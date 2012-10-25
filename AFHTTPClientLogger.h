// AFHTTPClientLogger.h
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

#import "AFHTTPClient.h"

typedef enum {
    AFHTTPClientLogLevelDebug,
    AFHTTPClientLogLevelVerbose,
    AFHTTPClientLogLevelInfo,
    AFHTTPClientLogLevelError,
} AFHTTPClientLogLevel;

#pragma mark -

/**
 `AFHTTPClientLogger` provides configurable HTTP request logging features.
 */
@interface AFHTTPClientLogger : NSObject

/**
 Is the logger current enabled?  Defaults to `NO`.
 */
@property (assign, nonatomic, getter=isEnabled) BOOL enabled;

/**
 The logger's current output level.  Defaults to `AFHTTPClientLogLevelInfo`.
 */
@property (assign, nonatomic) AFHTTPClientLogLevel level;

/**
 Sets a block that will be used to format log strings for HTTP request start events.

 @param block A block object that should return a formatted log string representing the given request operation.  It can also return `nil` if nothing should be logged.
 */
- (void)setRequestStartFormatBlock:(NSString * (^)(AFHTTPRequestOperation *operation, AFHTTPClientLogLevel level))block;

/**
 Sets a block that will be used to format log strings for HTTP request finish events.

 @param block A block object that should return a formatted log string representing the given request operation.  It can also return `nil` if nothing should be logged.
 */
- (void)setRequestFinishFormatBlock:(NSString * (^)(AFHTTPRequestOperation *operation, AFHTTPClientLogLevel level))block;

@end

#pragma mark -

/**
 `AFHTTPClient` category that provides access to the logger.
*/
@interface AFHTTPClient (Logging)

/**
 The HTTP client's logger. A logger will be created if one doesn't already exist.
 */
@property (readonly, nonatomic) AFHTTPClientLogger *logger;

@end
