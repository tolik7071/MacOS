//
//  PSXLoggerClient.h
//  XPSClient
//
//  Created by Anatoliy Goodz on 11/27/17.
//  Copyright © 2017 Anatoliy Goodz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSXLogProtocol.h"

@interface PSXLoggerClient : NSObject

- (instancetype)initWithLoggerDelegate:(id<PSXLogProtocol>)loggerDelegate;

- (void)logMessage:(NSString *)message;

@end
