//
//  ViewController.m
//  TwoViews
//
//  Created by Anatoliy Goodz on 5/30/16.
//  Copyright © 2016 Anatoliy Goodz. All rights reserved.
//

#import "ViewController.h"
#import "ChildView.h"

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self performSelector:@selector(setupChildOrigin) withObject:nil afterDelay:3.0];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (void)setupChildOrigin
{
    ChildView *subview = [[ChildView alloc] initWithFrame:
                          NSMakeRect(100.0, 100.0, 200.0, 200.0)];
    [self.view addSubview:subview];
    
    NSPoint origin = NSMakePoint(
        NSMaxX(self.view.bounds) - NSWidth(subview.frame),
        (NSHeight(self.view.bounds) - NSHeight(subview.frame)) / 2.0);

    [subview setFrameOrigin:origin];
}

@end
