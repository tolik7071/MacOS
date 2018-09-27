//
//  ViewController.m
//  ConstraintsTest
//
//  Created by Anatoliy Goodz on 9/26/18.
//  Copyright © 2018 Anatoliy Goodz. All rights reserved.
//

#import "ViewController.h"
#import "ChildView.h"

void DumpAutoresizingMask(NSAutoresizingMaskOptions mask)
{
    if ((mask & NSViewNotSizable) != 0)
        printf("NSViewNotSizable - The view cannot be resized.\n");
    
    if ((mask & NSViewMinXMargin) != 0)
        printf("NSViewMinXMargin - The left margin between the view and its superview is flexible.\n");
        
    if ((mask & NSViewWidthSizable) != 0)
        printf("NSViewWidthSizable - The view’s width is flexible.\n");
    
    if ((mask & NSViewMaxXMargin) != 0)
        printf("NSViewMaxXMargin - The right margin between the view and its superview is flexible.\n");
    
    if ((mask & NSViewMinYMargin) != 0)
        printf("NSViewMinYMargin - The bottom margin between the view and its superview is flexible.\n");
    
    if ((mask & NSViewHeightSizable) != 0)
        printf("NSViewHeightSizable - The view’s height is flexible.\n");
    
    if ((mask & NSViewMaxYMargin) != 0)
        printf("NSViewMaxYMargin - The top margin between the view and its superview is flexible.\n");
}

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    assert(self.view);

    ChildView *yellowView = [self.view subviews][0];
    yellowView.backgroundColor = [NSColor yellowColor];

    printf("ROOT VIEW:\n");
    DumpAutoresizingMask(self.view.autoresizingMask);
    printf("\n");
    
    printf("YELLOW VIEW:\n");
    DumpAutoresizingMask(yellowView.autoresizingMask);
    printf("\n");

    [self addRedView];
    [self addBlueView];
}

- (void)addRedView
{
    ChildView *redView = [[ChildView alloc] initWithFrame:NSMakeRect(0, 0, 200.0, 200.0)];
    redView.backgroundColor = [NSColor redColor];

    NSLayoutConstraint *constraint;

    {
        constraint = [NSLayoutConstraint
            constraintWithItem:redView
            attribute:NSLayoutAttributeWidth
            relatedBy:NSLayoutRelationEqual
            toItem:nil
            attribute:NSLayoutAttributeNotAnAttribute
            multiplier:1.0
            constant:200.0];

        [redView addConstraint:constraint];
    }

    {
        constraint = [NSLayoutConstraint
            constraintWithItem:redView
            attribute:NSLayoutAttributeHeight
            relatedBy:NSLayoutRelationEqual
            toItem:nil
            attribute:NSLayoutAttributeNotAnAttribute
            multiplier:1.0
            constant:200.0];

        [redView addConstraint:constraint];
    }

    {
        constraint = [NSLayoutConstraint
            constraintWithItem:redView
            attribute:NSLayoutAttributeLeading
            relatedBy:NSLayoutRelationEqual
            toItem:self.view
            attribute:NSLayoutAttributeLeading
            multiplier:1.0
            constant:0.0];

        [self.view addConstraint:constraint];
    }

    {
        constraint = [NSLayoutConstraint
            constraintWithItem:redView
            attribute:NSLayoutAttributeBottom
            relatedBy:NSLayoutRelationEqual
            toItem:self.view
            attribute:NSLayoutAttributeBottom
            multiplier:1.0
            constant:0.0];

        [self.view addConstraint:constraint];
    }
    
    [self.view addSubview:redView];
    
    printf("RED VIEW:\n");
    DumpAutoresizingMask(redView.autoresizingMask);
    printf("\n");
}

- (void)addBlueView
{
    ChildView *blueView = [[ChildView alloc] initWithFrame:NSMakeRect(200, 200, 400.0, 200.0)];
    blueView.backgroundColor = [NSColor blueColor];
    
    [self.view addSubview:blueView];
    
    printf("BLUE VIEW:\n");
    DumpAutoresizingMask(blueView.autoresizingMask);
    printf("\n");
}

@end
