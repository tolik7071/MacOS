//
//  ColorView.h
//  ColorModel
//
//  Created by Anatoliy Goodz on 6/30/16.
//  Copyright © 2016 Anatoliy Goodz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Color;

@interface ColorView : UIView

@property (nonatomic, weak) Color *colorModel;
@property (nonatomic, strong) UIImage *hsImage;
@property (nonatomic) CGFloat brightness;

- (UIImage *)colorChoiceImage:(CGSize)size;

@end
