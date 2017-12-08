//
//  AppDelegate.h
//  XPSClient
//
//  Created by Anatoliy Goodz on 10/12/17.
//  Copyright © 2017 Anatoliy Goodz. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PSXConnectionProxy.h"
#import "PSXLogProtocol.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic) id<PSXLogProtocol> loggerProxy;
@property (nonatomic) NSTask *logger;

@end
