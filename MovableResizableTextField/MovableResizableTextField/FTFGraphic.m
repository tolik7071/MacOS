//
//  FTFGraphic.m
//  MovableResizableTextField
//
//  Created by Anatoliy Goodz on 7/26/18.
//  Copyright © 2018 Anatoliy Goodz. All rights reserved.
//

#import "FTFGraphic.h"

NSString *FTFGraphicCanSetDrawingFillKey = @"canSetDrawingFill";
NSString *FTFGraphicCanSetDrawingStrokeKey = @"canSetDrawingStroke";
NSString *FTFGraphicIsDrawingFillKey = @"drawingFill";
NSString *FTFGraphicFillColorKey = @"fillColor";
NSString *FTFGraphicIsDrawingStrokeKey = @"drawingStroke";
NSString *FTFGraphicStrokeColorKey = @"strokeColor";
NSString *FTFGraphicStrokeWidthKey = @"strokeWidth";
NSString *FTFGraphicXPositionKey = @"xPosition";
NSString *FTFGraphicYPositionKey = @"yPosition";
NSString *FTFGraphicWidthKey = @"width";
NSString *FTFGraphicHeightKey = @"height";
NSString *FTFGraphicBoundsKey = @"bounds";
NSString *FTFGraphicDrawingBoundsKey = @"drawingBounds";
NSString *FTFGraphicDrawingContentsKey = @"drawingContents";
NSString *FTFGraphicKeysForValuesToObserveForUndoKey = @"keysForValuesToObserveForUndo";

const NSInteger FTFGraphicNoHandle = 0;

static NSString *FTFGraphicClassNameKey = @"className";

CGFloat FTFGraphicHandleWidth = 6.0f;
CGFloat FTFGraphicHandleHalfWidth = 6.0f / 2.0f;

@interface FTFGraphic ()
{
    NSRect   _bounds;
    BOOL     _isDrawingFill;
    NSColor *_fillColor;
    BOOL     _isDrawingStroke;
    NSColor *_strokeColor;
    CGFloat  _strokeWidth;
}

@end

@implementation FTFGraphic

- (id)init
{
    self = [super init];
    if (self)
    {
        _bounds = NSZeroRect;
        _isDrawingFill = NO;
        _fillColor = [NSColor whiteColor];
        _isDrawingStroke = YES;
        _strokeColor = [NSColor blackColor];
        _strokeWidth = 1.0f;
        
    }
    
    return self;
}

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
{
    BOOL automaticallyNotifies;
    
    if ([[NSSet setWithObjects:
          FTFGraphicXPositionKey,
          FTFGraphicYPositionKey,
          FTFGraphicWidthKey,
          FTFGraphicHeightKey,
          nil] containsObject:key])
    {
        automaticallyNotifies = NO;
    }
    else
    {
        automaticallyNotifies = [super automaticallyNotifiesObserversForKey:key];
    }
    
    return automaticallyNotifies;
}

+ (NSSet *)keyPathsForValuesAffectingXPosition
{
    return [NSSet setWithObject:FTFGraphicBoundsKey];
}

+ (NSSet *)keyPathsForValuesAffectingYPosition
{
    return [NSSet setWithObject:FTFGraphicBoundsKey];
}

+ (NSSet *)keyPathsForValuesAffectingWidth
{
    return [NSSet setWithObject:FTFGraphicBoundsKey];
}

+ (NSSet *)keyPathsForValuesAffectingHeight
{
    return [NSSet setWithObject:FTFGraphicBoundsKey];
}

- (CGFloat)xPosition
{
    return [self bounds].origin.x;
}

- (CGFloat)yPosition
{
    return [self bounds].origin.y;
}

- (CGFloat)width
{
    return [self bounds].size.width;
}

- (CGFloat)height
{
    return [self bounds].size.height;
}

- (void)setXPosition:(CGFloat)xPosition
{
    NSRect bounds = [self bounds];
    bounds.origin.x = xPosition;
    [self setBounds:bounds];
}

- (void)setYPosition:(CGFloat)yPosition
{
    NSRect bounds = [self bounds];
    bounds.origin.y = yPosition;
    [self setBounds:bounds];
}

- (void)setWidth:(CGFloat)width
{
    NSRect bounds = [self bounds];
    bounds.size.width = width;
    [self setBounds:bounds];
}

- (void)setHeight:(CGFloat)height
{
    NSRect bounds = [self bounds];
    bounds.size.height = height;
    [self setBounds:bounds];
}

+ (NSRect)boundsOfGraphics:(NSArray *)graphics
{
    __block NSRect bounds = NSZeroRect;
    
    [graphics enumerateObjectsUsingBlock:^(FTFGraphic * _Nonnull graphic, NSUInteger idx, BOOL * _Nonnull stop)
    {
        bounds = NSUnionRect(bounds, [graphic bounds]);
    }];
    
    return bounds;
}

+ (NSRect)drawingBoundsOfGraphics:(NSArray *)graphics
{
    __block NSRect drawingBounds = NSZeroRect;
    
    [graphics enumerateObjectsUsingBlock:^(FTFGraphic * _Nonnull graphic, NSUInteger idx, BOOL * _Nonnull stop)
    {
        drawingBounds = NSUnionRect(drawingBounds, [graphic drawingBounds]);
    }];
    
    return drawingBounds;
}

+ (void)translateGraphics:(NSArray *)graphics byX:(CGFloat)deltaX y:(CGFloat)deltaY
{
    [graphics enumerateObjectsUsingBlock:^(FTFGraphic * _Nonnull graphic, NSUInteger idx, BOOL * _Nonnull stop)
    {
        [graphic setBounds:NSOffsetRect([graphic bounds], deltaX, deltaY)];
    }];
}

- (NSRect)bounds
{
    return _bounds;
}

- (BOOL)isDrawingFill
{
    return _isDrawingFill;
}

- (NSColor *)fillColor
{
    return _fillColor;
}

- (BOOL)isDrawingStroke
{
    return _isDrawingStroke;
}

- (NSColor *)strokeColor
{
    return _strokeColor;
}

- (CGFloat)strokeWidth
{
    return _strokeWidth;
}

+ (NSSet *)keyPathsForValuesAffectingDrawingBounds
{
    return [NSSet setWithObjects:FTFGraphicBoundsKey, FTFGraphicStrokeWidthKey, nil];
}

+ (NSSet *)keyPathsForValuesAffectingDrawingContents
{
    return [NSSet setWithObjects:
            FTFGraphicIsDrawingFillKey,
            FTFGraphicFillColorKey,
            FTFGraphicIsDrawingStrokeKey,
            FTFGraphicStrokeColorKey,
            nil];
}

- (NSRect)drawingBounds
{
    CGFloat outset = FTFGraphicHandleHalfWidth;
    
    if ([self isDrawingStroke])
    {
        CGFloat strokeOutset = [self strokeWidth] / 2.0f;
        
        if (strokeOutset>outset)
        {
            outset = strokeOutset;
        }
    }
    
    CGFloat inset = 0.0f - outset;
    NSRect drawingBounds = NSInsetRect([self bounds], inset, inset);
    
    drawingBounds.size.width += 1.0f;
    drawingBounds.size.height += 1.0f;
    
    return drawingBounds;
}

- (void)drawContentsInView:(NSView *)view isBeingCreateOrEdited:(BOOL)isBeingCreatedOrEditing
{
    NSBezierPath *path = [self bezierPathForDrawing];
    if (path)
    {
        if ([self isDrawingFill])
        {
            [[self fillColor] set];
            [path fill];
        }
        
        if ([self isDrawingStroke])
        {
            [[self strokeColor] set];
            [path stroke];
        }
    }
}

- (NSBezierPath *)bezierPathForDrawing
{
    [self doesNotRecognizeSelector:_cmd];

    return nil;
}

- (void)drawHandlesInView:(NSView *)view
{
    NSRect bounds = [self bounds];
    
    [self drawHandleInView:view atPoint:NSMakePoint(NSMinX(bounds), NSMinY(bounds))];
    [self drawHandleInView:view atPoint:NSMakePoint(NSMidX(bounds), NSMinY(bounds))];
    [self drawHandleInView:view atPoint:NSMakePoint(NSMaxX(bounds), NSMinY(bounds))];
    [self drawHandleInView:view atPoint:NSMakePoint(NSMinX(bounds), NSMidY(bounds))];
    [self drawHandleInView:view atPoint:NSMakePoint(NSMaxX(bounds), NSMidY(bounds))];
    [self drawHandleInView:view atPoint:NSMakePoint(NSMinX(bounds), NSMaxY(bounds))];
    [self drawHandleInView:view atPoint:NSMakePoint(NSMidX(bounds), NSMaxY(bounds))];
    [self drawHandleInView:view atPoint:NSMakePoint(NSMaxX(bounds), NSMaxY(bounds))];
    
}

- (void)drawHandleInView:(NSView *)view atPoint:(NSPoint)point
{
    NSRect handleBounds;
    
    handleBounds.origin.x = point.x - FTFGraphicHandleHalfWidth;
    handleBounds.origin.y = point.y - FTFGraphicHandleHalfWidth;
    handleBounds.size.width = FTFGraphicHandleWidth;
    handleBounds.size.height = FTFGraphicHandleWidth;
    handleBounds = [view centerScanRect:handleBounds];
    
    NSRect handleShadowBounds = NSOffsetRect(handleBounds, 1.0f, 1.0f);
    [[NSColor controlDarkShadowColor] set];
    NSRectFill(handleShadowBounds);
    
    [[NSColor knobColor] set];
    NSRectFill(handleBounds);
}

+ (NSInteger)creationSizingHandle
{
    return FTFGraphicLowerRightHandle;
}

- (BOOL)canSetDrawingFill
{
    return YES;
}

- (BOOL)canSetDrawingStroke
{
    return YES;
}

- (BOOL)isContentsUnderPoint:(NSPoint)point
{
    return NSPointInRect(point, [self bounds]);
}

- (NSInteger)handleUnderPoint:(NSPoint)point
{
    NSInteger handle = FTFGraphicNoHandle;
    NSRect bounds = [self bounds];
    
    if ([self isHandleAtPoint:NSMakePoint(NSMinX(bounds), NSMinY(bounds)) underPoint:point])
    {
        handle = FTFGraphicUpperLeftHandle;
    }
    else if ([self isHandleAtPoint:NSMakePoint(NSMidX(bounds), NSMinY(bounds)) underPoint:point])
    {
        handle = FTFGraphicUpperMiddleHandle;
    }
    else if ([self isHandleAtPoint:NSMakePoint(NSMaxX(bounds), NSMinY(bounds)) underPoint:point])
    {
        handle = FTFGraphicUpperRightHandle;
    }
    else if ([self isHandleAtPoint:NSMakePoint(NSMinX(bounds), NSMidY(bounds)) underPoint:point])
    {
        handle = FTFGraphicMiddleLeftHandle;
    }
    else if ([self isHandleAtPoint:NSMakePoint(NSMaxX(bounds), NSMidY(bounds)) underPoint:point])
    {
        handle = FTFGraphicMiddleRightHandle;
    }
    else if ([self isHandleAtPoint:NSMakePoint(NSMinX(bounds), NSMaxY(bounds)) underPoint:point])
    {
        handle = FTFGraphicLowerLeftHandle;
    }
    else if ([self isHandleAtPoint:NSMakePoint(NSMidX(bounds), NSMaxY(bounds)) underPoint:point])
    {
        handle = FTFGraphicLowerMiddleHandle;
    }
    else if ([self isHandleAtPoint:NSMakePoint(NSMaxX(bounds), NSMaxY(bounds)) underPoint:point])
    {
        handle = FTFGraphicLowerRightHandle;
    }
    
    return handle;
}

- (BOOL)isHandleAtPoint:(NSPoint)handlePoint underPoint:(NSPoint)point
{
    NSRect handleBounds;
    
    handleBounds.origin.x = handlePoint.x - FTFGraphicHandleHalfWidth;
    handleBounds.origin.y = handlePoint.y - FTFGraphicHandleHalfWidth;
    handleBounds.size.width = FTFGraphicHandleWidth;
    handleBounds.size.height = FTFGraphicHandleWidth;
    
    return NSPointInRect(point, handleBounds);
}

- (NSInteger)resizeByMovingHandle:(NSInteger)handle toPoint:(NSPoint)point
{
    NSRect bounds = [self bounds];
    
    if (handle == FTFGraphicUpperLeftHandle ||
        handle == FTFGraphicMiddleLeftHandle ||
        handle == FTFGraphicLowerLeftHandle)
    {
        bounds.size.width = NSMaxX(bounds) - point.x;
        bounds.origin.x = point.x;
        
    }
    else if (handle == FTFGraphicUpperRightHandle ||
             handle == FTFGraphicMiddleRightHandle ||
             handle == FTFGraphicLowerRightHandle)
    {
        bounds.size.width = point.x - bounds.origin.x;
    }
    
    if (bounds.size.width < 0.0f)
    {
        static NSInteger flippings[9];
        static BOOL flippingsInitialized = NO;
        
        if (!flippingsInitialized)
        {
            flippings[FTFGraphicUpperLeftHandle] = FTFGraphicUpperRightHandle;
            flippings[FTFGraphicUpperMiddleHandle] = FTFGraphicUpperMiddleHandle;
            flippings[FTFGraphicUpperRightHandle] = FTFGraphicUpperLeftHandle;
            flippings[FTFGraphicMiddleLeftHandle] = FTFGraphicMiddleRightHandle;
            flippings[FTFGraphicMiddleRightHandle] = FTFGraphicMiddleLeftHandle;
            flippings[FTFGraphicLowerLeftHandle] = FTFGraphicLowerRightHandle;
            flippings[FTFGraphicLowerMiddleHandle] = FTFGraphicLowerMiddleHandle;
            flippings[FTFGraphicLowerRightHandle] = FTFGraphicLowerLeftHandle;
            flippingsInitialized = YES;
        }
        
        handle = flippings[handle];
        
        bounds.size.width = 0.0f - bounds.size.width;
        bounds.origin.x -= bounds.size.width;
        
        [self flipHorizontally];
    }
    
    if (handle == FTFGraphicUpperLeftHandle ||
        handle == FTFGraphicUpperMiddleHandle ||
        handle == FTFGraphicUpperRightHandle)
    {
        bounds.size.height = NSMaxY(bounds) - point.y;
        bounds.origin.y = point.y;
        
    }
    else if (handle == FTFGraphicLowerLeftHandle ||
             handle == FTFGraphicLowerMiddleHandle ||
             handle == FTFGraphicLowerRightHandle)
    {
        bounds.size.height = point.y - bounds.origin.y;
    }
    
    if (bounds.size.height < 0.0f)
    {
        static NSInteger flippings[9];
        static BOOL flippingsInitialized = NO;
        
        if (!flippingsInitialized)
        {
            flippings[FTFGraphicUpperLeftHandle] = FTFGraphicLowerLeftHandle;
            flippings[FTFGraphicUpperMiddleHandle] = FTFGraphicLowerMiddleHandle;
            flippings[FTFGraphicUpperRightHandle] = FTFGraphicLowerRightHandle;
            flippings[FTFGraphicMiddleLeftHandle] = FTFGraphicMiddleLeftHandle;
            flippings[FTFGraphicMiddleRightHandle] = FTFGraphicMiddleRightHandle;
            flippings[FTFGraphicLowerLeftHandle] = FTFGraphicUpperLeftHandle;
            flippings[FTFGraphicLowerMiddleHandle] = FTFGraphicUpperMiddleHandle;
            flippings[FTFGraphicLowerRightHandle] = FTFGraphicUpperRightHandle;
            flippingsInitialized = YES;
        }
        
        handle = flippings[handle];
        
        bounds.size.height = 0.0f - bounds.size.height;
        bounds.origin.y -= bounds.size.height;
        
        [self flipVertically];
    }
    
    [self setBounds:bounds];
    
    return handle;
}

- (void)flipHorizontally
{
    
}

- (void)flipVertically
{
    
}

- (void)setBounds:(NSRect)bounds
{
    _bounds = bounds;
}

- (void)setColor:(NSColor *)color
{
    if ([self canSetDrawingFill])
    {
        if (![self isDrawingFill])
        {
            [self setValue:[NSNumber numberWithBool:YES] forKey:FTFGraphicIsDrawingFillKey];
        }
        
        [self setValue:color forKey:FTFGraphicFillColorKey];
    }
}

- (NSView *)newEditingViewWithSuperviewBounds:(NSRect)superviewBounds
{
    return nil;
}

- (void)finalizeEditingView:(NSView *)editingView
{
    
}

- (NSSet *)keysForValuesToObserveForUndo
{
    return [NSSet setWithObjects:
            FTFGraphicIsDrawingFillKey,
            FTFGraphicFillColorKey,
            FTFGraphicIsDrawingStrokeKey,
            FTFGraphicStrokeColorKey,
            FTFGraphicStrokeWidthKey,
            FTFGraphicBoundsKey,
            nil];
}

@end
