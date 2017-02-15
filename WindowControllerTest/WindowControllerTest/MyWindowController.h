//
//  MyWindowController.h
//  WindowControllerTest
//
//  Created by Anatoliy Goodz on 10/30/15.
//  Copyright (c) 2015 smk.private. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MyWindowController : NSWindowController

@property (assign) BOOL colorPanelIsVisible;

- (IBAction)closeMe:(id)sender;

- (NSInteger)showWindowModal;

@end
