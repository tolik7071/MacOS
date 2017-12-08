//
//  main.m
//  Logger
//
//  Created by Anatoliy Goodz on 12/7/17.
//  Copyright © 2017 Anatoliy Goodz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PSXLogger : NSObject <NSApplicationDelegate>
{
    NSFileHandle    *_handle;
}

@end

@implementation PSXLogger

- (void)handleDataAvailable:(NSNotification*)notification
{
    NSFileHandle *fileHandle = [notification object];
    
    sleep(5);
    [self writeData:[fileHandle availableData]];
    
    [fileHandle waitForDataInBackgroundAndNotify];
}

- (void)writeData:(NSData *)data
{
//    NSLog(@"LOG begin: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    [[self handle] writeData:data];
    [[self handle] synchronizeFile];
//    NSLog(@"LOG end.");
}

- (NSFileHandle *)handle
{
    if (nil == _handle)
    {
        NSString *pathToFile = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES)[0];
        pathToFile = [pathToFile stringByAppendingPathComponent:@"85B97D14-4A5D-49C9-A55A-7513BAFC5E31.log"];
        
        [[NSFileManager defaultManager] createFileAtPath:pathToFile contents:nil attributes:nil];
        
        _handle = [NSFileHandle fileHandleForUpdatingAtPath:pathToFile];
    }
    
    return _handle;
}

@end

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        PSXLogger *logger = [PSXLogger new];
        
        NSApplication *app = [NSApplication sharedApplication];
        
        app.delegate = logger;
        
        NSFileHandle* inputHandle = [NSFileHandle fileHandleWithStandardInput];
        
        [[NSNotificationCenter defaultCenter]
            addObserver:logger
            selector:@selector(handleDataAvailable:)
            name:NSFileHandleDataAvailableNotification
            object:inputHandle];
        
        [inputHandle waitForDataInBackgroundAndNotify];
        
        [app run];
    }

    return 0;
}
