//
//  ViewController.h
//  springmass
//
//  Created by tolik7071 on 10/17/18.
//  Copyright © 2018 tolik7071. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SBViewControllerBase.h"
#import "SB_FPS_Counter.h"

@interface ViewController : SBViewControllerBase

@property (nonatomic, weak) IBOutlet NSTextField *fps;

@end
