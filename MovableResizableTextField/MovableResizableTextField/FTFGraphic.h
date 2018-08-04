//
//  FTFGraphic.h
//  MovableResizableTextField
//
//  Created by Anatoliy Goodz on 7/26/18.
//  Copyright © 2018 Anatoliy Goodz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString *FTFGraphicCanSetDrawingFillKey;
extern NSString *FTFGraphicCanSetDrawingStrokeKey;
extern NSString *FTFGraphicIsDrawingFillKey;
extern NSString *FTFGraphicFillColorKey;
extern NSString *FTFGraphicIsDrawingStrokeKey;
extern NSString *FTFGraphicStrokeColorKey;
extern NSString *FTFGraphicStrokeWidthKey;
extern NSString *FTFGraphicXPositionKey;
extern NSString *FTFGraphicYPositionKey;
extern NSString *FTFGraphicWidthKey;
extern NSString *FTFGraphicHeightKey;
extern NSString *FTFGraphicBoundsKey;
extern NSString *FTFGraphicDrawingBoundsKey;
extern NSString *FTFGraphicDrawingContentsKey;
extern NSString *FTFGraphicKeysForValuesToObserveForUndoKey;

extern const NSInteger SKTGraphicNoHandle;

enum
{
    FTFGraphicUpperLeftHandle = 1,
    FTFGraphicUpperMiddleHandle = 2,
    FTFGraphicUpperRightHandle = 3,
    FTFGraphicMiddleLeftHandle = 4,
    FTFGraphicMiddleRightHandle = 5,
    FTFGraphicLowerLeftHandle = 6,
    FTFGraphicLowerMiddleHandle = 7,
    FTFGraphicLowerRightHandle = 8,
};

extern CGFloat FTFGraphicHandleWidth;
extern CGFloat FTFGraphicHandleHalfWidth;

@interface FTFGraphic : NSObject

- (BOOL)isDrawingFill;
- (NSColor *)fillColor;
- (BOOL)isDrawingStroke;
- (NSColor *)strokeColor;
- (CGFloat)strokeWidth;
- (NSRect)drawingBounds;
- (void)drawContentsInView:(NSView *)view isBeingCreateOrEdited:(BOOL)isBeingCreatedOrEditing;
- (void)drawHandlesInView:(NSView *)view;
- (void)drawHandleInView:(NSView *)view atPoint:(NSPoint)point;
- (void)finalizeEditingView:(NSView *)editingView;
- (NSInteger)handleUnderPoint:(NSPoint)point;
- (BOOL)isContentsUnderPoint:(NSPoint)point;
- (void)setBounds:(NSRect)bounds;
- (NSRect)bounds;
- (void)setColor:(NSColor *)color;
- (NSView *)newEditingViewWithSuperviewBounds:(NSRect)superviewBounds;
- (BOOL)isHandleAtPoint:(NSPoint)handlePoint underPoint:(NSPoint)point;
- (NSInteger)resizeByMovingHandle:(NSInteger)handle toPoint:(NSPoint)point;

+ (NSRect)boundsOfGraphics:(NSArray *)graphics;
+ (void)translateGraphics:(NSArray *)graphics byX:(CGFloat)deltaX y:(CGFloat)deltaY;
+ (NSRect)drawingBoundsOfGraphics:(NSArray *)graphics;
+ (NSInteger)creationSizingHandle;

@end
