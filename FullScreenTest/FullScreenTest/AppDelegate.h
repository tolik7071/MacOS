//
//  AppDelegate.h
//  FullScreenTest
//
//  Created by Anatoliy Goodz on 1/11/16.
//  Copyright (c) 2016 smk.private. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, retain) NSPopover *popover;

- (IBAction)showDialog:(id)sender;

@end

