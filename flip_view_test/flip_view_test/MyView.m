//
//  MyView.m
//  flip_view_test
//
//  Created by Anatoliy Goodz on 9/4/18.
//  Copyright © 2018 Anatoliy Goodz. All rights reserved.
//

#import "MyView.h"

@implementation MyView

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    [[NSColor yellowColor] setFill];
    NSRectFill(dirtyRect);
    
    NSBezierPath *rectPath = [NSBezierPath bezierPathWithRect:NSMakeRect(10, 10, 200, 100)];
    [rectPath setLineWidth:2.0];
    [rectPath stroke];
    
    NSBezierPath *circlePath = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(5, 5, 10, 10)];
    [[NSColor redColor] setFill];
    [circlePath fill];
    
    [[NSColor redColor] setStroke];
    NSBezierPath *rect2Path = [NSBezierPath bezierPathWithRect:NSInsetRect(NSMakeRect(10, 10, 200, 100), -10, -10)];
    [rect2Path setLineWidth:1.0];
    [rect2Path stroke];
}

- (BOOL)isFlipped
{
    return self.shouldBeFlipped;
}

@end
