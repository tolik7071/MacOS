//
//  ViewController.m
//  ControlWithoutCll
//
//  Created by Anatoliy Goodz on 1/22/18.
//  Copyright © 2018 Anatoliy Goodz. All rights reserved.
//

#import "ViewController.h"
#import "MyControl.h"

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.control.color = [NSColor yellowColor];
}

- (IBAction)handleAction:(id)sender
{
    self.control.color = ([self.control.color isEqualTo:[NSColor yellowColor]]) ? [NSColor redColor] : [NSColor yellowColor];
    
    [self.control setNeedsDisplay:YES];
}

@end
