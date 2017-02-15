//
//  ChildView.m
//  TwoViews
//
//  Created by Anatoliy Goodz on 5/30/16.
//  Copyright © 2016 Anatoliy Goodz. All rights reserved.
//

#import "ChildView.h"

@implementation ChildView

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    [[NSColor blueColor] set];
    NSRectFill(self.bounds);
    
    [[NSColor redColor] set];
    NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect:
        NSMakeRect(0.0, 0.0, 20.0, 20.0)];
    [path fill];
}

- (BOOL)isFlipped
{
    return YES;
}

@end
