//
//  PSXConnectionProxy.m
//  XPSClient
//
//  Created by Anatoliy Goodz on 11/16/17.
//  Copyright © 2017 Anatoliy Goodz. All rights reserved.
//

#import "PSXConnectionProxy.h"

NSString * const kConnectionName = @"Anatoliy-Goodz.XPSServer";

@implementation PSXConnectionProxy
{
    id<PSXServiceSelector> _proxy;
}

+ (instancetype)defaultProxy
{
    static PSXConnectionProxy *gProxy = nil;
    static dispatch_once_t runOnlyOnce;
    
    dispatch_once(
        &runOnlyOnce,
        ^{
            gProxy = [[PSXConnectionProxy alloc] init];
         }
    );
    
    return gProxy;
}

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        _connection = [[NSXPCConnection alloc] initWithMachServiceName:kConnectionName options:0];
        [_connection setRemoteObjectInterface:[NSXPCInterface interfaceWithProtocol:@protocol(PSXServiceSelector)]];
        [_connection resume];
        
        _proxy = [_connection remoteObjectProxy];
    }
    
    return self;
}

- (void)registerListenerEndpoint:(NSXPCListenerEndpoint *)endpoint
    forServiceIdentifier:(NSString *)identifier
    completionHandler:(void (^)(BOOL))handler
{
    [_proxy registerListenerEndpoint:endpoint forServiceIdentifier:identifier completionHandler:handler];
}

- (void)retrieveListenerEndpointForServiceIdentifier:(NSString *)identifier
    completionHandler:(void (^)(NSXPCListenerEndpoint *))handler
{
    [_proxy retrieveListenerEndpointForServiceIdentifier:identifier completionHandler:handler];
}

@end
