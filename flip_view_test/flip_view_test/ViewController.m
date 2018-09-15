//
//  ViewController.m
//  flip_view_test
//
//  Created by Anatoliy Goodz on 9/4/18.
//  Copyright © 2018 Anatoliy Goodz. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.rightView.shouldBeFlipped = YES;
    
    assert(self.leftView.isFlipped == NO && self.rightView.isFlipped == YES);
}

@end
