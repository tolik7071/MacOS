//
//  TestView.m
//  AutoresizeMaskTest
//
//  Created by Anatoliy Goodz on 5/18/16.
//  Copyright © 2016 Anatoliy Goodz. All rights reserved.
//

#import "TestView.h"

@implementation TestView

- (void)drawRect:(NSRect)dirtyRect
{
    NSImage *image = [NSImage imageNamed:([self.superview isFlipped] ? @"flipped.png" : @"not_flipped.png")];
    [image drawInRect:self.bounds];
    
    [[NSColor redColor] set];
    NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect:
        NSMakeRect(0.0, 0.0, 20.0, 20.0)];
    [path fill];
}

@end
