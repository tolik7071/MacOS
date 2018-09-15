//
//  CoreTextView.m
//  CoreTextTest
//
//  Created by tolik7071 on 4/28/18.
//  Copyright © 2018 tolik7071. All rights reserved.
//

#import "CoreTextView.h"
#import <Carbon/Carbon.h>

#define LOG_METHOD() NSLog(@"%p: %s", self, __PRETTY_FUNCTION__)

#define kEmptyRange NSMakeRange(NSNotFound, 0 )
#define kEmptyRect NSMakeRect(0, 0, 0, 0)

@interface CoreTextView()

@property (nonatomic) NSString * text;

@end

@implementation CoreTextView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    
    if (self)
    {
        _font = [NSFont fontWithName:@"Arial" size:24.0];
        [[NSFontPanel sharedFontPanel] setPanelFont:_font isMultiple:NO];
        
        _attributes =
        @{
          NSForegroundColorAttributeName : [NSColor redColor]
        };
        [[NSFontManager sharedFontManager] setSelectedAttributes:_attributes isMultiple:NO];
        
        _text = @"Font descriptors, instantiated from the NSFontDescriptor class, provide a way to "
            "describe a font with a dictionary of attributes. The font descriptor can then be used "
            "to create or modify an NSFont object. In particular, you can make an NSFont object "
            "from a font descriptor, you can get a descriptor from an NSFont object, and you can "
            "change a descriptor and use it to make a new font object. You can also use a font "
            "descriptor to specify custom fonts provided by an app.";
        
        _zoom = 1.0;
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];

#define USE_CORE_GRAPHIC
    
#if defined(USE_CORE_GRAPHIC)
    
    CGContextRef context = [[NSGraphicsContext currentContext] CGContext];
    
    CGContextSaveGState(context);
    
//    CGAffineTransform textTransform = CGAffineTransformIdentity;
//    textTransform = CGAffineTransformScale(textTransform, 1, 1);
//    CGContextSetTextMatrix(context, textTransform);
    
    // Background
    
    CGContextBeginPath(context);
    CGContextAddRect(context, dirtyRect);
    CGContextSetRGBFillColor(context, 0.6, 0.9, 0.6, 1.0);
    CGContextFillPath(context);
    
    // Zoom
    
    NSFont *font;
    
//#define USE_SCALE_FONT
#if defined(USE_SCALE_FONT)
    CGFloat fontSize = _font.pointSize * _zoom;
    font = [NSFont fontWithName:_font.fontName size:fontSize];
#else
    font = _font;
    
    CGFloat deltaX = self.bounds.size.width - self.bounds.size.width * _zoom;
    CGFloat deltaY = self.bounds.size.height - self.bounds.size.height * _zoom;
    
    CGContextTranslateCTM(context, deltaX, deltaY);
    
    printf("%.2f: %.2f %.2f\n", _zoom, deltaX, deltaY);
    
    CGContextScaleCTM(context, _zoom, _zoom);
#endif // USE_SCALE_FONT
    
    // Text
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]
        initWithString:self.text
        attributes:_attributes];
    [attributedString addAttribute:NSFontAttributeName
        value:font
        range:NSMakeRange(0, _text.length)];
    
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString(
        (__bridge CFAttributedStringRef)attributedString);
    CGRect frameRect = NSInsetRect(self.bounds, 10.0, 10.0);
    
    CGPathRef framePath = CGPathCreateWithRect(frameRect, NULL);
    
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), framePath, NULL);
    CTFrameDraw(frame, context);
    
    CFRelease(frame);
    CFRelease(framePath);
    CFRelease(frameSetter);
    
    CGContextRestoreGState(context);
    
#else
    
    // Background
    
    [[NSColor colorWithRed:0.6 green:0.9 blue:0.6 alpha:1.0] set];
    NSRectFill(dirtyRect);
    
    // Text objects
    
    NSMutableDictionary *attributesToDraw = [[NSMutableDictionary alloc] initWithDictionary:_attributes];
    attributesToDraw[NSFontAttributeName] = _font;
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithString:_text attributes:attributesToDraw];
    
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [textStorage addLayoutManager:layoutManager];
    
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithContainerSize:self.frame.size];
    [layoutManager addTextContainer:textContainer];
    
    [textStorage drawInRect:self.bounds];
    
#endif // USE_CORE_GRAPHIC
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (void)keyDown:(NSEvent *)event
{
    NSLog(@"%u", [event keyCode]);
    [self interpretKeyEvents:[NSArray arrayWithObject:event]];
}

- (void)setZoom:(CGFloat)zoom
{
    if (_zoom != zoom)
    {
        _zoom = zoom;
        
        [self setNeedsDisplay:YES];
    }
}

#pragma mark - NSTextInputClient -

- (void)insertText:(id)string replacementRange:(NSRange)replacementRange
{
    LOG_METHOD();
    NSLog(@"%@ {%lu, %lu}", string, replacementRange.location, replacementRange.length);
    _text = [NSString stringWithString:string];
    [self setNeedsDisplay:YES];
}

- (void)doCommandBySelector:(SEL)selector
{
    LOG_METHOD();
    NSLog(@"%@", NSStringFromSelector(selector));
    
/*    if ([NSStringFromSelector(selector) isEqualToString:@"cancelOperation:"])
    {
        self.text = @"";
        [self setNeedsDisplay:YES];
    }
    else */if ([NSStringFromSelector(selector) isEqualToString:@"deleteBackward:"])
    {
        
    }
    else if ([NSStringFromSelector(selector) isEqualToString:@"deleteForward:"])
    {
        
    }
    else if ([NSStringFromSelector(selector) isEqualToString:@"insertNewline:"])
    {
        
    }
}

- (void)setMarkedText:(id)string selectedRange:(NSRange)selectedRange replacementRange:(NSRange)replacementRange
{
    LOG_METHOD();
}

- (void)unmarkText
{
    LOG_METHOD();
}

- (NSRange)selectedRange
{
    LOG_METHOD();
    return kEmptyRange;
}

- (NSRange)markedRange
{
    LOG_METHOD();
    return kEmptyRange;
}

- (BOOL)hasMarkedText
{
    LOG_METHOD();
    return NO;
}

- (nullable NSAttributedString *)attributedSubstringForProposedRange:(NSRange)range actualRange:(nullable NSRangePointer)actualRange
{
    LOG_METHOD();
    return nil;
}

- (NSArray<NSAttributedStringKey> *)validAttributesForMarkedText
{
    LOG_METHOD();
    return nil;
}

- (NSRect)firstRectForCharacterRange:(NSRange)range actualRange:(nullable NSRangePointer)actualRange
{
    LOG_METHOD();
    return kEmptyRect;
}

- (NSUInteger)characterIndexForPoint:(NSPoint)point
{
    LOG_METHOD();
    return NSNotFound;
}

@end
