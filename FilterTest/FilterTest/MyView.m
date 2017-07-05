//
//  MyView.m
//  FilterTest
//
//  Created by Anatoliy Goodz on 7/8/15.
//  Copyright (c) 2015 smk.private. All rights reserved.
//

#import "MyView.h"
#import <Quartz/Quartz.h>

void MyDrawColoredPattern(void*, CGContextRef);
CGColorRef GetColor(CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha);

#define H_PSIZE 100
#define V_PSIZE 100
#define H_PATTERN_SIZE 16
#define V_PATTERN_SIZE 18

@implementation MyView

- (QuartzFilter *)greyFilter
{
    static QuartzFilter *sFilter = nil;
    
    if (!sFilter)
    {
        NSArray *libraryPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSSystemDomainMask, YES);
        if ([libraryPaths count] > 0)
        {
            NSBundle *bundle = [NSBundle bundleWithPath:[[libraryPaths objectAtIndex:0]
                stringByAppendingPathComponent:@"Frameworks/Quartz.framework/Versions/A/Frameworks/QuartzFilters.framework"]];
            Class class = [bundle classNamed:@"QuartzFilter"];
            
            NSURL *url = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Gray" ofType:@"qfilter"]];
            sFilter = [class quartzFilterWithURL:url];
        }
    }
    
    return sFilter;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [NSGraphicsContext saveGraphicsState];
    
    if (self.image)
    {
        if (self.isGrey)
        {
            [[self greyFilter] applyToContext:[[NSGraphicsContext currentContext] CGContext]];
        }
        else
        {
            [[self greyFilter] removeFromContext:[[NSGraphicsContext currentContext] CGContext]];
        }
        
        [self.image drawInRect:self.bounds];
        
        [[NSColor yellowColor] set];
        NSRectFill(NSMakeRect(100, 100, 200, 200));
        
#define USE_GREY_COLORS
        
        if (self.isGrey)
        {
            CGContextRef myContext = [[NSGraphicsContext currentContext] CGContext];
            CGFloat components[] = {
#if defined(USE_GREY_COLORS)
                1, 0.5
#else
                1, 1, 1, 1
#endif
            };
            static const CGPatternCallbacks callbacks = {0, &MyDrawColoredPattern, NULL};
            
            CGContextSaveGState (myContext);

#if defined(USE_GREY_COLORS)
            const CGFloat whitePoint[] = {1, 1, 1};
            const CGFloat blackPoint[] = {0, 0, 0};
#endif
            
            CGColorSpaceRef patternSpace =
#if defined(USE_GREY_COLORS)
            // device-independent grayscale color
            CGColorSpaceCreatePattern(CGColorSpaceCreateCalibratedGray(whitePoint, blackPoint, 1));
#else
            CGColorSpaceCreatePattern(NULL);
#endif

            CGContextSetFillColorSpace(myContext, patternSpace);
            CGColorSpaceRelease(patternSpace);
            
            CGPatternRef pattern = CGPatternCreate(NULL,
                CGRectMake(0, 0, H_PSIZE, V_PSIZE),
                CGAffineTransformMake(1, 0, 0, 1, 0, 0),
                H_PATTERN_SIZE,
                V_PATTERN_SIZE,
                kCGPatternTilingConstantSpacing,
#if defined(USE_GREY_COLORS)
                false,
#else
                true,
#endif
                &callbacks);
            
            CGContextSetFillPattern(myContext, pattern, components);
            CGPatternRelease(pattern);
            CGContextFillRect(myContext, self.bounds);
            
            CGContextRestoreGState(myContext);
        }
    }
    else
    {
        [[NSColor yellowColor] set];
        NSRectFill(dirtyRect);
    }
    
    [NSGraphicsContext restoreGraphicsState];
}

- (void)mouseDown:(NSEvent *)theEvent
{
    [self lockFocus];
    
    NSBitmapImageRep* representation = [[NSBitmapImageRep alloc] initWithFocusedViewRect:self.bounds];
    
    [self unlockFocus];
    
    NSDictionary *imageProperties = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0] forKey:NSImageCompressionFactor];
    NSData *imageData = [representation representationUsingType:NSJPEGFileType properties:imageProperties];
    
    static int sCount = 0;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES);
    NSString *desktopPath = [paths objectAtIndex:0];
    NSString *fileName = [desktopPath stringByAppendingPathComponent:[NSString stringWithFormat:@"screenshot_%d.jpg", ++sCount]];
    
    [imageData writeToFile:fileName atomically:NO];
}

@end

void MyDrawColoredPattern(void *info, CGContextRef myContext)
{
    // the pattern cell itself is 16 by 18
    CGFloat subunit = 5;
    
    CGRect  myRect1 = {{0,0}, {subunit, subunit}},
    myRect2 = {{subunit, subunit}, {subunit, subunit}},
    myRect3 = {{0,subunit}, {subunit, subunit}},
    myRect4 = {{subunit,0}, {subunit, subunit}};
    
    CGContextSetFillColorWithColor(myContext, GetColor(0, 0, 1, 0.8));
    CGContextFillRect(myContext, myRect1);

    CGContextSetFillColorWithColor(myContext, GetColor(1, 0, 0, 0.8));
    CGContextFillRect (myContext, myRect2);

    CGContextSetFillColorWithColor(myContext, GetColor(0, 1, 0, 0.8));
    CGContextFillRect (myContext, myRect3);

    CGContextSetFillColorWithColor(myContext, GetColor(1, 0, 1, 0.8));
    CGContextFillRect (myContext, myRect4);
}

CGColorRef GetColor(CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha)
{
//#define USE_CONVERT_COLORS
#if defined(USE_GREY_COLORS) && defined(USE_CONVERT_COLORS)
    return CGColorCreateGenericGray(0.2126 * red + 0.7152 * green + 0.0722 * blue, alpha);
#else
    return CGColorCreateGenericRGB(red, green, blue, alpha);
#endif
}
