// AFHTTPClientLogger.m
//
// Copyright (c) 2012 Jon Parise
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "AFHTTPClientLogger.h"
#import "AFHTTPRequestOperation.h"
#import "AFJSONRequestOperation.h"

#import <objc/runtime.h>

typedef NSString * (^AFHTTPClientLoggerFormatBlock)(AFHTTPRequestOperation *operation, AFHTTPClientLogLevel level);

@interface AFHTTPClientLogger ()
@property (readwrite, nonatomic) NSString *baseURLString;
@property (readwrite, nonatomic, copy) AFHTTPClientLoggerFormatBlock requestStartFormatBlock;
@property (readwrite, nonatomic, copy) AFHTTPClientLoggerFormatBlock requestFinishFormatBlock;
@end

#pragma mark -

@implementation AFHTTPClientLogger

@synthesize baseURLString = _baseURLString;
@synthesize requestStartFormatBlock = _requestStartFormatBlock;
@synthesize requestFinishFormatBlock = _requestFinishFormatBlock;
@synthesize enabled = _enabled;
@synthesize level = _level;

- (instancetype)initWithBaseURL:(NSURL *)baseURL {
    if ((self = [super init])) {
        self.baseURLString = [baseURL absoluteString];
        self.level = AFHTTPClientLogLevelInfo;
    }

    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setEnabled:(BOOL)enabled {
    if (enabled != _enabled) {
        if (enabled) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(operationDidStart:) name:AFNetworkingOperationDidStartNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(operationDidFinish:) name:AFNetworkingOperationDidFinishNotification object:nil];
        } else {
            [[NSNotificationCenter defaultCenter] removeObserver:self];
        }

        _enabled = enabled;
    }
}

- (void)operationDidStart:(NSNotification *)notification {
    AFHTTPRequestOperation *operation = [notification object];
    if (![[[operation.request URL] absoluteString] hasPrefix:self.baseURLString]) {
        return;
    }

    if (self.requestStartFormatBlock) {
        NSString *formattedString = self.requestStartFormatBlock(operation, self.level);
        if (formattedString) {
            NSLog(@"%@", formattedString);
        }
        return;
    }

    id body = nil;
    if ([operation.request HTTPBody] && self.level <= AFHTTPClientLogLevelVerbose) {
        if ([operation isKindOfClass:[AFJSONRequestOperation class]]) {
            body = [NSJSONSerialization JSONObjectWithData:[operation.request HTTPBody] options:NSJSONReadingAllowFragments error:nil];
        } else {
            body = [[NSString alloc] initWithData:[operation.request HTTPBody] encoding:NSUTF8StringEncoding];
        }
    }

    switch (self.level) {
        case AFHTTPClientLogLevelDebug:
            if (body) {
                NSLog(@">> %@ %@\n%@\n%@", [operation.request HTTPMethod], [[operation.request URL] absoluteString], [operation.request allHTTPHeaderFields], body);
            } else {
                NSLog(@">> %@ %@\n%@", [operation.request HTTPMethod], [[operation.request URL] absoluteString], [operation.request allHTTPHeaderFields]);
            }
            break;
        case AFHTTPClientLogLevelVerbose:
            if (body) {
                NSLog(@">> %@ %@\n%@", [operation.request HTTPMethod], [[operation.request URL] absoluteString], body);
            } else {
                NSLog(@">> %@ %@", [operation.request HTTPMethod], [[operation.request URL] absoluteString]);
            }
            break;
        case AFHTTPClientLogLevelInfo:
            NSLog(@">> %@ %@", [operation.request HTTPMethod], [[operation.request URL] absoluteString]);
            break;
        default:
            break;
    }
}

- (void)operationDidFinish:(NSNotification *)notification {
    AFHTTPRequestOperation *operation = [notification object];
    if (![[[operation.request URL] absoluteString] hasPrefix:self.baseURLString]) {
        return;
    }

    if (self.requestFinishFormatBlock) {
        NSString *formattedString = self.requestFinishFormatBlock(operation, self.level);
        if (formattedString) {
            NSLog(@"%@", formattedString);
        }
        return;
    }

    NSURL *URL = (operation.response) ? [operation.response URL] : [operation.request URL];
    id responseObject = ([operation isKindOfClass:[AFJSONRequestOperation class]]) ? ((AFJSONRequestOperation *)operation).responseJSON : operation.responseString;

    if (operation.error) {
        switch (self.level) {
            case AFHTTPClientLogLevelDebug:
                NSLog(@"!! %ld %@: %@", (long)[operation.response statusCode], [URL absoluteString], operation.error);
                break;
            case AFHTTPClientLogLevelVerbose:
            case AFHTTPClientLogLevelInfo:
            case AFHTTPClientLogLevelError:
                NSLog(@"!! %ld %@: %@", (long)[operation.response statusCode], [URL absoluteString], [operation.error localizedDescription]);
                break;
        }
    } else {
        switch (self.level) {
            case AFHTTPClientLogLevelDebug:
                if (operation.responseString) {
                    NSLog(@"<< %ld %@\n%@\n%@", (long)[operation.response statusCode], [URL absoluteString], [operation.response allHeaderFields], responseObject);
                } else {
                    NSLog(@"<< %ld %@\n%@", (long)[operation.response statusCode], [URL absoluteString], [operation.response allHeaderFields]);
                }
                break;
            case AFHTTPClientLogLevelVerbose:
                if (operation.responseString) {
                    NSLog(@"<< %ld %@\n%@", (long)[operation.response statusCode], [URL absoluteString], responseObject);
                } else {
                    NSLog(@"<< %ld %@", (long)[operation.response statusCode], [URL absoluteString]);
                }
                break;
            case AFHTTPClientLogLevelInfo:
                NSLog(@"<< %ld %@", (long)[operation.response statusCode], [URL absoluteString]);
                break;
            default:
                break;
        }
    }
}

@end

#pragma mark -

@implementation AFHTTPClient (Logging)

static char AFHTTPClientLoggerObject;

- (AFHTTPClientLogger *)logger {
    AFHTTPClientLogger *logger = objc_getAssociatedObject(self, &AFHTTPClientLoggerObject);
    if (logger == nil) {
        logger = [[AFHTTPClientLogger alloc] initWithBaseURL:self.baseURL];
        objc_setAssociatedObject(self, &AFHTTPClientLoggerObject, logger, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }

    return logger;
}

@end
