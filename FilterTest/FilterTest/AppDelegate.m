//
//  AppDelegate.m
//  FilterTest
//
//  Created by Anatoliy Goodz on 7/8/15.
//  Copyright (c) 2015 smk.private. All rights reserved.
//

#import "AppDelegate.h"
#import "MyView.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSImage *image = [NSImage imageNamed:@"background"];
    NSAssert(image != nil, @"No image");
    
    self.leftView.image = image;
    [self.leftView setNeedsDisplay:YES];
    
    self.rigthView.image = image;
    self.rigthView.isGrey = YES;
    [self.rigthView setNeedsDisplay:YES];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
