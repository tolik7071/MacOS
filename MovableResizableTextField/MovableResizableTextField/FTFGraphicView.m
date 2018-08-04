//
//  MyGraphicView.m
//  MovableResizableTextField
//
//  Created by Anatoliy Goodz on 7/24/18.
//  Copyright © 2018 Anatoliy Goodz. All rights reserved.
//

#import "FTFGraphicView.h"
#import "FTFGraphic.h"
#import "FTFLine.h"
#import "FTFText.h"

NSString *FTFGraphicViewGraphicsBindingName = @"graphics";
NSString *FTFGraphicViewSelectionIndexesBindingName = @"selectionIndexes";

static NSString *FTFGraphicViewGraphicsObservationContext = @"com.TODO.graphics";
static NSString *FTFGraphicViewIndividualGraphicObservationContext = @"com.TODO.individualGraphic";
static NSString *FTFGraphicViewSelectionIndexesObservationContext = @"com.TODO.selectionIndexes";
static NSString *FTFGraphicViewAnyGridPropertyObservationContext = @"com.TODO.anyGridProperty";

const NSInteger SKTGraphicNoHandle = 0;

@interface FTFGraphicView ()
{
    FTFGraphic  *_creatingGraphic;
    FTFGraphic  *_editingGraphic;
    NSView      *_editingView;
    NSRect       _editingViewFrame;
    NSRect       _marqueeSelectionBounds;
    BOOL         _isHidingHandles;
    NSTimer     *_handleShowingTimer;
}

@property (nonatomic) id graphicsContainer;
@property (nonatomic) id selectionIndexesContainer;
@property (nonatomic) NSString * graphicsKeyPath;
@property (nonatomic) NSString * selectionIndexesKeyPath;

@end

@implementation FTFGraphicView

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    
    if (nil != self)
    {
        
    }
    
    return self;
}

- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    
    if (nil != self)
    {
        
    }
    
    return self;
}

- (void)dealloc
{
    [_handleShowingTimer invalidate];
    
    [self stopEditing];
    
    [self unbind:FTFGraphicViewGraphicsBindingName];
    [self unbind:FTFGraphicViewSelectionIndexesBindingName];
}

- (NSArray *)graphics
{
    NSArray *graphics = [_graphicsContainer valueForKeyPath:_graphicsKeyPath];
    if (!graphics)
    {
        graphics = [NSArray array];
    }
    
    return graphics;
}

- (NSMutableArray *)mutableGraphics
{
    NSMutableArray *graphics = [_graphicsContainer mutableArrayValueForKeyPath:_graphicsKeyPath];
    
    return graphics;
}

- (NSIndexSet *)selectionIndexes
{
    NSIndexSet *selectionIndexes = [_selectionIndexesContainer valueForKeyPath:_selectionIndexesKeyPath];
    if (!selectionIndexes)
    {
        selectionIndexes = [NSIndexSet indexSet];
    }
    
    return selectionIndexes;
}

- (void)changeSelectionIndexes:(NSIndexSet *)indexes
{
    [_selectionIndexesContainer setValue:indexes forKeyPath:_selectionIndexesKeyPath];
}

- (void)startObservingGraphics:(NSArray *)graphics
{
    NSIndexSet *allGraphicIndexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [graphics count])];
    
    [graphics addObserver:self
       toObjectsAtIndexes:allGraphicIndexes
               forKeyPath:FTFGraphicDrawingBoundsKey
                  options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
                  context:(__bridge void * _Nullable)(FTFGraphicViewIndividualGraphicObservationContext)];
    
    [graphics addObserver:self
       toObjectsAtIndexes:allGraphicIndexes
               forKeyPath:FTFGraphicDrawingContentsKey
                  options:0
                  context:(__bridge void * _Nullable)(FTFGraphicViewIndividualGraphicObservationContext)];
}

- (void)stopObservingGraphics:(NSArray *)graphics
{
    NSIndexSet *allGraphicIndexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [graphics count])];
    
    [graphics removeObserver:self
        fromObjectsAtIndexes:allGraphicIndexes
                  forKeyPath:FTFGraphicDrawingContentsKey];
    
    [graphics removeObserver:self
        fromObjectsAtIndexes:allGraphicIndexes
                  forKeyPath:FTFGraphicDrawingBoundsKey];
    
}

- (void)bind:(NSString *)bindingName
    toObject:(id)observableObject
 withKeyPath:(NSString *)observableKeyPath
     options:(NSDictionary *)options
{
    if ([bindingName isEqualToString:FTFGraphicViewGraphicsBindingName])
    {
        if (_graphicsContainer || _graphicsKeyPath)
        {
            [self unbind:FTFGraphicViewGraphicsBindingName];
        }
        
        _graphicsContainer = observableObject;
        _graphicsKeyPath = [observableKeyPath copy];
        
        [_graphicsContainer addObserver:self
                             forKeyPath:_graphicsKeyPath
                                options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
                                context:(__bridge void * _Nullable)(FTFGraphicViewGraphicsObservationContext)];
        [self startObservingGraphics:[_graphicsContainer valueForKeyPath:_graphicsKeyPath]];
        
        [self setNeedsDisplay:YES];
        
    }
    else if ([bindingName isEqualToString:FTFGraphicViewSelectionIndexesBindingName])
    {
        if (_selectionIndexesContainer || _selectionIndexesKeyPath)
        {
            [self unbind:FTFGraphicViewSelectionIndexesBindingName];
        }
        
        _selectionIndexesContainer = observableObject;
        _selectionIndexesKeyPath = [observableKeyPath copy];
        
        [_selectionIndexesContainer addObserver:self
                                     forKeyPath:_selectionIndexesKeyPath
                                        options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
                                        context:(__bridge void * _Nullable)(FTFGraphicViewSelectionIndexesObservationContext)];
        
        [self setNeedsDisplay:YES];
    }
    else
    {
        [super bind:bindingName toObject:observableObject withKeyPath:observableKeyPath options:options];
    }
}

- (void)unbind:(NSString *)bindingName
{
    if ([bindingName isEqualToString:FTFGraphicViewGraphicsBindingName])
    {
        [self stopObservingGraphics:[self graphics]];
        
        [_graphicsContainer removeObserver:self forKeyPath:_graphicsKeyPath];
        _graphicsContainer = nil;
        _graphicsKeyPath = nil;
        
        [self setNeedsDisplay:YES];
    }
    else if ([bindingName isEqualToString:FTFGraphicViewSelectionIndexesBindingName])
    {
        [_selectionIndexesContainer removeObserver:self forKeyPath:_selectionIndexesKeyPath];
        _selectionIndexesContainer = nil;
        _selectionIndexesKeyPath = nil;
        
        [self setNeedsDisplay:YES];
    }
    else
    {
        [super unbind:bindingName];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(NSObject *)observedObject
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (context == (__bridge void * _Nullable)(FTFGraphicViewGraphicsObservationContext))
    {
        NSArray *oldGraphics = [change objectForKey:NSKeyValueChangeOldKey];
        if (![oldGraphics isEqual:[NSNull null]])
        {
            [self stopObservingGraphics:oldGraphics];
            
            [oldGraphics enumerateObjectsUsingBlock:^(FTFGraphic * _Nonnull graphic, NSUInteger idx, BOOL * _Nonnull stop)
            {
                [self setNeedsDisplayInRect:[graphic drawingBounds]];
            }];
            
            if (_editingGraphic && [oldGraphics containsObject:_editingGraphic])
            {
                [self stopEditing];
            }
        }
        
        NSArray *newGraphics = [change objectForKey:NSKeyValueChangeNewKey];
        if (![newGraphics isEqual:[NSNull null]])
        {
            [self startObservingGraphics:newGraphics];
            
            [newGraphics enumerateObjectsUsingBlock:^(FTFGraphic * _Nonnull graphic, NSUInteger idx, BOOL * _Nonnull stop)
            {
                [self setNeedsDisplayInRect:[graphic drawingBounds]];
            }];
            
            // TODO: undo selection
        }
        
    }
    else if (context == (__bridge void * _Nullable)(FTFGraphicViewIndividualGraphicObservationContext))
    {
        if ([keyPath isEqualToString:FTFGraphicDrawingBoundsKey])
        {
            NSRect oldGraphicDrawingBounds = [[change objectForKey:NSKeyValueChangeOldKey] rectValue];
            [self setNeedsDisplayInRect:oldGraphicDrawingBounds];
            NSRect newGraphicDrawingBounds = [[change objectForKey:NSKeyValueChangeNewKey] rectValue];
            [self setNeedsDisplayInRect:newGraphicDrawingBounds];
        }
        else if ([keyPath isEqualToString:FTFGraphicDrawingContentsKey])
        {
            NSRect graphicDrawingBounds = [(FTFGraphic *)observedObject drawingBounds];
            [self setNeedsDisplayInRect:graphicDrawingBounds];
            
        }
    }
    else if (context == (__bridge void * _Nullable)FTFGraphicViewSelectionIndexesObservationContext)
    {
        NSIndexSet *oldSelectionIndexes = [change objectForKey:NSKeyValueChangeOldKey];
        NSIndexSet *newSelectionIndexes = [change objectForKey:NSKeyValueChangeNewKey];
        
        if (![oldSelectionIndexes isEqual:[NSNull null]] &&
            ![newSelectionIndexes isEqual:[NSNull null]])
        {
            for (NSUInteger oldSelectionIndex = [oldSelectionIndexes firstIndex];
                 oldSelectionIndex != NSNotFound;
                 oldSelectionIndex = [oldSelectionIndexes indexGreaterThanIndex:oldSelectionIndex])
            {
                if (![newSelectionIndexes containsIndex:oldSelectionIndex])
                {
                    FTFGraphic *deselectedGraphic = [self graphics][oldSelectionIndex];
                    [self setNeedsDisplayInRect:[deselectedGraphic drawingBounds]];
                }
            }
            
            for (NSUInteger newSelectionIndex = [newSelectionIndexes firstIndex];
                 newSelectionIndex != NSNotFound;
                 newSelectionIndex = [newSelectionIndexes indexGreaterThanIndex:newSelectionIndex])
            {
                if (![oldSelectionIndexes containsIndex:newSelectionIndex])
                {
                    FTFGraphic *selectedGraphic = [self graphics][newSelectionIndex];
                    [self setNeedsDisplayInRect:[selectedGraphic drawingBounds]];
                }
            }
        }
        else
        {
            [self setNeedsDisplay:YES];
        }
        
    }
    else if (context == (__bridge void * _Nullable)FTFGraphicViewAnyGridPropertyObservationContext)
    {
        [self setNeedsDisplay:YES];
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:observedObject change:change context:context];
    }
}

- (NSArray *)selectedGraphics
{
    return [[self graphics] objectsAtIndexes:[self selectionIndexes]];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // TODO: change background
    [[NSColor yellowColor] setFill];
    NSRectFill(dirtyRect);
    
    NSGraphicsContext *currentContext = [NSGraphicsContext currentContext];
    
    NSArray *graphics = [self graphics];
    NSIndexSet *selectionIndexes = [self selectionIndexes];
    NSInteger graphicCount = [graphics count];
    for (NSInteger index = graphicCount - 1; index >= 0; --index)
    {
        FTFGraphic *graphic = graphics[index];
        
        NSRect graphicDrawingBounds = [graphic drawingBounds];
        if (NSIntersectsRect(dirtyRect, graphicDrawingBounds))
        {
            BOOL drawSelectionHandles = NO;
            if (!_isHidingHandles &&
                graphic!=_creatingGraphic &&
                graphic!=_editingGraphic)
            {
                drawSelectionHandles = [selectionIndexes containsIndex:index];
            }
        
            [currentContext saveGraphicsState];
            {
                [NSBezierPath clipRect:graphicDrawingBounds];
                [graphic drawContentsInView:self
                      isBeingCreateOrEdited:(graphic == _creatingGraphic || graphic == _editingGraphic)];
                
                if (drawSelectionHandles)
                {
                    [graphic drawHandlesInView:self];
                }
            }
            [currentContext restoreGraphicsState];
        }
    }
    
    if (!NSEqualRects(_marqueeSelectionBounds, NSZeroRect))
    {
        [[NSColor knobColor] set];
        NSFrameRect(_marqueeSelectionBounds);
    }
}

- (void)setNeedsDisplayForEditingViewFrameChangeNotification:(NSNotification *)viewFrameDidChangeNotification
{
    NSRect newEditingViewFrame = [[viewFrameDidChangeNotification object] frame];
    
    [self setNeedsDisplayInRect:NSUnionRect(_editingViewFrame, newEditingViewFrame)];
    
    _editingViewFrame = newEditingViewFrame;
}

- (void)startEditingGraphic:(FTFGraphic *)graphic
{
    _editingView = [graphic newEditingViewWithSuperviewBounds:[self bounds]];
    if (_editingView)
    {
        _editingGraphic = graphic;
        
        [self addSubview:_editingView];
        
        [[self window] makeFirstResponder:_editingView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
            selector:@selector(setNeedsDisplayForEditingViewFrameChangeNotification:)
            name:NSViewFrameDidChangeNotification object:_editingView];
        
        _editingViewFrame = [_editingView frame];
        
        [self setNeedsDisplayInRect:[_editingGraphic drawingBounds]];
    }
}

- (void)stopEditing
{
    if (_editingView)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self
            name:NSViewFrameDidChangeNotification
            object:_editingView];
        
        BOOL makeSelfFirstResponder = [[self window] firstResponder] == _editingView ? YES : NO;
        
        [_editingView removeFromSuperview];
        
        if (makeSelfFirstResponder)
        {
            [[self window] makeFirstResponder:self];
        }
        
        [_editingGraphic finalizeEditingView:_editingView];
        _editingGraphic = nil;
        _editingView = nil;
    }
}

- (FTFGraphic *)graphicUnderPoint:(NSPoint)point
                            index:(NSUInteger *)outIndex
                       isSelected:(BOOL *)outIsSelected
                           handle:(NSInteger *)outHandle
{
    FTFGraphic *graphicToReturn = nil;
    
    NSArray *graphics = [self graphics];
    NSIndexSet *selectionIndexes = [self selectionIndexes];
    NSUInteger graphicCount = [graphics count];
    
    for (NSUInteger index = 0; index<graphicCount; index++)
    {
        FTFGraphic *graphic = [graphics objectAtIndex:index];
        
        if (NSPointInRect(point, [graphic drawingBounds]))
        {
            BOOL graphicIsSelected = [selectionIndexes containsIndex:index];
            if (graphicIsSelected)
            {
                NSInteger handle = [graphic handleUnderPoint:point];
                if (handle != SKTGraphicNoHandle)
                {
                    graphicToReturn = graphic;
                    if (outHandle)
                    {
                        *outHandle = handle;
                    }
                }
            }
            
            if (!graphicToReturn)
            {
                BOOL clickedOnGraphicContents = [graphic isContentsUnderPoint:point];
                if (clickedOnGraphicContents)
                {
                    graphicToReturn = graphic;
                    if (outHandle)
                    {
                        *outHandle = SKTGraphicNoHandle;
                    }
                }
            }
            
            if (graphicToReturn)
            {
                if (outIndex)
                {
                    *outIndex = index;
                }
                
                if (outIsSelected)
                {
                    *outIsSelected = graphicIsSelected;
                }
                
                break;
            }
        }
    }
    
    return graphicToReturn;
}

- (void)moveSelectedGraphicsWithEvent:(NSEvent *)event
{
    NSPoint lastPoint, curPoint;
    NSArray *selGraphics = [self selectedGraphics];
    NSUInteger c;
    BOOL isMoving = NO;
    NSRect selBounds = [[FTFGraphic class] boundsOfGraphics:selGraphics];
    
    c = [selGraphics count];
    
    lastPoint = [self convertPoint:[event locationInWindow] fromView:nil];
//    NSPoint selOriginOffset = NSMakePoint(
//        (lastPoint.x - selBounds.origin.x),
//        (lastPoint.y - selBounds.origin.y));
    
    while ([event type] != NSEventTypeLeftMouseUp)
    {
        event = [[self window] nextEventMatchingMask:(NSEventMaskLeftMouseDragged | NSEventMaskLeftMouseUp)];
        
        [self autoscroll:event];
        
        curPoint = [self convertPoint:[event locationInWindow] fromView:nil];
        
        if (!isMoving && ((fabs(curPoint.x - lastPoint.x) >= 2.0) || (fabs(curPoint.y - lastPoint.y) >= 2.0)))
        {
            isMoving = YES;
            _isHidingHandles = YES;
        }
        
        if (isMoving)
        {
            if (!NSEqualPoints(lastPoint, curPoint))
            {
                [[FTFGraphic class] translateGraphics:selGraphics
                    byX:(curPoint.x - lastPoint.x)
                    y:(curPoint.y - lastPoint.y)];
            }
            
            lastPoint = curPoint;
        }
    }
    

    if (isMoving)
    {
        _isHidingHandles = NO;
        
        [self setNeedsDisplayInRect:[[FTFGraphic class] drawingBoundsOfGraphics:selGraphics]];
    }
}

- (void)resizeGraphic:(FTFGraphic *)graphic
          usingHandle:(NSInteger)handle
            withEvent:(NSEvent *)event
{
    while ([event type] != NSEventTypeLeftMouseUp)
    {
        event = [[self window] nextEventMatchingMask:(NSEventMaskLeftMouseDragged | NSEventMaskLeftMouseUp)];
        
        [self autoscroll:event];
        
        NSPoint handleLocation = [self convertPoint:[event locationInWindow] fromView:nil];
        
        handle = [graphic resizeByMovingHandle:handle toPoint:handleLocation];
    }
}

- (NSIndexSet *)indexesOfGraphicsIntersectingRect:(NSRect)rect
{
    __block NSMutableIndexSet *indexSetToReturn = [NSMutableIndexSet indexSet];
    NSArray *graphics = [self graphics];
    
    [graphics enumerateObjectsUsingBlock:^(FTFGraphic * _Nonnull graphic, NSUInteger idx, BOOL * _Nonnull stop)
    {
        if (NSIntersectsRect(rect, [graphic drawingBounds]))
        {
            [indexSetToReturn addIndex:[graphics indexOfObject:graphic]];
        }
    }];
    
    return indexSetToReturn;
}

- (void)createGraphicOfClass:(Class)graphicClass
                   withEvent:(NSEvent *)event
{
    // TODO: undo
    
    [self changeSelectionIndexes:[NSIndexSet indexSet]];
    
    NSPoint graphicOrigin;
    NSSize graphicSize;
    
    if (event != nil)
    {
        graphicOrigin = [self convertPoint:[event locationInWindow] fromView:nil];
        graphicSize = NSMakeSize(0.0f, 0.0f);
    }
    else
    {
        graphicOrigin = NSMakePoint(10.0f, 10.0f);
        graphicSize = NSMakeSize(100.0f, 100.0f);
    }
    
    _creatingGraphic = [[graphicClass alloc] init];
    [_creatingGraphic setBounds:
        NSMakeRect(
            graphicOrigin.x, graphicOrigin.y,
            graphicSize.width, graphicSize.height)];
    
    NSMutableArray *mutableGraphics = [self mutableGraphics];
    [mutableGraphics insertObject:_creatingGraphic atIndex:0];
    
    if (event)
    {
        [self resizeGraphic:_creatingGraphic
                usingHandle:[graphicClass creationSizingHandle]
                  withEvent:event];
    }
    
    NSRect createdGraphicBounds = [_creatingGraphic bounds];
    if (NSWidth(createdGraphicBounds) != 0.0 || NSHeight(createdGraphicBounds) != 0.0)
    {
        [self changeSelectionIndexes:[NSIndexSet indexSetWithIndex:0]];
        
        [self startEditingGraphic:_creatingGraphic];
    }
    
    _creatingGraphic = nil;
}

- (void)marqueeSelectWithEvent:(NSEvent *)event
{
    NSIndexSet *oldSelectionIndexes = [self selectionIndexes];
    NSPoint originalMouseLocation = [self convertPoint:[event locationInWindow] fromView:nil];
    
    while ([event type] != NSEventTypeLeftMouseUp)
    {
        event = [[self window] nextEventMatchingMask:(NSEventMaskLeftMouseDragged | NSEventMaskLeftMouseUp)];
        
        [self autoscroll:event];
        
        NSPoint currentMouseLocation = [self convertPoint:[event locationInWindow] fromView:nil];
        
        NSRect newMarqueeSelectionBounds = NSMakeRect(
            fmin(originalMouseLocation.x, currentMouseLocation.x),
            fmin(originalMouseLocation.y, currentMouseLocation.y),
            fabs(currentMouseLocation.x - originalMouseLocation.x),
            fabs(currentMouseLocation.y - originalMouseLocation.y));
        
        if (!NSEqualRects(newMarqueeSelectionBounds, _marqueeSelectionBounds))
        {
            [self setNeedsDisplayInRect:_marqueeSelectionBounds];
            _marqueeSelectionBounds = newMarqueeSelectionBounds;
            [self setNeedsDisplayInRect:_marqueeSelectionBounds];
            
            NSIndexSet *indexesOfGraphicsInRubberBand = [self indexesOfGraphicsIntersectingRect:_marqueeSelectionBounds];
            NSMutableIndexSet *newSelectionIndexes = [oldSelectionIndexes mutableCopy];
            for (NSUInteger index = [indexesOfGraphicsInRubberBand firstIndex];
                 index != NSNotFound;
                 index = [indexesOfGraphicsInRubberBand indexGreaterThanIndex:index])
            {
                if ([newSelectionIndexes containsIndex:index]) {
                    [newSelectionIndexes removeIndex:index];
                } else {
                    [newSelectionIndexes addIndex:index];
                }
            }
            
            [self changeSelectionIndexes:newSelectionIndexes];
        }
    }
    
    [self setNeedsDisplayInRect:_marqueeSelectionBounds];
    
    _marqueeSelectionBounds = NSZeroRect;
}

- (void)selectAndTrackMouseWithEvent:(NSEvent *)event
{
    BOOL modifyingExistingSelection = ([event modifierFlags] & NSEventModifierFlagShift) ? YES : NO;
    
    NSPoint mouseLocation = [self convertPoint:[event locationInWindow] fromView:nil];
    NSUInteger clickedGraphicIndex;
    BOOL clickedGraphicIsSelected;
    NSInteger clickedGraphicHandle;
    FTFGraphic *clickedGraphic = [self graphicUnderPoint:mouseLocation
                                                  index:&clickedGraphicIndex
                                             isSelected:&clickedGraphicIsSelected
                                                 handle:&clickedGraphicHandle];
    if (clickedGraphic)
    {
        if (clickedGraphicHandle != SKTGraphicNoHandle)
        {
            [self resizeGraphic:clickedGraphic
                    usingHandle:clickedGraphicHandle
                      withEvent:event];
        }
        else
        {
            if (modifyingExistingSelection)
            {
                if (clickedGraphicIsSelected)
                {
                    NSMutableIndexSet *newSelectionIndexes = [[self selectionIndexes] mutableCopy];
                    [newSelectionIndexes removeIndex:clickedGraphicIndex];
                    [self changeSelectionIndexes:newSelectionIndexes];
                    clickedGraphicIsSelected = NO;
                    
                }
                else
                {
                    NSMutableIndexSet *newSelectionIndexes = [[self selectionIndexes] mutableCopy];
                    [newSelectionIndexes addIndex:clickedGraphicIndex];
                    [self changeSelectionIndexes:newSelectionIndexes];
                    clickedGraphicIsSelected = YES;
                }
            }
            else
            {
                if (!clickedGraphicIsSelected)
                {
                    [self changeSelectionIndexes:[NSIndexSet indexSetWithIndex:clickedGraphicIndex]];
                    clickedGraphicIsSelected = YES;
                }
            }
            
            if (clickedGraphicIsSelected)
            {
                [self moveSelectedGraphicsWithEvent:event];
            }
            else
            {
                while ([event type] != NSEventTypeLeftMouseUp)
                {
                    event = [[self window] nextEventMatchingMask:(NSEventMaskLeftMouseDragged | NSEventMaskLeftMouseUp)];
                }
            }
        }
    }
    else
    {
        if (!modifyingExistingSelection)
        {
            [self changeSelectionIndexes:[NSIndexSet indexSet]];
        }

#if defined(TRACK_MULTI_SELECTION)
        [self marqueeSelectWithEvent:event];
#endif // TRACK_MULTI_SELECTION
    }
}

- (BOOL)acceptsFirstMouse:(NSEvent *)event
{
    return [[self selectionIndexes] count] > 0 ? NO : YES;
}

- (Class)classForGraphicID:(FTFGraphicToolIDs)FTFGraphicToolIDs
{
    Class result = nil;
    
    switch (FTFGraphicToolIDs)
    {
        case FTFLineGraphicToolTag:
            result = [FTFLine class];
            break;
            
        case FTFTextGraphicToolTag:
            result = [FTFText class];
            break;
            
        default:
            break;
    }
    
    return result;
}

- (void)mouseDown:(NSEvent *)event
{
    [self stopEditing];
    
    // TODO: select cursor
    
    Class graphicClassToInstantiate = [self classForGraphicID:[_graphicSelectionSource selectedGraphic]];
    
    if (graphicClassToInstantiate)
    {
        [self createGraphicOfClass:graphicClassToInstantiate withEvent:event];
    }
    else
    {
        FTFGraphic *doubleClickedGraphic = nil;
        
        if ([event clickCount] > 1)
        {
            NSPoint mouseLocation = [self convertPoint:[event locationInWindow] fromView:nil];
            doubleClickedGraphic = [self graphicUnderPoint:mouseLocation index:NULL isSelected:NULL handle:NULL];
            if (doubleClickedGraphic)
            {
                [self startEditingGraphic:doubleClickedGraphic];
            }
        }
        
        if (!doubleClickedGraphic)
        {
            [self selectAndTrackMouseWithEvent:event];
        }
    }
    
    // TODO: restore cursor
}

- (void)keyDown:(NSEvent *)event
{
    [self interpretKeyEvents:[NSArray arrayWithObject:event]];
}

- (IBAction)delete:(id)sender
{
    [[self mutableGraphics] removeObjectsAtIndexes:[self selectionIndexes]];
}

- (void)deleteBackward:(id)sender
{
    [self delete:sender];
}

- (void)deleteForward:(id)sender
{
    [self delete:sender];
}

- (void)invalidateHandlesOfGraphics:(NSArray *)graphics
{
    [graphics enumerateObjectsUsingBlock:^(FTFGraphic * _Nonnull graphic, NSUInteger idx, BOOL * _Nonnull stop)
    {
        [self setNeedsDisplayInRect:[graphic drawingBounds]];
    }];
}

- (void)unhideHandlesForTimer:(NSTimer *)timer
{
    _isHidingHandles = NO;
    _handleShowingTimer = nil;
    
    [self setNeedsDisplayInRect:[[FTFGraphic class] drawingBoundsOfGraphics:[self selectedGraphics]]];
}

- (void)hideHandlesMomentarily
{
    [_handleShowingTimer invalidate];
    
    _handleShowingTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
        target:self
        selector:@selector(unhideHandlesForTimer:)
        userInfo:nil
        repeats:NO];
    _isHidingHandles = YES;
    
    [self setNeedsDisplayInRect:[[FTFGraphic class] drawingBoundsOfGraphics:[self selectedGraphics]]];
}

- (void)moveSelectedGraphicsByX:(CGFloat)x y:(CGFloat)y
{
    NSArray *selectedGraphics = [self selectedGraphics];
    if ([selectedGraphics count] > 0)
    {
        [self hideHandlesMomentarily];
        
        [[FTFGraphic class] translateGraphics:selectedGraphics byX:x y:y];
    }
}

- (void)moveLeft:(id)sender
{
    [self moveSelectedGraphicsByX:-1.0f y:0.0f];
}

- (void)moveRight:(id)sender
{
    [self moveSelectedGraphicsByX:1.0f y:0.0f];
}

- (void)moveUp:(id)sender
{
    [self moveSelectedGraphicsByX:0.0f y:-1.0f];
}

- (void)moveDown:(id)sender
{
    [self moveSelectedGraphicsByX:0.0f y:1.0f];
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (BOOL)isFlipped
{
    // TODO:
    return NO;
}

- (BOOL)isOpaque
{
    // TODO:
    return YES;
}

- (BOOL)validateMenuItem:(NSMenuItem *)item
{
    SEL action = [item action];
    
    if ((action == @selector(delete:)) ||
        (action == @selector(bringToFront:)) ||
        (action == @selector(sendToBack:)) ||
        (action == @selector(cut:)) ||
        (action == @selector(copy:)))
    {
        return (([[self selectedGraphics] count] > 0) ? YES : NO);
    }
    else if (action == @selector(undo:) ||
             action == @selector(redo:))
    {
        // TODO:
        return [[self window] validateMenuItem:item];
        
    }
    else
    {
        return YES;
    }
}

- (IBAction)undo:(id)sender
{
    // TODO:
}

- (IBAction)redo:(id)sender
{
    // TODO:
}

- (void)changeColor:(id)sender
{
    [[self selectedGraphics] enumerateObjectsUsingBlock:^(FTFGraphic * _Nonnull graphic, NSUInteger idx, BOOL * _Nonnull stop)
    {
        [graphic setColor:[sender color]];
    }];
}

- (void)selectAll:(id)sender
{
    [self changeSelectionIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [[self graphics] count])]];
}

- (IBAction)deselectAll:(id)sender
{
    [self changeSelectionIndexes:[NSIndexSet indexSet]];
}

- (IBAction)insertGraphic:(id)sender
{
    
    Class graphicClass = nil;

/*
    switch ([sender tag])
    {
        case MyTextTag:
            graphicClass = [MyText class];
            break;
        case MyLineTage:
            graphicClass = [MyLine class];
            break;
        default:
            break;
    };
 */
    
    if (graphicClass)
    {
        [self createGraphicOfClass:graphicClass withEvent:nil];
        // TODO: select arrow
    }
}

@end
