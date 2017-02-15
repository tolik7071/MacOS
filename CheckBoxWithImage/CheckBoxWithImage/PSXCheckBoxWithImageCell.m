//
//  PSXCheckBoxWithImageCell.m
//  CheckBoxWithImage
//
//  Created by Anatoliy Goodz on 9/27/16.
//  Copyright © 2016 Anatoliy Goodz. All rights reserved.
//

#import "PSXCheckBoxWithImageCell.h"

@implementation PSXCheckboxWithImageCell

+ (CGFloat)PSX_contentMargin
{
    return 5.0;
}

+ (CGFloat)PSX_cornerRadius
{
    return 5.0;
}

- (void)drawImage:(NSImage*)image withFrame:(NSRect)frame inView:(NSView*)controlView
{
    CGPoint origin = CGPointMake(
        [PSXCheckboxWithImageCell PSX_contentMargin],
        [PSXCheckboxWithImageCell PSX_contentMargin]);
    frame.origin = origin;
    
    [super drawImage:image withFrame:frame inView:controlView];
}

- (NSRect)drawTitle:(NSAttributedString*)title withFrame:(NSRect)frame inView:(NSView*)controlView
{
    frame.origin.y = [PSXCheckboxWithImageCell PSX_contentMargin];
    frame.origin.x += [PSXCheckboxWithImageCell PSX_contentMargin];
    
    return [super drawTitle:title withFrame:frame inView:controlView];
}

- (void)drawBezelWithFrame:(NSRect)frame inView:(NSView*)controlView
{
    // draw border only for 'CHECKED' state
    if (self.state == NSOnState)
    {
        CGFloat xRadius = [PSXCheckboxWithImageCell PSX_cornerRadius];
        CGFloat yRadius = [PSXCheckboxWithImageCell PSX_cornerRadius];
        
        NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:frame
            xRadius:xRadius yRadius:yRadius];
        
        [[NSColor selectedControlColor] setFill];
        
        [path fill];
    }
}

- (NSCellHitResult)hitTestForEvent:(NSEvent *)event inRect:(NSRect)cellFrame ofView:(NSView *)controlView
{
    CGPoint location = [event locationInWindow];
    location = [controlView convertPoint:location fromView:nil];
    
    NSCellHitResult result = CGRectContainsPoint(cellFrame, location)
    ? NSCellHitTrackableArea : NSCellHitNone;
    
    return result;
}

- (BOOL)isBordered
{
    return YES;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    [super drawWithFrame:cellFrame inView:controlView];
    
    if (self.thumbnailImage != nil)
    {
        CGFloat dx = [PSXCheckboxWithImageCell PSX_contentMargin];
        CGFloat dy = [PSXCheckboxWithImageCell PSX_contentMargin];
        CGRect drawingRect = CGRectInset(cellFrame, dx, dy);
        
        NSRect imageRect = [self imageRectForBounds:cellFrame];
        NSRect titleRect = [self titleRectForBounds:cellFrame];
        
        CGFloat maxHeight = MAX(imageRect.size.height, titleRect.size.height);
        
        drawingRect.origin.y += (maxHeight + dy);
        drawingRect.size.height -= (maxHeight + dy);
        
        if (drawingRect.size.height <= 0 || drawingRect.size.width <= 0)
        {
            // no room to draw
            return;
        }
        
        [[NSGraphicsContext currentContext] saveGraphicsState];
        
        CGFloat xRadius = [PSXCheckboxWithImageCell PSX_cornerRadius];
        CGFloat yRadius = [PSXCheckboxWithImageCell PSX_cornerRadius];
        
        NSBezierPath *clipping = [NSBezierPath bezierPathWithRoundedRect:drawingRect
            xRadius:xRadius yRadius:yRadius];
        [clipping addClip];
        
        // use white color by default
        NSColor *background = (self.backgroundColor == nil)
            ? [NSColor whiteColor] : self.backgroundColor;
        [background setFill];
        NSRectFill(drawingRect);
        
        NSImageCell *cell = [[NSImageCell alloc] initImageCell:self.thumbnailImage];
        cell.imageAlignment = NSImageAlignCenter;
        cell.imageScaling = NSImageScaleProportionallyUpOrDown;
        cell.imageFrameStyle = NSImageFrameNone;
        cell.enabled = self.enabled;
        
        [cell drawWithFrame:drawingRect inView:controlView];
        
        [[NSGraphicsContext currentContext] restoreGraphicsState];
    }
}

@end
