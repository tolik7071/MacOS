//
//  PSXServiceSelectorProtocol.h
//  XPSClient
//
//  Created by Anatoliy Goodz on 11/16/17.
//  Copyright © 2017 Anatoliy Goodz. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PSXServiceSelector

- (void)registerListenerEndpoint:(NSXPCListenerEndpoint *)endpoint
    forServiceIdentifier:(NSString *)identifier
    completionHandler:(void (^)(BOOL))handler;

- (void)retrieveListenerEndpointForServiceIdentifier:(NSString *)identifier
    completionHandler:(void (^)(NSXPCListenerEndpoint *))handler;

@end
