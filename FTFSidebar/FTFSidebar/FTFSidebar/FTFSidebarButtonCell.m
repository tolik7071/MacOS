//
//  FTFSidebarButtonCell.m
//  FTFSidebar
//
//  Created by Anatoliy Goodz on 9/27/18.
//  Copyright © 2018 Anatoliy Goodz. All rights reserved.
//

#import "FTFSidebarButtonCell.h"
#import "FTFSidebarVisualAttributesManager.h"

const CGFloat kSinOf60Deg = 0.6;

@implementation FTFSidebarButtonCell

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    
    if (self)
    {
        self.highlightsBy = NSNoCellMask;
    }
    
    return self;
}

- (instancetype)initImageCell:(NSImage *)image
{
    self = [super initImageCell:image];
    
    if (self)
    {
        self.highlightsBy = NSNoCellMask;
    }
    
    return self;
}

- (void)drawImage:(NSImage*)image withFrame:(NSRect)frame inView:(NSView*)controlView
{
    NSRect rectForDraw = NSInsetRect(frame, -2.0, -2.0);
    [super drawImage:image withFrame:rectForDraw inView:controlView];
}

- (NSRect)drawTitle:(NSAttributedString*)title withFrame:(NSRect)frame inView:(NSView*)controlView
{
    NSRect bounds = [super drawTitle:[self fixedAttributesForString:title] withFrame:frame inView:controlView];
    
    [self drawArrowheadInBounds:[self boundsOfArrowheadUsignFrame:bounds]];
    
    return bounds;
}

- (void)drawBezelWithFrame:(NSRect)frame inView:(NSView*)controlView
{
    FTFSidebarVisualAttributesManager *manager = [FTFSidebarVisualAttributesManager sharedManager];
    
    if (self.isPrimary)
    {
        [[manager primaryButtonBorderColor] setFill];
        NSRectFill(frame);
    }
    else
    {
        [[manager secondaryButtonBorderColor] setFill];
        NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:frame xRadius:3.0 yRadius:3.0];
        [path fill];
    }
}

#pragma mark -

- (void)drawArrowheadInBounds:(NSRect)bounds
{
    FTFSidebarVisualAttributesManager *manager = [FTFSidebarVisualAttributesManager sharedManager];
    
    NSBezierPath *path = [NSBezierPath bezierPath];
    
    if (self.state == NSControlStateValueOn && self.isPrimary)
    {
        [[manager textColorOfActivePrimaryItem] setStroke];
    }
    else
    {
        [[manager textColorOfSecondaryItem] setStroke];
    }
    
    if (self.state == NSControlStateValueOn)
    {
        [path moveToPoint:NSMakePoint(NSMinX(bounds), NSMaxY(bounds))];
        [path lineToPoint:NSMakePoint(NSMidX(bounds), NSMinY(bounds))];
        [path lineToPoint:NSMakePoint(NSMaxX(bounds), NSMaxY(bounds))];
    }
    else
    {
        [path moveToPoint:NSMakePoint(NSMinX(bounds), NSMinY(bounds))];
        [path lineToPoint:NSMakePoint(NSMidX(bounds), NSMaxY(bounds))];
        [path lineToPoint:NSMakePoint(NSMaxX(bounds), NSMinY(bounds))];
    }
    
    [path setLineWidth:2.0];
    
    [path stroke];
}

- (NSRect)boundsOfArrowheadUsignFrame:(NSRect)frame
{
    FTFSidebarVisualAttributesManager *manager = [FTFSidebarVisualAttributesManager sharedManager];
    
    NSFont *font = [self.attributedTitle attributesAtIndex:0
        effectiveRange:nil][NSFontAttributeName];
    
    CGFloat height = font.capHeight;
    CGFloat side = height / kSinOf60Deg;
    
    NSRect bounds =
    {
        {
            NSMaxX(frame) - side - [manager primaryItemPadding],
            NSMaxY(frame) - font.ascender
        },
        {
            side,
            height
        }
    };
    
    return bounds;
}

- (NSAttributedString *)fixedAttributesForString:(NSAttributedString *)string
{
    NSMutableAttributedString *result = [[NSMutableAttributedString alloc] initWithAttributedString:string];
    
    FTFSidebarVisualAttributesManager *manager = [FTFSidebarVisualAttributesManager sharedManager];
    
    if (self.isPrimary)
    {
        [result addAttributes:
            @{
              NSForegroundColorAttributeName :
                  (self.state == NSControlStateValueOn ?
                       manager.textColorOfActivePrimaryItem : manager.textColorOfInactivePrimaryItem)
             }
        range:NSMakeRange(0, string.length)];
    }
    else
    {
        [result addAttributes:
            @{
                NSForegroundColorAttributeName : manager.textColorOfSecondaryItem
             }
        range:NSMakeRange(0, string.length)];
    }
    
    return result;
}

@end
