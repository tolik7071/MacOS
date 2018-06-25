//
//  ViewController.h
//  ControlWithoutCll
//
//  Created by Anatoliy Goodz on 1/22/18.
//  Copyright © 2018 Anatoliy Goodz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MyControl;

@interface ViewController : NSViewController

@property (nonatomic, weak) IBOutlet MyControl *control;

@end
