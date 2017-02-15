//
//  AppDelegate.h
//  FilterTest
//
//  Created by Anatoliy Goodz on 7/8/15.
//  Copyright (c) 2015 smk.private. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MyView;

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet MyView* leftView;
@property (assign) IBOutlet MyView* rigthView;

@end

