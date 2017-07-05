//
//  AppDelegate.m
//  FullScreenTest
//
//  Created by Anatoliy Goodz on 1/11/16.
//  Copyright (c) 2016 smk.private. All rights reserved.
//

#import "AppDelegate.h"
#import "MyPopoverController.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (IBAction)showDialog:(id)sender
{
    if (self.popover == nil)
    {
        self.popover = [[NSPopover alloc] init];
        MyPopoverController *controller = [[MyPopoverController alloc] init];
        assert(controller != nil);
        self.popover.contentViewController = controller; 
    }
    
    [self.popover showRelativeToRect:[(NSButton *)sender frame]
                              ofView:self.window.contentView
                       preferredEdge:NSMinXEdge];
//    [self.window addChildWindow:self.panel ordered:NSWindowAbove];
//    [self.panel makeKeyAndOrderFront:self.window];
}

@end
