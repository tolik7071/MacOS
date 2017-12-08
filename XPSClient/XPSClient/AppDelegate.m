//
//  AppDelegate.m
//  XPSClient
//
//  Created by Anatoliy Goodz on 10/12/17.
//  Copyright © 2017 Anatoliy Goodz. All rights reserved.
//

#import "AppDelegate.h"
#import "PSXConnectionProxy.h"

@implementation AppDelegate

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self setupAcceptor];
    [self startAcceptor];
    [self startLogger];
    [self loggerProxy];
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    [self stopAcceptor];
    [self stopLogger];
}

- (void)startLogger
{
    NSString *pathToLogger = [[NSBundle mainBundle] pathForResource:@"Logger" ofType:nil];
    NSAssert(pathToLogger, @"Logger does not found.");
    
    self.logger = [[NSTask alloc] init];
    [self.logger setLaunchPath:pathToLogger];
    
    [self.logger launch];
}

- (void)stopLogger
{
    //[self.logger terminate];
    [self.loggerProxy shutdown];
}

- (void)setupAcceptor
{
    static dispatch_once_t runOnlyOnce;
    
    dispatch_once(
        &runOnlyOnce,
        ^{
            NSString *pathToPlist = [[[self pathToAcceptorServiceFolder]
                stringByAppendingPathComponent:kConnectionName]
                stringByAppendingPathExtension:@"plist"];
            
            [[self acceptorPropertyList] writeToFile:pathToPlist atomically:YES];
        }
    );
}

- (NSDictionary *)acceptorPropertyList
{
    static NSDictionary *gPropertyList = nil;
    static dispatch_once_t runOnlyOnce;
    
    dispatch_once(
        &runOnlyOnce,
        ^{
            NSString *path = [[NSBundle mainBundle] pathForResource:@"Acceptor" ofType:nil];
            NSAssert(path, @"Logger does not found.");

            gPropertyList =
            @{
                @"Label" : kConnectionName,
                @"Program" : path,
                @"MachServices" : @{ kConnectionName : @{} }
            };
        }
    );
    
    return gPropertyList;
}

- (NSString *)pathToAcceptorServiceFolder
{
    static NSString *gPath = nil;
    static dispatch_once_t runOnlyOnce;
    
    dispatch_once(
        &runOnlyOnce,
        ^{
            gPath = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES)[0];
            gPath = [gPath stringByAppendingPathComponent:kConnectionName];
            
            [[NSFileManager defaultManager] createDirectoryAtPath:gPath
                withIntermediateDirectories:YES
                attributes:nil
                error:NULL];
        }
    );
    
    return gPath;
}

- (void)startAcceptor
{
    NSString *pathToAcceptorPlist = [[[self pathToAcceptorServiceFolder]
        stringByAppendingPathComponent:kConnectionName]
        stringByAppendingPathExtension:@"plist"];
    NSAssert([[NSFileManager defaultManager] fileExistsAtPath:pathToAcceptorPlist],
        @"Acceptor plist does not found.");
    
    NSTask *task = [[NSTask alloc] init];
    
    [task setLaunchPath:@"/bin/launchctl"];
    [task setArguments:@[ @"load", pathToAcceptorPlist]];
    
    [task setStandardOutput:[NSFileHandle fileHandleWithStandardOutput]];
    
    [task launch];
    [task waitUntilExit];
}

- (void)stopAcceptor
{
    NSString *pathToAcceptorPlist = [[[self pathToAcceptorServiceFolder]
        stringByAppendingPathComponent:kConnectionName]
        stringByAppendingPathExtension:@"plist"];
    
    NSTask *task = [[NSTask alloc] init];
    
    [task setLaunchPath:@"/bin/launchctl"];
    [task setArguments:@[ @"unload", pathToAcceptorPlist]];
    
    [task setStandardOutput:[NSFileHandle fileHandleWithStandardOutput]];
    
    [task launch];
    [task waitUntilExit];
}

- (id<PSXLogProtocol>)loggerProxy
{
    if (nil == _loggerProxy)
    {
        [[PSXConnectionProxy defaultProxy] retrieveListenerEndpointForServiceIdentifier:kLogMessagesService
            completionHandler:^(NSXPCListenerEndpoint *endpoint)
            {
                NSXPCConnection *connection = [[NSXPCConnection alloc] initWithListenerEndpoint:endpoint];
                [connection setRemoteObjectInterface:[NSXPCInterface interfaceWithProtocol:@protocol(PSXLogProtocol)]];
                [connection resume];

                _loggerProxy = [connection remoteObjectProxy];
            }
        ];
    }
    
    return _loggerProxy;
}

@end
