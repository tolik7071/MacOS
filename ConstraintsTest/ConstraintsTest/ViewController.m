//
//  ViewController.m
//  ConstraintsTest
//
//  Created by Anatoliy Goodz on 9/26/18.
//  Copyright © 2018 Anatoliy Goodz. All rights reserved.
//

#import "ViewController.h"
#import "ChildView.h"

@implementation ViewController

- (void)viewDidLoad
{
   [super viewDidLoad];

   assert(self.view);

/*

 po [yellowView constraints]
 <__NSArrayM 0x60400024ace0>(
 <NSLayoutConstraint:0x60000008ae10 ChildView:0x600000121f40.width == 200   (active)>,
 <NSLayoutConstraint:0x60000008af00 ChildView:0x600000121f40.height == 200   (active)>
 )

 po [self.view constraints]
 <__NSArrayM 0x60400024ac50>(
 <NSLayoutConstraint:0x60000008ad70 ChildView:0x600000121f40.centerY == NSView:0x600000121ea0.centerY   (active)>,
 <NSLayoutConstraint:0x60000008ac30 ChildView:0x600000121f40.centerX == NSView:0x600000121ea0.centerX   (active)>
 )

 */


   ChildView *yellowView = [self.view subviews][0];
   yellowView.backgroundColor = [NSColor yellowColor];

   [self addRedView];
}

- (void)addRedView
{
   ChildView *redView = [[ChildView alloc] initWithFrame:NSMakeRect(0, 0, 200.0, 200.0)];
   redView.backgroundColor = [NSColor redColor];

   NSLayoutConstraint *constraint;

   {
      // <NSLayoutConstraint:0x6040000888e0 ChildView:0x604000121540.width == 200   (active)>,
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
      // <NSLayoutConstraint:0x604000088890 ChildView:0x604000121540.height == 200   (active)>
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
      // po [self.view constraints]
      // <NSLayoutConstraint:0x604000088980 ChildView:0x604000121540.centerX == NSView:0x604000121400.centerX   (active)>
      constraint = [NSLayoutConstraint
         constraintWithItem:redView
         attribute:NSLayoutAttributeCenterX
         relatedBy:NSLayoutRelationEqual
         toItem:self.view
         attribute:NSLayoutAttributeCenterX
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
}

@end
