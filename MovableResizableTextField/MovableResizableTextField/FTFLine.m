//
//  FTFLine.m
//  MovableResizableTextField
//
//  Created by Anatoliy Goodz on 7/27/18.
//  Copyright © 2018 Anatoliy Goodz. All rights reserved.
//

#import "FTFLine.h"

NSString *FTFLineBeginPointKey = @"beginPoint";
NSString *FTFLineEndPointKey = @"endPoint";

@interface FTFLine ()
{
    BOOL _pointsRight;
    BOOL _pointsDown;
}

@end

@implementation FTFLine

+ (NSSet *)keyPathsForValuesAffectingBeginPoint
{
    return [NSSet setWithObject:FTFGraphicBoundsKey];
}

- (NSPoint)beginPoint
{
    NSRect bounds = [self bounds];
    
    NSPoint beginPoint;
    beginPoint.x = _pointsRight ? NSMinX(bounds) : NSMaxX(bounds);
    beginPoint.y = _pointsDown ? NSMinY(bounds) : NSMaxY(bounds);
    
    return beginPoint;
}

+ (NSSet *)keyPathsForValuesAffectingEndPoint
{
    return [NSSet setWithObject:FTFGraphicBoundsKey];
}

- (NSPoint)endPoint
{
    NSRect bounds = [self bounds];
    
    NSPoint endPoint;
    endPoint.x = _pointsRight ? NSMaxX(bounds) : NSMinX(bounds);
    endPoint.y = _pointsDown ? NSMaxY(bounds) : NSMinY(bounds);
    
    return endPoint;
    
}

+ (NSRect)boundsWithBeginPoint:(NSPoint)beginPoint
                      endPoint:(NSPoint)endPoint
                   pointsRight:(BOOL *)outPointsRight
                          down:(BOOL *)outPointsDown
{
    BOOL pointsRight = beginPoint.x<endPoint.x;
    BOOL pointsDown = beginPoint.y<endPoint.y;
    CGFloat xPosition = pointsRight ? beginPoint.x : endPoint.x;
    CGFloat yPosition = pointsDown ? beginPoint.y : endPoint.y;
    CGFloat width = fabs(endPoint.x - beginPoint.x);
    CGFloat height = fabs(endPoint.y - beginPoint.y);
    
    if (outPointsRight)
    {
        *outPointsRight = pointsRight;
    }
    
    if (outPointsDown)
    {
        *outPointsDown = pointsDown;
    }
    
    return NSMakeRect(xPosition, yPosition, width, height);
}

- (void)setBeginPoint:(NSPoint)beginPoint
{
    [self setBounds:[[self class] boundsWithBeginPoint:beginPoint
                                              endPoint:[self endPoint]
                                           pointsRight:&_pointsRight
                                                  down:&_pointsDown]];
}


- (void)setEndPoint:(NSPoint)endPoint
{
    [self setBounds:[[self class] boundsWithBeginPoint:[self beginPoint]
                                              endPoint:endPoint
                                           pointsRight:&_pointsRight
                                                  down:&_pointsDown]];
}

- (BOOL)isDrawingFill
{
    return NO;
}

- (BOOL)isDrawingStroke
{
    return YES;
}

- (NSBezierPath *)bezierPathForDrawing
{
    NSBezierPath *path = [NSBezierPath bezierPath];
    
    [path moveToPoint:[self beginPoint]];
    [path lineToPoint:[self endPoint]];
    [path setLineWidth:[self strokeWidth]];
    
    return path;
}

- (void)drawHandlesInView:(NSView *)view
{
    [self drawHandleInView:view atPoint:[self beginPoint]];
    [self drawHandleInView:view atPoint:[self endPoint]];
}

+ (NSInteger)creationSizingHandle
{
    return FTFLineEndHandle;
}

- (BOOL)canSetDrawingFill
{
    return NO;
}

- (BOOL)canSetDrawingStroke
{
    return NO;
}

- (BOOL)isContentsUnderPoint:(NSPoint)point
{
    BOOL isContentsUnderPoint = NO;
    
    if (NSPointInRect(point, [self bounds]))
    {
        CGFloat acceptableDistance = ([self strokeWidth] / 2.0f) + 2.0f;
        
        NSPoint beginPoint = [self beginPoint];
        NSPoint endPoint = [self endPoint];
        CGFloat xDelta = endPoint.x - beginPoint.x;
        if (xDelta == 0.0f && fabs(point.x - beginPoint.x) <= acceptableDistance)
        {
            isContentsUnderPoint = YES;
        }
        else
        {
            CGFloat slope = (endPoint.y - beginPoint.y) / xDelta;
            if (fabs(((point.x - beginPoint.x) * slope) - (point.y - beginPoint.y)) <= acceptableDistance)
            {
                isContentsUnderPoint = YES;
            }
        }
    }
    
    return isContentsUnderPoint;
}

- (NSInteger)handleUnderPoint:(NSPoint)point
{
    NSInteger handle = SKTGraphicNoHandle;
    
    if ([self isHandleAtPoint:[self beginPoint] underPoint:point])
    {
        handle = FTFLineBeginHandle;
    }
    else if ([self isHandleAtPoint:[self endPoint] underPoint:point])
    {
        handle = FTFLineEndHandle;
    }
    
    return handle;
}

- (NSInteger)resizeByMovingHandle:(NSInteger)handle toPoint:(NSPoint)point
{
    if (handle == FTFLineBeginHandle)
    {
        [self setBeginPoint:point];
    }
    else if (handle == FTFLineEndHandle)
    {
        [self setEndPoint:point];
    }
    
    return handle;
}

- (void)setColor:(NSColor *)color
{
    [self setValue:color forKey:FTFGraphicStrokeColorKey];
}

@end
