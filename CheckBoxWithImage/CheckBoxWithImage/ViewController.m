//
//  ViewController.m
//  CheckBoxWithImage
//
//  Created by Anatoliy Goodz on 9/26/16.
//  Copyright © 2016 Anatoliy Goodz. All rights reserved.
//

#import "ViewController.h"
#import "PSXCheckBoxWithImageCell.h"

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSImage *image = [NSImage imageNamed:@"image"];
    assert(image != NULL);
    
    [(PSXCheckboxWithImageCell *)self.button.cell setThumbnailImage:image];
}

@end
