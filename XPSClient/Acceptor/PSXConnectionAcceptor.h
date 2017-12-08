//
//  PSXConnectionAcceptor.h
//  XPSClient
//
//  Created by Anatoliy Goodz on 11/17/17.
//  Copyright © 2017 Anatoliy Goodz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSXServiceSelectorProtocol.h"

@interface PSXConnectionAcceptor : NSObject <NSXPCListenerDelegate, PSXServiceSelector>

- (void)resume;

@end
