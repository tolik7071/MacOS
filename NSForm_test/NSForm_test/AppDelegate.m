//
//  AppDelegate.m
//  NSForm_test
//
//  Created by Anatoliy Goodz on 6/8/15.
//  Copyright (c) 2015 smk.private. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
//    [self.myForm setNeedsLayout:YES];
//    NSLog(@"%@", [[self.myForm cellAtIndex:0] description]);
//    [[self.myForm currentEditor] setNeedsLayout:YES];
    
//    NSInteger columns = [self.myForm numberOfColumns];
//    for (int column = 0; column < columns; ++column)
//    {
//        NSInteger rows = [self.myForm numberOfRows];
//        for (int row = 0; row < rows; ++row)
//        {
//            NSCell *cell = [self.myForm cellAtRow:row column:column];
//            NSLog(@"%@", [cell description]);
//        }
//    }
    
    NSSize size = [self.myForm cellSize];
    size.height = 22;
    size.width = 160;
    [self.myForm setCellSize:size];
    [self.myForm setNeedsLayout:YES];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
