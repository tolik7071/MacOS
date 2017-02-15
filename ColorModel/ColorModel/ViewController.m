//
//  ViewController.m
//  ColorModel
//
//  Created by Anatoliy Goodz on 6/24/16.
//  Copyright © 2016 Anatoliy Goodz. All rights reserved.
//

#import "ViewController.h"
#import "Color.h"
#import "ColorView.h"

@interface ViewController ()
{
    Color *_colorModel;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.colorView.colorModel = self.colorModel;
    
    [self.colorModel addObserver:self
                      forKeyPath:@"hue"
                         options:NSKeyValueObservingOptionNew
                         context:nil];
    [self.colorModel addObserver:self
                      forKeyPath:@"saturation"
                         options:NSKeyValueObservingOptionNew
                         context:nil];
    [self.colorModel addObserver:self
                      forKeyPath:@"brightness"
                         options:NSKeyValueObservingOptionNew
                         context:nil];
    [self.colorModel addObserver:self
                      forKeyPath:@"color"
                         options:NSKeyValueObservingOptionNew
                         context:nil];
    
    self.colorModel.hue = 60;
    self.colorModel.saturation = 50;
    self.colorModel.brightness = 100;
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath
                      ofObject:(nullable id)object
                        change:(nullable NSDictionary<NSString*, id> *)change
                       context:(nullable void *)context
{
    if ([keyPath isEqualToString:@"hue"])
    {
        self.hueLabel.text = [NSString stringWithFormat:@"%0.f°", self.colorModel.hue];
        self.hueSlider.value = self.colorModel.hue;
    }
    else if ([keyPath isEqualToString:@"saturation"])
    {
        self.saturationLabel.text = [NSString stringWithFormat:@"%0.f%%", self.colorModel.saturation];
        self.saturationSlider.value = self.colorModel.saturation;
    }
    else if ([keyPath isEqualToString:@"brightness"])
    {
        self.brightnessLabel.text = [NSString stringWithFormat:@"%0.f%%", self.colorModel.brightness];
        self.brightnessSlider.value = self.colorModel.brightness;
    }
    else if ([keyPath isEqualToString:@"color"])
    {
        self.webLabel.text = self.rgbCode;
        
        self.webLabel.backgroundColor = self.colorModel.color;
        
        [self.colorView setNeedsDisplay];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator
{
    [self.colorView setNeedsDisplay];
}

- (Color *)colorModel
{
    if (_colorModel == nil)
    {
        _colorModel = [Color new];
    }
    
    return _colorModel;
}

- (IBAction)changeHue:(id)sender
{
    if ([sender isKindOfClass:[UISlider class]])
    {
        self.colorModel.hue = [(UISlider *)sender value];
    }
}

- (IBAction)changeSaturation:(id)sender
{
    if ([sender isKindOfClass:[UISlider class]])
    {
        self.colorModel.saturation = [(UISlider *)sender value];
    }
}

- (IBAction)changeBrightness:(id)sender
{
    if ([sender isKindOfClass:[UISlider class]])
    {
        self.colorModel.brightness = [(UISlider *)sender value];
    }
}

- (IBAction)share:(id)sender
{
    NSString *shareMessage = [NSString stringWithFormat:@"I wrote an iOS app to share a color! RGB=%@", self.rgbCode];
    UIImage *shareImage = [self.colorView colorChoiceImage:CGSizeMake(380.0, 160.0)];
    NSURL *shareURL = [NSURL URLWithString:@"http://www.learniosappdev.com/"];
    
    NSArray *itemsToShare = @[self, shareImage, shareURL];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc]
        initWithActivityItems:itemsToShare applicationActivities:nil];
    
    activityViewController.excludedActivityTypes = @[UIActivityTypeAssignToContact,UIActivityTypePrint];
    
    UIPopoverPresentationController *popover = activityViewController.popoverPresentationController;
    if (popover != nil)
    {
        popover.barButtonItem = sender;
    }
    
    [self presentViewController:activityViewController animated:YES completion:nil];
}

- (NSString *)rgbCode
{
    CGFloat red = .0, green = .0, blue = .0, alpha = .0;
    [self.colorModel.color getRed:&red green:&green blue:&blue alpha:&alpha];
    
    return [NSString stringWithFormat:@"#%02X%02X%02X%02X"
        , (NSUInteger)(red * 255.0)
        , (NSUInteger)(green * 255.0)
        , (NSUInteger)(blue * 255.0)
        , (NSUInteger)(alpha * 255.0)];
}

// called to determine data type. only the class of the return type is consulted.
// it should match what -itemForActivityType: returns later
- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
{
    return @"My color message goes here.";
}

// called to fetch data after an activity is selected. you can return nil.
- (nullable id)activityViewController:(UIActivityViewController *)activityViewController
                  itemForActivityType:(NSString *)activityType
{
    NSString *message;
    
    if ([activityType isEqualToString:UIActivityTypePostToTwitter] ||
        [activityType isEqualToString:UIActivityTypePostToWeibo])
    {
        message = [NSString stringWithFormat:@"Today's color is RGB=%@.I wrote an iOS "
                   "app to do this! @LearniOSAppDev", self.rgbCode];
    }
    else if([activityType isEqualToString:UIActivityTypeMail])
    {
        message = [NSString stringWithFormat:@"Hello,\n\nI wrote an awesome iOS app that "
                   "lets me share a color   with my friends.\n\n"
                   "Here's my color (see attachment): "
                   "hue=%f°, "
                   "saturation=%f%%, "
                   "brightness=%f%%.\n\n"
                   "If you like it, use the HTML code %@ in your design.\n\nEnjoy,\n\n",
                   self.colorModel.hue, self.colorModel.saturation, self.colorModel.brightness,
                   self.rgbCode];
    }
    else
    {
        message = [NSString stringWithFormat:@"I wrote a great iOS app to share this color: %@", self.rgbCode];
    }

    return message;
}

@end
