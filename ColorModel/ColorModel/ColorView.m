//
//  ColorView.m
//  ColorModel
//
//  Created by Anatoliy Goodz on 6/30/16.
//  Copyright © 2016 Anatoliy Goodz. All rights reserved.
//

#import "ColorView.h"
#import "Color.h"

#define radius 30.0

@implementation ColorView

- (void)drawRect:(CGRect)rect
{
    [self drawColorChoice:self.bounds];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self changeColorToTouch:[touches anyObject]];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self changeColorToTouch:[touches anyObject]];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self changeColorToTouch:[touches anyObject]];
}

- (void)changeColorToTouch:(UITouch *)aTouch
{
    [self changeColorToPoint:[aTouch locationInView:self]];
}

- (void)changeColorToPoint:(CGPoint)aPoint
{
    if (self.colorModel != nil)
    {
        if (CGRectContainsPoint(self.bounds, aPoint))
        {
            self.colorModel.hue = (aPoint.x - CGRectGetMinX(self.bounds))
                / CGRectGetWidth(self.bounds) * 360.0;
            self.colorModel.saturation = (aPoint.y - CGRectGetMinY(self.bounds))
                / CGRectGetHeight(self.bounds) * 100.0;
        }
    }
}

- (UIImage *)colorChoiceImage:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect bounds = CGRectMake(0.0, 0.0, size.width, size.height);
    
    [[UIColor clearColor] set];
    
    CGContextFillRect(context, bounds);
    
    CGRectInset(bounds, radius, radius);
    
    [self drawColorChoice:bounds];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)drawColorChoice:(CGRect)bounds
{
    if (self.colorModel != nil)
    {
        if (self.hsImage != nil &&
            (self.brightness != self.colorModel.brightness ||
             !CGSizeEqualToSize(bounds.size, self.hsImage.size)))
        {
            self.hsImage = nil;
        }
        
        if (self.hsImage == nil)
        {
            self.brightness = self.colorModel.brightness;
            
            UIGraphicsBeginImageContextWithOptions(bounds.size, YES, 1.0);
            
            {
                CGContextRef context = UIGraphicsGetCurrentContext();
                
                for (int y = 0; y < (int)(bounds.size.height); y++)
                {
                    for (int x = 0; x < (int)(bounds.size.width); x++)
                    {
                        UIColor *currentColor = [UIColor colorWithHue:((CGFloat)x / bounds.size.width)
                                                           saturation:((CGFloat)y / bounds.size.height)
                                                           brightness:((CGFloat)(self.brightness / 100.0))
                                                                alpha:1.0];
                        [currentColor set];
                        CGContextFillRect(context, CGRectMake(x, y, 1.0, 1.0));
                    }
                }
                
                self.hsImage = UIGraphicsGetImageFromCurrentImageContext();
            }
            
            UIGraphicsEndImageContext();
        }
        
        if (self.hsImage != nil)
        {
            [self.hsImage drawInRect:bounds];
        }
        
        CGRect circleRect = CGRectMake(CGRectGetMaxX(bounds) * (CGFloat)(self.colorModel.hue / 360.0) - radius / 2.0,
                                       CGRectGetMaxY(bounds) * (CGFloat)(self.colorModel.saturation / 100.0) - radius / 2.0,
                                       radius,
                                       radius);
        UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:circleRect];
        [self.colorModel.color setFill];
        [circlePath fill];
        circlePath.lineWidth = 3.0;
        [[UIColor blackColor] setStroke];
        [circlePath stroke];
    }
}

@end
