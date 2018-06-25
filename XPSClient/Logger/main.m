//
//  main.m
//  Logger
//
//  Created by Anatoliy Goodz on 11/16/17.
//  Copyright © 2017 Anatoliy Goodz. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include "PSXLogProtocol.h"
#include "PSXConnectionProxy.h"

@interface PSXLogServiceProvider : NSObject <PSXLogProtocol, NSXPCListenerDelegate, NSApplicationDelegate>

- (void)resume;

@end

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        NSApplication *app = [NSApplication sharedApplication];
        
        PSXLogServiceProvider *provider = [[PSXLogServiceProvider alloc] init];
        [app setDelegate:provider];
        [provider resume];
        
        [app run];
    }
    
    return 0;
}

@implementation PSXLogServiceProvider
{
    NSXPCListener   *_listener;
    NSXPCConnection *_consumerConnection;
    NSFileHandle    *_handle;
}

- (void)resume
{
    _listener = [NSXPCListener anonymousListener];
    [_listener setDelegate:self];
    [_listener resume];
    
    NSXPCListenerEndpoint *endpoint = [_listener endpoint];
    
    PSXConnectionProxy *proxy = [PSXConnectionProxy defaultProxy];
    [proxy registerListenerEndpoint:endpoint
               forServiceIdentifier:kLogMessagesService
                  completionHandler:^(BOOL success){}];
}

- (BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)connection
{
    _consumerConnection = connection;
    [_consumerConnection setExportedInterface:[NSXPCInterface interfaceWithProtocol:@protocol(PSXLogProtocol)]];
    [_consumerConnection setExportedObject:self];
    [_consumerConnection resume];
    
    return YES;
}

#pragma mark -

- (void)logMessage:(NSString *)message
{
    [[self handle] writeData:[message dataUsingEncoding:NSUTF8StringEncoding]];
    [[self handle] synchronizeFile];
}

- (void)logMessage:(NSString *)message withReply:(void (^)())reply
{
    [self logMessage:message];
    reply();
}

- (void)shutdown
{
    [NSApp terminate:nil];
}

#pragma mark -

- (NSFileHandle *)handle
{
    if (nil == _handle)
    {
        NSString *pathToFile = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES)[0];
        pathToFile = [pathToFile stringByAppendingPathComponent:@"7C7C1890-91F9-4D85-AD6E-2AF65560C724.log"];
        
        [[NSFileManager defaultManager] createFileAtPath:pathToFile contents:nil attributes:nil];
        
        _handle = [NSFileHandle fileHandleForUpdatingAtPath:pathToFile];
    }
    
    return _handle;
}

@end
