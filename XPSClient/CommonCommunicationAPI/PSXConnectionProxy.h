//
//  PSXConnectionProxy.h
//  XPSClient
//
//  Created by Anatoliy Goodz on 11/16/17.
//  Copyright © 2017 Anatoliy Goodz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSXServiceSelectorProtocol.h"

extern NSString * const kConnectionName;

@interface PSXConnectionProxy : NSObject <PSXServiceSelector>

+ (instancetype)defaultProxy;

@property (nonatomic, readonly) NSXPCConnection *connection;

@end
