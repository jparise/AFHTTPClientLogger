# AFHTTPClientLogger

AFHTTPClientLogger is a request logging extension for [AFNetworking][].  It
provides configurable HTTP request logging features on a per `AFHTTPRequestOperationManager`
instance basis.

It is conceptually similar to [AFHTTPRequestOperationLogger][], which works
globally across all `AFHTTPRequestOperationManager` instances.

AFHTTPClientLogger supports logging via [CocoaLumberjack][] and will use its logging methods over `NSLog` if it's available.

## Usage

The logger is accessed via the `logger` property of an `AFHTTPRequestOperationManager` object
instance (simply named `manager` in the examples below).  It must be explicitly
enabled:

```objective-c
manager.logger.enabled = YES;
```

You can configure the log level to control the output's verbosity:

```objective-c
manager.logger.level = AFHTTPClientLogLevelDebug;
```

You can also customize the output by supplying your own format blocks:

```objective-c
[manager.logger setRequestStartFormatBlock:^NSString *(AFHTTPRequestOperation *operation, AFHTTPClientLogLevel level) {
    if (level > AFHTTPClientLogLevelInfo) {
        return nil;
    }

    return [NSString stringWithFormat:@"%@ %@", [operation.request HTTPMethod], [[operation.request URL] absoluteString]];
}];
```

## License

AFHTTPClientLogger is available under the MIT license.  See the included
LICENSE file for details.

## Contact

 - Email: jon@indelible.org
 - GitHub: [@jparise](https://github.com/jparise)
 - Twitter: [@jparise](https://twitter.com/jparise)

[AFNetworking]: http://afnetworking.com/
[AFHTTPRequestOperationLogger]: https://github.com/AFNetworking/AFHTTPRequestOperationLogger
[CocoaLumberjack]: https://github.com/CocoaLumberjack/CocoaLumberjack
