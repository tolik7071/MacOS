//
//  AppDelegate.m
//  WindowControllerTest
//
//  Created by Anatoliy Goodz on 10/30/15.
//  Copyright (c) 2015 smk.private. All rights reserved.
//

#import "AppDelegate.h"
#import "MyWindowController.h"

@interface AppDelegate ()

@property IBOutlet NSWindow *window;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{

}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{

}

- (IBAction)showSomeWindow:(id)sender
{
    MyWindowController *controller = [[[MyWindowController alloc] init] autorelease];
    
    if ([controller showWindowModal])
    {
        
    }
}

- (void)changeColor:(id)sender
{
//    NSLog(@"%@", [sender color]);
}

@end
