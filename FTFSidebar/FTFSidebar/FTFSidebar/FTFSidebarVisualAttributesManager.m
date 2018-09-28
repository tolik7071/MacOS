//
//  FTFSidebarVisualAttributesManager.m
//  FTFSidebar
//
//  Created by Anatoliy Goodz on 9/27/18.
//  Copyright © 2018 Anatoliy Goodz. All rights reserved.
//

#import "FTFSidebarVisualAttributesManager.h"

@implementation FTFSidebarVisualAttributesManager

+ (instancetype)sharedManager
{
    static FTFSidebarVisualAttributesManager *sManager = nil;
    
    if (!sManager)
    {
        sManager = [[FTFSidebarVisualAttributesManager alloc] init];
    }
    
    return sManager;
}

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        _primaryButtonHeight = INFINITY;
        _secondaryButtonHeight = INFINITY;
        _primaryItemPadding = INFINITY;
        _secondaryItemPadding = INFINITY;
    }
    
    return self;
}

- (NSColor *)background
{
    if (!_background)
    {
        _background = [NSColor colorWithRed:(54.0 / 255.0)
                                      green:(56.0 / 255.0)
                                       blue:(58.0 / 255.0)
                                      alpha:1.0];
    }
    
    return _background;
}

- (NSImage *)primaryButtonBackground
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *url = [bundle URLForImageResource:@"primary_button_background.png"];
    NSImage *image = [[NSImage alloc] initByReferencingURL:url];
    
    return image;
}

- (NSColor *)itemBackground
{
    if (!_itemBackground)
    {
        _itemBackground = [NSColor colorWithRed:(64.0 / 255.0)
                                          green:(66.0 / 255.0)
                                           blue:(68.0 / 255.0)
                                          alpha:1.0];
    }
    
    return _itemBackground;
}

- (NSColor *)textColorOfActivePrimaryItem
{
    if(!_textColorOfActivePrimaryItem)
    {
        _textColorOfActivePrimaryItem = [NSColor colorWithRed:(255.0 / 255.0)
                                                        green:(204.0 / 255.0)
                                                         blue:(107.0 / 255.0)
                                                        alpha:1.0];
    }
    
    return _textColorOfActivePrimaryItem;
}

- (NSFont *)fontOfPrimaryItem
{
    if (!_fontOfPrimaryItem)
    {
        _fontOfPrimaryItem = [NSFont systemFontOfSize:18.0];
    }
    
    return _fontOfPrimaryItem;
}

- (NSColor *)textColorOfInactivePrimaryItem
{
    if (!_textColorOfInactivePrimaryItem)
    {
        _textColorOfInactivePrimaryItem = [NSColor colorWithRed:(234.0 / 255.0)
                                                          green:(234.0 / 255.0)
                                                           blue:(234.0 / 255.0)
                                                          alpha:1.0];
    }
    
    return _textColorOfInactivePrimaryItem;
}

- (NSImage *)secondaryButtonBackground
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *url = [bundle URLForImageResource:@"secondary_button_background.png"];
    NSImage *image = [[NSImage alloc] initByReferencingURL:url];
    
    return image;
}

- (NSColor *)textColorOfSecondaryItem
{
    if (!_textColorOfSecondaryItem)
    {
        _textColorOfSecondaryItem = [NSColor colorWithRed:(156.0 / 255.0)
                                                    green:(157.0 / 255.0)
                                                     blue:(158.0 / 255.0)
                                                    alpha:1.0];
    }
    
    return _textColorOfSecondaryItem;
}

- (NSFont *)fontOfSecondaryItem
{
    if (!_fontOfSecondaryItem)
    {
        _fontOfSecondaryItem = [NSFont systemFontOfSize:18.0];
    }
    
    return _fontOfSecondaryItem;
}

- (CGFloat)primaryButtonHeight
{
    if (isinf(_primaryButtonHeight))
    {
        _primaryButtonHeight = 60.0;
    }
    
    return _primaryButtonHeight;
}

- (CGFloat)secondaryButtonHeight
{
    if (isinf(_secondaryButtonHeight))
    {
        _secondaryButtonHeight = 45.0;
    }
    
    return _secondaryButtonHeight;
}

- (CGFloat)primaryItemPadding
{
    if (isinf(_primaryItemPadding))
    {
        _primaryItemPadding = 20.0;
    }
    
    return _primaryItemPadding;
}

- (CGFloat)secondaryItemPadding
{
    if (isinf(_secondaryItemPadding))
    {
        _secondaryItemPadding = 0.0;
    }
    
    return _secondaryItemPadding;
}

- (NSAttributedString *)attributedStringForString:(NSString *)string
                                  foregroundColor:(NSColor *)foregroundColor
                                             font:(NSFont *)font
{
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.alignment = NSTextAlignmentCenter;
    
    NSAttributedString *result = [[NSAttributedString alloc] initWithString:string
        attributes:
        @{
            NSForegroundColorAttributeName : foregroundColor,
            NSFontAttributeName : font,
            NSParagraphStyleAttributeName : paragraph
        }
    ];
    
    return result;
}

- (NSColor *)primaryButtonBorderColor
{
    if (!_primaryButtonBorderColor)
    {
        _primaryButtonBorderColor = [NSColor blackColor];
    }
    
    return _primaryButtonBorderColor;
}

- (NSColor *)secondaryButtonBorderColor
{
    if (!_secondaryButtonBorderColor)
    {
        _secondaryButtonBorderColor = [self itemBackground];
    }
    
    return _secondaryButtonBorderColor;
}

@end
