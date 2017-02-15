//
//  BackgroundView.m
//  TwoViews
//
//  Created by Anatoliy Goodz on 5/30/16.
//  Copyright © 2016 Anatoliy Goodz. All rights reserved.
//

#import "BackgroundView.h"

#define LINE_WIDTH 20.0

@implementation BackgroundView

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    [[NSColor yellowColor] set];
    NSRectFill(self.bounds);
    
    [[NSColor redColor] set];
    
    NSBezierPath *path1 = [NSBezierPath bezierPath];
    [path1 setLineWidth:LINE_WIDTH];
    [path1 moveToPoint:NSMakePoint(
        0.0,
        NSHeight(self.bounds) / 2.0)];
    [path1 lineToPoint:NSMakePoint(
        NSMaxX(self.bounds),
        NSHeight(self.bounds) / 2.0)];
    [path1 stroke];
    
    NSBezierPath *path2 = [NSBezierPath bezierPathWithOvalInRect:
        NSMakeRect(0.0, 0.0, 20.0, 20.0)];
    [path2 fill];
}

- (BOOL)isFlipped
{
    return NO;
}

@end
