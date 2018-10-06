//
//  FTFSecondaryItemView.m
//  FTFSidebar
//
//  Created by Anatoliy Goodz on 10/3/18.
//  Copyright © 2018 Anatoliy Goodz. All rights reserved.
//

#import "FTFSecondaryItemView.h"
#import "FTFSidebarVisualAttributesManager.h"
#import "FTFTableCellView.h"
#import "FTFSidebarButtonCell.h"
#import "FTFSecondaryPlaceholderView.h"

@interface FTFSecondaryItemView ()

@property (nonatomic) NSButton * toggleButton;

@end

@implementation FTFSecondaryItemView

- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        _toggleButton = [[NSButton alloc] initWithFrame:
            [[self class] toggleButtonFrameForParentFrame:frame]];
        [self addSubview:_toggleButton];
        
        _contentPlaceholder = [[FTFSecondaryPlaceholderView alloc] initWithFrame:
            [[self class] placeholderViewFrameForParentFrame:frame]];
        [self addSubview:_contentPlaceholder];
        
        [self setupControls];
    }
    
    return self;
}

- (void)setupControls
{
    assert(_toggleButton && _contentPlaceholder);
    
/*
    
//    self.autoresizingMask =
//        NSViewMinXMargin |
//        NSViewWidthSizable |
//        NSViewMaxXMargin |
//        NSViewMinYMargin |
//        NSViewHeightSizable |
//        NSViewMaxYMargin;
    
    _toggleButton.autoresizingMask =
        NSViewMinXMargin |
        NSViewWidthSizable |
        NSViewMaxXMargin |
        NSViewMinYMargin |
//        NSViewHeightSizable |
        NSViewMaxYMargin;
    
    _contentPlaceholder.autoresizingMask =
        NSViewMinXMargin |
        NSViewWidthSizable |
        NSViewMaxXMargin |
        NSViewMinYMargin |
        NSViewHeightSizable |
        NSViewMaxYMargin;
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint
        constraintWithItem:_toggleButton
        attribute:NSLayoutAttributeLeading
        relatedBy:NSLayoutRelationEqual
        toItem:self
        attribute:NSLayoutAttributeLeading
        multiplier:1.0
        constant:0.0];
    [self addConstraint:constraint];
    
    constraint = [NSLayoutConstraint
        constraintWithItem:_toggleButton
        attribute:NSLayoutAttributeTop
        relatedBy:NSLayoutRelationEqual
        toItem:self
        attribute:NSLayoutAttributeTop
        multiplier:1.0
        constant:0.0];
    [self addConstraint:constraint];
    
    constraint = [NSLayoutConstraint
        constraintWithItem:_toggleButton
        attribute:NSLayoutAttributeTrailing
        relatedBy:NSLayoutRelationEqual
        toItem:self
        attribute:NSLayoutAttributeTrailing
        multiplier:1.0
        constant:0.0];
    [self addConstraint:constraint];
    
    constraint = [NSLayoutConstraint
        constraintWithItem:_toggleButton
        attribute:NSLayoutAttributeHeight
        relatedBy:NSLayoutRelationEqual
        toItem:nil
        attribute:NSLayoutAttributeNotAnAttribute
        multiplier:1.0
        constant:[[FTFSidebarVisualAttributesManager sharedManager] secondaryButtonHeight]];
    [_toggleButton addConstraint:constraint];
    
    constraint = [NSLayoutConstraint
        constraintWithItem:_contentPlaceholder
        attribute:NSLayoutAttributeLeading
        relatedBy:NSLayoutRelationEqual
        toItem:self
        attribute:NSLayoutAttributeLeading
        multiplier:1.0
        constant:0.0];
    [self addConstraint:constraint];
    
    constraint = [NSLayoutConstraint
        constraintWithItem:_contentPlaceholder
        attribute:NSLayoutAttributeTop
        relatedBy:NSLayoutRelationEqual
        toItem:_toggleButton
        attribute:NSLayoutAttributeBottom
        multiplier:1.0
        constant:2.0];
    [self addConstraint:constraint];
    
    constraint = [NSLayoutConstraint
        constraintWithItem:_contentPlaceholder
        attribute:NSLayoutAttributeTrailing
        relatedBy:NSLayoutRelationEqual
        toItem:self
        attribute:NSLayoutAttributeTrailing
        multiplier:1.0
        constant:0.0];
    [self addConstraint:constraint];
    
    constraint = [NSLayoutConstraint
        constraintWithItem:_contentPlaceholder
        attribute:NSLayoutAttributeBottom
        relatedBy:NSLayoutRelationEqual
        toItem:self
        attribute:NSLayoutAttributeBottom
        multiplier:1.0
        constant:0.0];
    [self addConstraint:constraint];
 
 */
    
    _toggleButton.bezelStyle = NSBezelStyleTexturedRounded;
    [_toggleButton setButtonType:NSButtonTypeMomentaryPushIn];
    _toggleButton.bordered = NO;
    
    FTFSidebarButtonCell *buttonCell = [[FTFSidebarButtonCell alloc] initImageCell:
        [FTFSidebarVisualAttributesManager imageOfSize:NSMakeSize(1.0, 45.0)
            color:[[FTFSidebarVisualAttributesManager sharedManager] itemBackground]]];
    
    _toggleButton.cell = buttonCell;
    _toggleButton.imagePosition = NSImageOverlaps;
    _toggleButton.imageScaling = NSImageScaleAxesIndependently;
    
    _toggleButton.state = NSOnState;
    
    _toggleButton.target = self;
    _toggleButton.action = @selector(hideOrShowContent:);
}

+ (NSRect)placeholderViewFrameForParentFrame:(NSRect)parentFrame
{
    FTFSidebarVisualAttributesManager *manager = [FTFSidebarVisualAttributesManager sharedManager];
    
     NSRect frame =
    {
        {
            0,
            [manager secondaryButtonHeight] + 2.0
        },
        {
            parentFrame.size.width,
            parentFrame.size.height - [manager secondaryButtonHeight] - 2.0
        }
    };
    
    return frame;
}

+ (NSRect)toggleButtonFrameForParentFrame:(NSRect)parentFrame
{
    NSRect frame =
    {
        {
            0,
            0
        },
        {
            parentFrame.size.width,
            [[FTFSidebarVisualAttributesManager sharedManager] secondaryButtonHeight]
        }
    };
    
    return frame;
}

//- (void)drawRect:(NSRect)dirtyRect
//{
//    [super drawRect:dirtyRect];
//
//    [[NSColor redColor] setStroke];
//    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(self.bounds, 3.0, 3.0) xRadius:3.0 yRadius:3.0];
//    [path stroke];
//}

- (BOOL)isFlipped
{
    return YES;
}

+ (NSSet<NSString *> *)keyPathsForValuesAffectingIsExpanded
{
    return [NSSet setWithObjects:@"contentPlaceholder.hidden", nil];
}

- (BOOL)isExpanded
{
    return !self.contentPlaceholder.hidden;
}

- (IBAction)hideOrShowContent:(id)sender
{
    self.contentPlaceholder.hidden = !self.contentPlaceholder.hidden;
 
    FTFSidebarVisualAttributesManager *manager = [FTFSidebarVisualAttributesManager sharedManager];
    
    NSSize frameSize =
    {
        self.frame.size.width,
        [manager secondaryButtonHeight]
            + (self.contentPlaceholder.hidden ? 0 : 2.0 + self.contentPlaceholder.frame.size.height)
    };
    
    [self setFrameSize:frameSize];
    
    [self.parentCellView.tableView noteHeightOfRowsWithIndexesChanged:
        [NSIndexSet indexSetWithIndex:[self.parentCellView.tableView rowForView:self]]];
}

- (void)setTitle:(NSString *)title
{
    if (title)
    {
        FTFSidebarVisualAttributesManager *manager = [FTFSidebarVisualAttributesManager sharedManager];
        
        self.toggleButton.attributedTitle = [manager
            attributedStringForString:title
            foregroundColor:[manager textColorOfSecondaryItem]
            font:[manager fontOfSecondaryItem]];
    }
}

@end
