//
//  PSXConnectionAcceptor.m
//  XPSClient
//
//  Created by Anatoliy Goodz on 11/17/17.
//  Copyright © 2017 Anatoliy Goodz. All rights reserved.
//

#import "PSXConnectionAcceptor.h"
#import "PSXConnectionProxy.h"

@interface PSXListener : NSObject

@property(nonatomic, readonly) NSXPCListenerEndpoint *endpoint;
@property(nonatomic, readonly, copy) void(^handler)(BOOL success);

+ (instancetype)listenerWithEndpoint:(NSXPCListenerEndpoint *)endpoint handler:(void(^)(BOOL success))handler;

@end

@implementation PSXConnectionAcceptor
{
    NSXPCListener       *_listener;
    dispatch_queue_t     _listenerQueue;
    NSMutableDictionary *_listeners;
    NSMutableDictionary *_clients;
}

- (id)init
{
    self = [super init];
    
    if(self)
    {
        _listener  = [[NSXPCListener alloc] initWithMachServiceName:kConnectionName];
        [_listener setDelegate:self];
        
        _listenerQueue    = dispatch_queue_create("com.Anatoliy.Goodz.ListenerQueue", DISPATCH_QUEUE_SERIAL);
        _listeners = [NSMutableDictionary dictionary];
        _clients   = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void)resume
{
    [_listener resume];
    
    __block BOOL isRunning = NO;
    
    do
    {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:5.0]];
        
        dispatch_sync(_listenerQueue,
            ^{
                isRunning = [_clients count] > 0 || [_listeners count] > 0;
            }
        );
    } while(isRunning);
}

- (BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)connection
{
    [connection setExportedInterface:[NSXPCInterface interfaceWithProtocol:@protocol(PSXServiceSelector)]];
    [connection setExportedObject:self];
    [connection resume];
    
    return YES;
}
- (void)registerListenerEndpoint:(NSXPCListenerEndpoint *)endpoint
    forServiceIdentifier:(NSString *)identifier
    completionHandler:(void (^)(BOOL))handler
{
    dispatch_async(_listenerQueue,
        ^{
            void (^clientBlock)(NSXPCListenerEndpoint *) = _clients[identifier];
            
            if(clientBlock == nil)
            {
                _listeners[identifier] = [PSXListener listenerWithEndpoint:endpoint handler:handler];
                return;
            }
            
            clientBlock(endpoint);
            handler(YES);
            [_clients removeObjectForKey:identifier];
        }
    );
}

- (void)retrieveListenerEndpointForServiceIdentifier:(NSString *)identifier
    completionHandler:(void (^)(NSXPCListenerEndpoint *))handler
{
    dispatch_async(_listenerQueue, ^{
        PSXListener *listener = _listeners[identifier];
        
        if(listener == nil)
        {
            _clients[identifier] = [handler copy];
            return;
        }
        
        handler([listener endpoint]);
        
        [listener handler](YES);
        [_listeners removeObjectForKey:identifier];
    });
}

@end

@implementation PSXListener

+ (instancetype)listenerWithEndpoint:(NSXPCListenerEndpoint *)endpoint handler:(void(^)(BOOL success))handler
{
    PSXListener *listener = [[PSXListener alloc] init];
    listener->_endpoint = endpoint;
    listener->_handler = [handler copy];
    
    return listener;
}

@end
