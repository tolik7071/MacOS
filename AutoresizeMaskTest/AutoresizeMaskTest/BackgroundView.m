//
//  BackgroundView.m
//  AutoresizeMaskTest
//
//  Created by Anatoliy Goodz on 5/30/16.
//  Copyright © 2016 Anatoliy Goodz. All rights reserved.
//

#import "BackgroundView.h"

@implementation BackgroundView
{
    BOOL _viewIsFlipped;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    [[NSColor yellowColor] set];
    NSRectFill(self.bounds);
    
    [[NSColor redColor] set];
    NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect:
        NSMakeRect(0.0, 0.0, 20.0, 20.0)];
    [path fill];
}

- (BOOL)viewIsFlipped
{
    return self.flipped;
}

- (void)setViewIsFlipped:(BOOL)aFlag
{
    _viewIsFlipped = aFlag;
    
    [self setNeedsLayout:YES];
    [self setNeedsDisplay:YES];
    [[self.subviews firstObject] setNeedsDisplay:YES];
}

- (BOOL)isFlipped
{
    return _viewIsFlipped;
}

@end
