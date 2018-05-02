//
//  ViewController.m
//  CoreTextTest
//
//  Created by tolik7071 on 4/28/18.
//  Copyright © 2018 tolik7071. All rights reserved.
//

#import "ViewController.h"
#import "CoreTextView.h"

#define LOG_METHOD() NSLog(@"%p: %s", self, __PRETTY_FUNCTION__)

@implementation ViewController

#pragma mark - Font -

- (IBAction)changeFont:(id)sender
{
    LOG_METHOD();
    
    NSFont *oldFont = [(CoreTextView *)self.view font];
    NSFont *newFont = [sender convertFont:oldFont];
    [(CoreTextView *)self.view setFont:newFont];
    [self.view setNeedsDisplay:YES];
}

- (IBAction)changeAttributes:(nullable id)sender
{
    LOG_METHOD();
    NSDictionary *attributes = [sender convertAttributes:[(CoreTextView *)self.view attributes]];
    [(CoreTextView *)self.view setAttributes:attributes];
    [self.view setNeedsDisplay:YES];
}

- (IBAction)changeColor:(id)sender
{
    LOG_METHOD();
}

- (IBAction)underline:(id)sender
{
    LOG_METHOD();
}

#pragma mark - Kern -

- (IBAction)useStandardKerning:(id)sender
{
    LOG_METHOD();
}

- (IBAction)turnOffKerning:(id)sender
{
    LOG_METHOD();
}

- (IBAction)tightenKerning:(id)sender
{
    LOG_METHOD();
}

- (IBAction)loosenKerning:(id)sender
{
    LOG_METHOD();
}

#pragma mark - Ligatures -

- (IBAction)useStandardLigatures:(id)sender
{
    LOG_METHOD();
}

- (IBAction)turnOffLigatures:(id)sender
{
    LOG_METHOD();
}

- (IBAction)useAllLigatures:(id)sender
{
    LOG_METHOD();
}

#pragma mark - Baseline -

- (IBAction)unscript:(id)sender
{
    LOG_METHOD();
}

- (IBAction)superscript:(id)sender
{
    LOG_METHOD();
}

- (IBAction)subscript:(id)sender
{
    LOG_METHOD();
}

- (IBAction)raiseBaseline:(id)sender
{
    LOG_METHOD();
}

- (IBAction)lowerBaseline:(id)sender
{
    LOG_METHOD();
}

#pragma mark - Copy/paste style -

- (IBAction)copyFont:(id)sender
{
    LOG_METHOD();
}

- (IBAction)pasteFont:(id)sender
{
    LOG_METHOD();
}

#pragma mark - Text -

- (IBAction)alignLeft:(id)sender
{
    LOG_METHOD();
}

- (IBAction)alignCenter:(id)sender
{
    LOG_METHOD();
}

- (IBAction)alignJustified:(id)sender
{
    LOG_METHOD();
}

- (IBAction)alignRight:(id)sender
{
    LOG_METHOD();
}

@end
