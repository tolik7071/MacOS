//
//  MyPreview.m
//  InscribeRectangle
//
//  Created by Anatoliy Goodz on 1/5/18.
//  Copyright © 2018 Anatoliy Goodz. All rights reserved.
//

#import "MyPreview.h"

const CGFloat kRadius = 10.0;

@implementation MyPreview

- (NSRect)boundingFrame
{
    return NSInsetRect(self.bounds, 50.0, 50.0);
}

- (NSRect)inscribedFrame
{
    return NSMakeRect(
        [self boundingFrame].origin.x + NSWidth([self boundingFrame]) / 2.0 - self.inscribedRectSize.width / 2.0,
        [self boundingFrame].origin.y + NSHeight([self boundingFrame]) / 2.0  - self.inscribedRectSize.height / 2.0,
        self.inscribedRectSize.width,
        self.inscribedRectSize.height);
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    {
        NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:[self inscribedFrame] xRadius:kRadius yRadius:kRadius];
        [[NSColor yellowColor] setStroke];
        [path setLineWidth:5.0];
        [path stroke];
    }
    
    {
        NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:[self boundingFrame] xRadius:kRadius yRadius:kRadius];
        [[NSColor blackColor] setStroke];
        [path setLineWidth:5.0];
        [path stroke];
    }

/*
    {
        NSBezierPath *path = [NSBezierPath bezierPath];
        [[NSColor redColor] setStroke];
        [path setLineWidth:10.0];
        [path moveToPoint:NSMakePoint(0.0, 0.0)];
        [path lineToPoint:NSMakePoint(100.0, 100.0)];
        [path stroke];
    }
 */
}

- (void)inscribe
{
    /*
     
     1. Rect exactly inside frame
     2. Rect's width is greater than frame's width
     3. Rect's height is greater than frame's height
     4. Both width and height are outside of frame bounds
     
     */
    
#if 0
    
    if (self.inscribedRectSize.width <= [self boundingFrame].size.width &&
        self.inscribedRectSize.height <= [self boundingFrame].size.height)
    // Case #1
    {
        // do nothing
    }
    else if (self.inscribedRectSize.width > [self boundingFrame].size.width &&
        self.inscribedRectSize.height <= [self boundingFrame].size.height)
    // Case #2
    {
        CGFloat scale = [self boundingFrame].size.width / self.inscribedRectSize.width;
        self.inscribedRectSize = NSMakeSize(self.inscribedRectSize.width * scale, self.inscribedRectSize.height * scale);
        assert(self.inscribedRectSize.width / self.inscribedRectSize.height == 300.0 / 200.0);
    }
    else if (self.inscribedRectSize.width <= [self boundingFrame].size.width &&
        self.inscribedRectSize.height > [self boundingFrame].size.height)
    // Case #3
    {
        CGFloat scale = [self boundingFrame].size.height / self.inscribedRectSize.height;
        self.inscribedRectSize = NSMakeSize(self.inscribedRectSize.width * scale, self.inscribedRectSize.height * scale);
        assert(self.inscribedRectSize.width / self.inscribedRectSize.height == 300.0 / 200.0);
    }
    else if (self.inscribedRectSize.width > [self boundingFrame].size.width &&
             self.inscribedRectSize.height > [self boundingFrame].size.height)
    // Case #4
    {
        CGFloat scale = MIN([self boundingFrame].size.width / self.inscribedRectSize.width,
                            [self boundingFrame].size.height / self.inscribedRectSize.height);
        self.inscribedRectSize = NSMakeSize(self.inscribedRectSize.width * scale, self.inscribedRectSize.height * scale);
        assert(self.inscribedRectSize.width / self.inscribedRectSize.height == 300.0 / 200.0);
    }
    
#else
    
    if (!(self.inscribedRectSize.width <= [self boundingFrame].size.width &&
        self.inscribedRectSize.height <= [self boundingFrame].size.height))
    {
        CGFloat scale = MIN([self boundingFrame].size.width / self.inscribedRectSize.width,
                            [self boundingFrame].size.height / self.inscribedRectSize.height);
        self.inscribedRectSize = NSMakeSize(self.inscribedRectSize.width * scale, self.inscribedRectSize.height * scale);
        assert(self.inscribedRectSize.width / self.inscribedRectSize.height == 1.0);
    }
    
#endif // 0
    
    [self setNeedsDisplay:YES];
}

@end
