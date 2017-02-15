//
//  ViewController.h
//  ColorModel
//
//  Created by Anatoliy Goodz on 6/24/16.
//  Copyright © 2016 Anatoliy Goodz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Color;
@class ColorView;

@interface ViewController : UIViewController <UIActivityItemSource>

@property (strong, readonly) Color *colorModel;
@property (nonatomic, weak) IBOutlet ColorView *colorView;
@property (nonatomic, weak) NSString *rgbCode;

@property (nonatomic, weak) IBOutlet UILabel *hueLabel;
@property (nonatomic, weak) IBOutlet UILabel *saturationLabel;
@property (nonatomic, weak) IBOutlet UILabel *brightnessLabel;
@property (nonatomic, weak) IBOutlet UILabel *webLabel;

@property (nonatomic, weak) IBOutlet UISlider *hueSlider;
@property (nonatomic, weak) IBOutlet UISlider *saturationSlider;
@property (nonatomic, weak) IBOutlet UISlider *brightnessSlider;

@end
