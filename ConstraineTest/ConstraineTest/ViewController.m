//
//  ViewController.m
//  ConstraineTest
//
//  Created by Anatoliy Goodz on 1/30/16.
//  Copyright © 2016 Anatoliy Goodz. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.textField.placeholder = self.label.text;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    self.label.text = textField.text;
    return YES;
}

@end
