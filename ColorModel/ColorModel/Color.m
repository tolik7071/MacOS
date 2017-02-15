//
//  Color.m
//  ColorModel
//
//  Created by Anatoliy Goodz on 6/24/16.
//  Copyright © 2016 Anatoliy Goodz. All rights reserved.
//

#import "Color.h"

@implementation Color

- (UIColor *)color
{
    return [UIColor colorWithHue:(self.hue / 360.0)
                      saturation:(self.saturation / 100.0)
                      brightness:(self.brightness / 100.0)
                           alpha:1.0];
}

+ (NSSet *)keyPathsForValuesAffectingColor
{
    return [NSSet setWithArray:@[@"hue", @"saturation", @"brightness"]];
}

@end
