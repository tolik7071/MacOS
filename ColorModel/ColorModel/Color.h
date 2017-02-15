//
//  Color.h
//  ColorModel
//
//  Created by Anatoliy Goodz on 6/24/16.
//  Copyright © 2016 Anatoliy Goodz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Color : NSObject

@property (nonatomic) CGFloat hue;
@property (nonatomic) CGFloat saturation;
@property (nonatomic) CGFloat brightness;

@property (nonatomic) UIColor *color;

@end
