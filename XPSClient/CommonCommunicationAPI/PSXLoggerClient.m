//
//  PSXLoggerClient.m
//  XPSClient
//
//  Created by Anatoliy Goodz on 11/27/17.
//  Copyright © 2017 Anatoliy Goodz. All rights reserved.
//

#import "PSXLoggerClient.h"

@interface PSXLoggerClient ()
{
    dispatch_queue_t    _queue;
    id<PSXLogProtocol>  _loggerDelegate;
}

@end

@implementation PSXLoggerClient

- (instancetype)initWithLoggerDelegate:(id<PSXLogProtocol>)loggerDelegate
{
    self = [super init];
    
    if (self != nil)
    {
        _loggerDelegate = loggerDelegate;
    }
    
    return self;
}

- (dispatch_queue_t)queue
{
    if (NULL == _queue)
    {
        _queue = dispatch_queue_create("com.anatoliy.goodz.logger-client-queue", DISPATCH_QUEUE_SERIAL);
    }
    
    return _queue;
}

- (void)logMessage:(NSString *)message
{
    dispatch_async([self queue], ^{
        
        __block NSLock *lock = [[NSLock alloc] init];
        NSRunLoop *loop = [NSRunLoop currentRunLoop];
        
        [lock lock];
        
        [_loggerDelegate logMessage:message
            withReply:^{
                
                [loop performBlock:^{
                    [lock unlock];
                }];
                
            }
        ];
        
        while (YES)
        {
            if ([lock tryLock])
            {
                [lock unlock];
                break;
            }
            
            [loop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0005]];
        }
        
    });
}

@end
