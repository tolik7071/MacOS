//
//  ViewController.m
//  PrintingTest
//
//  Created by Anatoliy Goodz on 6/9/18.
//  Copyright © 2018 Anatoliy Goodz. All rights reserved.
//

#import "ViewController.h"
#import <ApplicationServices/ApplicationServices.h>

#define LOG_METHOD() NSLog(@"%s", __PRETTY_FUNCTION__)

@implementation ViewController

- (void)viewDidLoad
{
   [super viewDidLoad];
}

#pragma mark - Printing -

- (IBAction)print:(id)sender
{
   LOG_METHOD();

   [[NSPrintPanel printPanel] beginSheetWithPrintInfo:[NSPrintInfo sharedPrintInfo]
                                       modalForWindow:self.view.window
                                             delegate:self
                                       didEndSelector:@selector(doPrint:)
                                          contextInfo:NULL];
}

- (void)doPrint:(id)sender
{

}

- (IBAction)runPageLayout:(id)sender
{
   LOG_METHOD();

   NSInteger result = [[NSPageLayout pageLayout] runModal];
   if (NSModalResponseOK == result)
   {
      NSLog(@"%@", [NSPrintInfo sharedPrintInfo]);
   }
}

@end
