//
//  AppDelegate.m
//  NSTextProtocolTest
//
//  Created by Anatoliy Goodz on 10/21/15.
//  Copyright (c) 2015 smk.private. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    [self.textField1 objectDidBeginEditing:self];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (BOOL)commitEditingAndReturnError:(NSError **)error
{
    return YES;
}

@end
