//
//  ViewController.m
//  XPSClient
//
//  Created by Anatoliy Goodz on 10/12/17.
//  Copyright © 2017 Anatoliy Goodz. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "PSXLoggerClient.h"

#define CRASHED
#define USE_SEPARATED_QUEUE

@implementation ViewController

- (IBAction)doCrash2:(id)sender
{
#if defined(CRASHED)
    
    int *data = NULL;
    
#endif // CRASHED
    
    NSDate *start = [NSDate date];
    
    AppDelegate *delegate = (AppDelegate *)[NSApp delegate];
    
#if defined(USE_SEPARATED_QUEUE)
    
    PSXLoggerClient *client = [[PSXLoggerClient alloc] initWithLoggerDelegate:delegate.loggerProxy];
    
#endif // USE_SEPARATED_QUEUE
    
    for (int i = 1; i <= 10000 && delegate.logger.isRunning; i++)
    {
        NSString *message = [NSString stringWithFormat:@"message #%ld\n", (long)i];
//        NSLog(@"%@", message);
        
#if defined(USE_SEPARATED_QUEUE)
        
        [client logMessage:message];
        
#else
        
        __block NSLock *lock = [[NSLock alloc] init];
        
        [lock lock];
        
        [[delegate loggerProxy]
            logMessage:message
            withReply:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [lock unlock];
                });
            }
        ];
        
        while (YES)
        {
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0005]];
            
            if ([lock tryLock] || !delegate.logger.isRunning)
            {
                [lock unlock];
                break;
            }
        }
        
#endif // USE_SEPARATED_QUEUE
        
#if defined(CRASHED)
        
        if (9000 == i)
        {
            *data = i;
        }
        
#endif // CRASHED
        
    }
    
    NSLog(@"%f", [[NSDate date] timeIntervalSinceDate:start]);
}

@end
