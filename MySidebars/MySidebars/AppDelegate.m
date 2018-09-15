//
//  AppDelegate.m
//  MySidebars
//
//  Created by Anatoliy Goodz on 9/13/18.
//  Copyright © 2018 Anatoliy Goodz. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@end

@implementation AppDelegate

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

@end
