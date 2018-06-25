//
//  ViewController.m
//  InscribeRectangle
//
//  Created by Anatoliy Goodz on 1/5/18.
//  Copyright © 2018 Anatoliy Goodz. All rights reserved.
//

#import "ViewController.h"
#import "MyPreview.h"

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self resetPreview];
}

- (IBAction)inscribeYellowRect:(id)sender
{
    [self.preview inscribe];
}

- (IBAction)reset:(id)sender
{
    [self resetPreview];
}

- (void)resetPreview
{
    self.preview.inscribedRectSize = NSMakeSize(400, 400);
    [self.preview setNeedsDisplay:YES];
}

@end
