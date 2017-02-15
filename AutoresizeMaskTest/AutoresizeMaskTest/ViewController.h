//
//  ViewController.h
//  AutoresizeMaskTest
//
//  Created by Anatoliy Goodz on 5/18/16.
//  Copyright © 2016 Anatoliy Goodz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController

@property (nonatomic, weak) IBOutlet NSView *rightView;
@property (nonatomic, weak) IBOutlet NSView *testView;

@property (nonatomic) IBOutlet NSNumber* testViewY;
@property (nonatomic) IBOutlet NSNumber* testViewX;

@property (nonatomic) IBOutlet NSNumber* isMinXMarginOn;
@property (nonatomic) IBOutlet NSNumber* isViewWidthSizable;
@property (nonatomic) IBOutlet NSNumber* isMaxXMarginOn;
@property (nonatomic) IBOutlet NSNumber* isMinYMarginOn;
@property (nonatomic) IBOutlet NSNumber* isViewHeightSizable;
@property (nonatomic) IBOutlet NSNumber* isMaxYMarginOn;

@end

