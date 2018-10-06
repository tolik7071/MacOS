//
//  FTFSidebarVisualAttributesManager.h
//  FTFSidebar
//
//  Created by Anatoliy Goodz on 9/27/18.
//  Copyright © 2018 Anatoliy Goodz. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface FTFSidebarVisualAttributesManager : NSObject

+ (instancetype)sharedManager;

@property (nonatomic) NSColor * background;

@property (nonatomic) NSImage * primaryButtonBackground;
@property (nonatomic) NSColor * itemBackground;
@property (nonatomic) NSFont * fontOfPrimaryItem;
@property (nonatomic) NSColor * textColorOfActivePrimaryItem;
@property (nonatomic) NSColor * textColorOfInactivePrimaryItem;
@property (nonatomic) NSColor * primaryButtonBorderColor;

@property (nonatomic) NSImage * secondaryButtonBackground;
@property (nonatomic) NSColor * textColorOfSecondaryItem;
@property (nonatomic) NSFont * fontOfSecondaryItem;
@property (nonatomic) NSColor * secondaryButtonBorderColor;

@property (nonatomic) CGFloat primaryButtonHeight;
@property (nonatomic) CGFloat secondaryButtonHeight;

@property (nonatomic) CGFloat primaryItemPadding;
@property (nonatomic) CGFloat secondaryItemPadding;

- (NSAttributedString *)attributedStringForString:(NSString *)string
    foregroundColor:(NSColor *)foregroundColor
    font:(NSFont *)font;

+ (NSImage *)imageOfSize:(NSSize)size color:(NSColor *)background;

@end
