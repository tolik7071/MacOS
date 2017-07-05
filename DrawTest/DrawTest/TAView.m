//
//  TAView.m
//  DrawTest
//
//  Created by Anatoliy Goodz on 8/20/14.
//  Copyright (c) 2014 Anatoliy Goodz. All rights reserved.
//

#import "TAView.h"

@implementation TAView

@synthesize image = _image;

- (id)initWithFrame:(NSRect)frame
{
   self = [super initWithFrame:frame];
   if (self)
   {
      // Initialization code here.
      self.drawImage = YES;
   }
   
   return self;
}

- (void)dealloc
{
   [_image release];
   
   [super dealloc];
}

- (NSImage*)image
{
   if (! _image)
   {
      NSURL *imageURL = [[NSBundle mainBundle] URLForResource:@"picture" withExtension:@"jpg"];
      _image = [[NSImage alloc] initWithContentsOfURL:imageURL];
   }
   
   return _image;
}

- (void)viewWillStartLiveResize
{
   self.drawImage = NO;
}

- (void)viewDidEndLiveResize
{
   self.drawImage = YES;
   [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect
{
#define OFFSET 15.0f
   
   [super drawRect:dirtyRect];
/*
   {
      [[NSColor redColor] setStroke];
      [[NSColor blueColor] setFill];
      NSBezierPath *path = [NSBezierPath bezierPathWithRect:NSInsetRect(self.bounds, OFFSET, OFFSET)];
      [path setLineWidth:3.0f];
      [path fill];
      [path stroke];
   }
   
   {
      NSBezierPath *path = [NSBezierPath bezierPathWithRect:NSInsetRect(self.bounds, OFFSET, OFFSET)];
      [path addClip];
   }
   
   {
      if (self.drawImage)
      {
         [[NSGraphicsContext currentContext] saveGraphicsState];
         
         NSAffineTransform* transform = [NSAffineTransform transform];
         [transform translateXBy:(self.bounds.size.width / 2.0f) yBy:0.0f];
         [transform rotateByDegrees:45.0f];
         [transform concat];
         
         [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
         
         [self.image drawInRect:NSInsetRect(self.bounds, 50.0f, 50.0f)
                       fromRect:NSMakeRect(0.0f, 0.0f, self.image.size.width, self.image.size.height)
                      operation:NSCompositeSourceOver
                       fraction:1.0f];
         
         [[NSGraphicsContext currentContext] restoreGraphicsState];
      }
   }
   
   {
      NSGradient* gradient = [[[NSGradient alloc]
                                initWithStartingColor:[NSColor orangeColor]
                                endingColor:[NSColor cyanColor]] autorelease];
      [gradient drawFromCenter:NSMakePoint(200.0f, 200.0f)
                        radius:100.0f
                      toCenter:NSMakePoint(150.0f, 200.0f)
                        radius:0.0f
                       options:0];
   }
   
   {
      NSShadow* shadow = [[[NSShadow alloc] init] autorelease];
      [shadow setShadowOffset:NSMakeSize(OFFSET / 2.0, - (OFFSET / 2.0f))];
      [shadow setShadowBlurRadius:2.0f];
      [shadow setShadowColor:[[NSColor yellowColor] colorWithAlphaComponent:0.5f]];
      [shadow set];
      
      NSString *text = @"This is a simple text.";
      NSFont *font = [NSFont fontWithName:@"Zapfino" size:50.0f];
      NSDictionary *attributes = @{
          NSFontAttributeName : font,
          NSForegroundColorAttributeName : [NSColor yellowColor]
      };
      
      NSAttributedString *stringWithAttributes = [[[NSAttributedString alloc]
                                        initWithString:text
                                        attributes:attributes] autorelease];
      [stringWithAttributes drawAtPoint:NSMakePoint(300.0f, 200.0f)];
   }
 */

    {
        NSString *text = @"Difference between means = 1.46";
        NSFont *font = [NSFont systemFontOfSize:12.0];
        NSParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        NSDictionary *attributes = @{
            NSFontAttributeName : font,
            NSForegroundColorAttributeName : [NSColor redColor],
            NSParagraphStyleAttributeName : style
        };
        
        NSAttributedString *stringWithAttributes = [[[NSAttributedString alloc]
            initWithString:text attributes:attributes] autorelease];
        [stringWithAttributes drawAtPoint:NSMakePoint(300.0f, 200.0f)];
        NSLog(@"SYSTEM %@ %f", stringWithAttributes.string, stringWithAttributes.size.width);
    }
    {
        NSString *text = @"Difference between means = 1.46";
        NSFont *font = [NSFont userFontOfSize:12.0];
        NSParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        NSDictionary *attributes = @{
                                     NSFontAttributeName : font,
                                     NSForegroundColorAttributeName : [NSColor redColor],
                                     NSParagraphStyleAttributeName : style
                                     };
        
        NSAttributedString *stringWithAttributes = [[[NSAttributedString alloc]
                                                     initWithString:text attributes:attributes] autorelease];
        [stringWithAttributes drawAtPoint:NSMakePoint(300.0f, 200.0f)];
        NSLog(@"USER %@ %f", stringWithAttributes.string, stringWithAttributes.size.width);
    }
}

-  (void)mouseDown:(NSEvent *)theEvent
{
   [self lockFocus];
   
   NSBitmapImageRep* representation = [[NSBitmapImageRep alloc] initWithFocusedViewRect:self.bounds];
   
   [self unlockFocus];
   
   NSDictionary *imageProperties = [NSDictionary dictionaryWithObject:
      [NSNumber numberWithFloat:1.0] forKey:NSImageCompressionFactor];
   NSData *imageData = [representation representationUsingType:NSJPEGFileType properties:imageProperties];
   
   static int sCount = 0;
   
   NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES);
   NSString *desktopPath = [paths objectAtIndex:0];
   NSString *fileName = [desktopPath stringByAppendingPathComponent:
      [NSString stringWithFormat:@"screenshot_%d.jpg", ++sCount]];
   
   [imageData writeToFile:fileName atomically:NO];
}

@end
