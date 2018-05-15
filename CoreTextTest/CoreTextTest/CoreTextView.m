//
//  CoreTextView.m
//  CoreTextTest
//
//  Created by tolik7071 on 4/28/18.
//  Copyright © 2018 tolik7071. All rights reserved.
//

#import "CoreTextView.h"
#import <Carbon/Carbon.h>

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
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
#if defined(USE_CORE_GRAPHIC)
    
    CGContextRef context = [[NSGraphicsContext currentContext] CGContext];
    
    CGContextSaveGState(context);
    
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    
    // Background
    
    CGContextBeginPath(context);
    CGContextAddRect(context, dirtyRect);
    CGContextSetRGBFillColor(context, 0.6, 0.9, 0.6, 1.0);
    CGContextFillPath(context);
    
    // Text
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.text attributes:_attributes];
    [attributedString addAttribute:NSFontAttributeName value:_font range:NSMakeRange(0, _text.length)];
    
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attributedString);
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
    [super keyDown:event];
    
//    TISInputSourceRef inputSource = TISCopyCurrentKeyboardLayoutInputSource();
//    CFShow(inputSource);
}

@end
