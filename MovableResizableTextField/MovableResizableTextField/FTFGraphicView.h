//
//  MyGraphicView.h
//  MovableResizableTextField
//
//  Created by Anatoliy Goodz on 7/24/18.
//  Copyright © 2018 Anatoliy Goodz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString *FTFGraphicViewGraphicsBindingName;
extern NSString *FTFGraphicViewSelectionIndexesBindingName;
extern NSString *FTFGraphicViewGridBindingName;

typedef enum : NSUInteger
{
    FTFSelectGraphicToolTag,
    FTFTextGraphicToolTag,
    FTFLineGraphicToolTag
} FTFGraphicToolIDs;

@protocol FTFGraphicToolsSelection

- (FTFGraphicToolIDs)selectedGraphic;

@end

@interface FTFGraphicView : NSView

- (IBAction)makeNaturalSize:(id)sender;
- (IBAction)makeSameHeight:(id)sender;
- (IBAction)makeSameWidth:(id)sender;

- (NSArray *)selectedGraphics;

@property (nonatomic, weak) id<FTFGraphicToolsSelection> graphicSelectionSource;

@end
