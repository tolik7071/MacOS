//
//  FTFText.m
//  MovableResizableTextField
//
//  Created by Anatoliy Goodz on 7/27/18.
//  Copyright © 2018 Anatoliy Goodz. All rights reserved.
//

#import "FTFText.h"

NSString *FTFTextScriptingContentsKey = @"scriptingContents";
NSString *FTFTextUndoContentsKey = @"undoContents";
NSString *FTFTextContentsKey = @"contents";

@interface FTFText ()
{
    NSTextStorage   *_contents;
    BOOL             _boundsBeingChangedToMatchContents;
}
@end

@implementation FTFText

- (NSTextStorage *)contents
{
    if (!_contents)
    {
        _contents = [[NSTextStorage alloc] init];
        
        [_contents setDelegate:self];
        
    }
    
    return _contents;
}

- (void)dealloc
{
    [_contents setDelegate:nil];
}

+ (NSLayoutManager *)sharedLayoutManager
{
    static NSLayoutManager *layoutManager = nil;
    
    if (!layoutManager)
    {
        NSTextContainer *textContainer = [[NSTextContainer alloc]
            initWithContainerSize:NSMakeSize(1.0e7f, 1.0e7f)];
        layoutManager = [[NSLayoutManager alloc] init];
        [textContainer setWidthTracksTextView:NO];
        [textContainer setHeightTracksTextView:NO];
        [layoutManager addTextContainer:textContainer];
    }
    
    return layoutManager;
}

- (NSSize)naturalSize
{
    NSRect bounds = [self bounds];
    NSLayoutManager *layoutManager = [[self class] sharedLayoutManager];
    NSTextContainer *textContainer = [[layoutManager textContainers] objectAtIndex:0];
    [textContainer setContainerSize:NSMakeSize(bounds.size.width, 1.0e7f)];
    NSTextStorage *contents = [self contents];
    [contents addLayoutManager:layoutManager];
    [layoutManager glyphRangeForTextContainer:textContainer];
    NSSize naturalSize = [layoutManager usedRectForTextContainer:textContainer].size;
    [contents removeLayoutManager:layoutManager];
    
    return naturalSize;
}

- (void)setHeightToMatchContents
{
    [self willChangeValueForKey:FTFGraphicKeysForValuesToObserveForUndoKey];
    _boundsBeingChangedToMatchContents = YES;
    [self didChangeValueForKey:FTFGraphicKeysForValuesToObserveForUndoKey];
    
    NSRect bounds = [self bounds];
    NSSize naturalSize = [self naturalSize];
    [self setBounds:NSMakeRect(bounds.origin.x, bounds.origin.y, bounds.size.width, naturalSize.height)];
    
    [self willChangeValueForKey:FTFGraphicKeysForValuesToObserveForUndoKey];
    _boundsBeingChangedToMatchContents = NO;
    [self didChangeValueForKey:FTFGraphicKeysForValuesToObserveForUndoKey];
}

- (void)textStorage:(NSTextStorage *)textStorage
  didProcessEditing:(NSTextStorageEditActions)editedMask
              range:(NSRange)editedRange
     changeInLength:(NSInteger)delta
{
    [self performSelector:@selector(setHeightToMatchContents) withObject:nil afterDelay:0.0];
}

//- (void)textStorageDidProcessEditing:(NSNotification *)notification
//{
//    [self performSelector:@selector(setHeightToMatchContents) withObject:nil afterDelay:0.0];
//}

- (BOOL)isDrawingStroke
{
    return NO;
}

- (NSRect)drawingBounds
{
    return NSUnionRect([super drawingBounds], NSInsetRect([self bounds], -1.0f, -1.0f));
}

- (void)drawContentsInView:(NSView *)view
     isBeingCreateOrEdited:(BOOL)isBeingCreatedOrEditing
{
    NSRect bounds = [self bounds];
    
    if ([self isDrawingFill])
    {
        [[self fillColor] set];
        NSRectFill(bounds);
    }
    
    if (isBeingCreatedOrEditing)
    {
        [[NSColor knobColor] set];
        NSFrameRect(NSInsetRect(bounds, -1.0, -1.0));
    }
    else
    {
        NSTextStorage *contents = [self contents];
        if ([contents length] > 0)
        {
            NSLayoutManager *layoutManager = [[self class] sharedLayoutManager];
            NSTextContainer *textContainer = [[layoutManager textContainers] objectAtIndex:0];
            [textContainer setContainerSize:bounds.size];
            [contents addLayoutManager:layoutManager];
            NSRange glyphRange = [layoutManager glyphRangeForTextContainer:textContainer];
            
            if (glyphRange.length > 0)
            {
                if (!view.isFlipped)
                {
                    [[NSGraphicsContext currentContext] saveGraphicsState];
                    
                    NSRect frameRect = bounds;
                    NSAffineTransform* xform = [NSAffineTransform transform];
                    [xform translateXBy:0.0 yBy:frameRect.size.height];
                    [xform scaleXBy:1.0 yBy:-1.0];
                    [xform concat];
                }
                
                [layoutManager drawBackgroundForGlyphRange:glyphRange atPoint:bounds.origin];
                [layoutManager drawGlyphsForGlyphRange:glyphRange atPoint:bounds.origin];
                
                if (!view.isFlipped)
                {
                    [[NSGraphicsContext currentContext] restoreGraphicsState];
                }
            }
            
            [contents removeLayoutManager:layoutManager];
        }
    }
}

- (BOOL)canSetDrawingStroke
{
    return NO;
}

- (void)setBounds:(NSRect)bounds
{
    [super setBounds:bounds];
    
    if (!_boundsBeingChangedToMatchContents)
    {
        NSArray *layoutManagers = [[self contents] layoutManagers];
        NSUInteger layoutManagerCount = [layoutManagers count];
        for (NSUInteger index = 0; index < layoutManagerCount; index++)
        {
            NSLayoutManager *layoutManager = [layoutManagers objectAtIndex:index];
            [[layoutManager firstTextView] setFrame:bounds];
        }
    }
}

- (NSView *)newEditingViewWithSuperviewBounds:(NSRect)superviewBounds
{
    NSRect bounds = [self bounds];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithContainerSize:NSMakeSize(bounds.size.width, 1.0e7f)];
    NSTextView *textView = [[NSTextView alloc] initWithFrame:bounds textContainer:textContainer];
    
    textView.backgroundColor = [NSColor redColor];
    
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [layoutManager addTextContainer:textContainer];

    NSTextStorage *contents = [self contents];
    [contents addLayoutManager:layoutManager];
    
    [textView setAllowsUndo:YES];
    
    [textView setDrawsBackground:NO];
    
    [textView setSelectedRange:NSMakeRange(0, [contents length])];
    
    [textView setMinSize:NSMakeSize(bounds.size.width, 0.0)];
    [textView setMaxSize:NSMakeSize(bounds.size.width, superviewBounds.size.height - bounds.origin.y)];
    [textView setVerticallyResizable:YES];
    
    return textView;
}

- (void)finalizeEditingView:(NSView *)editingView
{
    [[self contents] removeLayoutManager:[(NSTextView *)editingView layoutManager]];
}

@end
