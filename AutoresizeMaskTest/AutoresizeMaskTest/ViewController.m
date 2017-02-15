//
//  ViewController.m
//  AutoresizeMaskTest
//
//  Created by Anatoliy Goodz on 5/18/16.
//  Copyright © 2016 Anatoliy Goodz. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)setRepresentedObject:(id)representedObject
{
    [super setRepresentedObject:representedObject];
}

- (NSNumber *)testViewY
{
    return [NSNumber numberWithDouble:self.testView.frame.origin.y];
}

- (void)setTestViewY:(NSNumber *)newValue
{
//    NSRect oldFrame = self.testView.frame;
//    oldFrame.origin.y = [newValue doubleValue];
}

- (NSNumber *)testViewX
{
    return [NSNumber numberWithDouble:self.testView.frame.origin.x];
}

- (void)setTestViewX:(NSNumber *)newValue
{
//    NSRect oldFrame = self.testView.frame;
//    oldFrame.origin.x = [newValue doubleValue];
}

- (void)setBit:(NSUInteger)aBit to:(BOOL)aFlag
{
    if (aFlag)
    {
        self.testView.autoresizingMask |= aBit;
    }
    else
    {
        self.testView.autoresizingMask &= ~aBit;
    }
}

- (NSNumber *)isMinXMarginOn
{
    return [NSNumber numberWithBool:((self.testView.autoresizingMask & NSViewMinXMargin) != 0)];
}

- (void)setIsMinXMarginOn:(NSNumber *)newValue
{
    [self setBit:NSViewMinXMargin to:[newValue boolValue]];
    
    NSAssert([self.isMinXMarginOn boolValue] == [newValue boolValue], @"Oops!!!");
}

- (NSNumber *)isViewWidthSizable
{
    return [NSNumber numberWithBool:((self.testView.autoresizingMask & NSViewWidthSizable) != 0)];
}

- (void)setIsViewWidthSizable:(NSNumber *)newValue
{
    [self setBit:NSViewWidthSizable to:[newValue boolValue]];
    
    NSAssert([self.isViewWidthSizable boolValue] == [newValue boolValue], @"Oops!!!");
}

- (NSNumber *)isMaxXMarginOn
{
    return [NSNumber numberWithBool:((self.testView.autoresizingMask & NSViewMaxXMargin) != 0)];
}

- (void)setIsMaxXMarginOn:(NSNumber *)newValue
{
    [self setBit:NSViewMaxXMargin to:[newValue boolValue]];
    
    NSAssert([self.isMaxXMarginOn boolValue] == [newValue boolValue], @"Oops!!!");
}

- (NSNumber *)isMinYMarginOn
{
    return [NSNumber numberWithBool:((self.testView.autoresizingMask & NSViewMinYMargin) != 0)];
}

- (void)setIsMinYMarginOn:(NSNumber *)newValue
{
    [self setBit:NSViewMinYMargin to:[newValue boolValue]];
    
    NSAssert([self.isMinYMarginOn boolValue] == [newValue boolValue], @"Oops!!!");
}

- (NSNumber *)isViewHeightSizable
{
    return [NSNumber numberWithBool:((self.testView.autoresizingMask & NSViewHeightSizable) != 0)];
}

- (void)setIsViewHeightSizable:(NSNumber *)newValue
{
    [self setBit:NSViewHeightSizable to:[newValue boolValue]];
    
    NSAssert([self.isViewHeightSizable boolValue] == [newValue boolValue], @"Oops!!!");
}

- (NSNumber *)isMaxYMarginOn
{
    return [NSNumber numberWithBool:((self.testView.autoresizingMask & NSViewMaxYMargin) != 0)];
}

- (void)setIsMaxYMarginOn:(NSNumber *)newValue
{
    [self setBit:NSViewMaxYMargin to:[newValue boolValue]];
    
    NSAssert([self.isMaxYMarginOn boolValue] == [newValue boolValue], @"Oops!!!");
}

@end
