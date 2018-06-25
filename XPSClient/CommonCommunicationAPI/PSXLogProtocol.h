//
//  PSXLogProtocol.h
//  XPSClient
//
//  Created by Anatoliy Goodz on 11/16/17.
//  Copyright © 2017 Anatoliy Goodz. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kLogMessagesService @"LogMessagesService"
//NSString * const kLogMessagesService = @"LogMessagesService";

@protocol PSXLogProtocol

- (void)logMessage:(NSString *)message;
- (void)logMessage:(NSString *)message withReply:(void (^)())reply;
- (void)shutdown;

@end
