//
//  AppDelegate.m
//  RadioButtonsTest
//
//  Created by Anatoliy Goodz on 1/25/17.
//  Copyright © 2017 Anatoliy Goodz. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (nonatomic, readonly) BOOL isChecked;
@property (nonatomic) NSMutableArray<NSButton* > *radioButtons;
@property (weak) IBOutlet NSMatrix *matrix;
@property (nonatomic) NSInteger selectedItem;
@property (nonatomic, readonly) BOOL isEnabled;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    _radioButtons = [[NSMutableArray alloc] init];
    
    for (NSView *view in self.window.contentView.subviews)
    {
        if ([view isKindOfClass:[NSStackView class]])
        {
            for (NSButton *button in view.subviews)
            {
                [self.radioButtons addObject:button];
                
                [button setTarget:self];
                [button setAction:@selector(onButtonClick:)];
            }
        }
    }
    
    [self.radioButtons sortUsingComparator:^NSComparisonResult(
        NSButton*  _Nonnull obj1, NSButton*  _Nonnull obj2)
        {
            NSComparisonResult result = (obj1.tag == obj2.tag) ? NSOrderedSame :
                (obj1.tag <= obj2.tag) ? NSOrderedAscending : NSOrderedDescending;
            
            return result;
        }
    ];
    
    self.radioButtons[2].enabled = NO;
    self.selectedItem = 1;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
}

- (BOOL)isChecked
{
    return YES;
}

- (BOOL)isEnabled
{
    return NO;
}

- (void)onButtonClick:(id)sender
{
    if ([(NSButton *)sender state] == NSOnState)
    {
        return;
    }
    
    [(NSButton *)sender setState:NSOnState];
    
    for (NSButton *button in self.radioButtons)
    {
        if (button != sender)
        {
            [(NSButton *)sender setState:NSOffState];
        }
    }
}

- (IBAction)onClick:(id)sender
{
    self.selectedItem = 2;
    [self.radioButtons[2] setTitle:@"Oops!"];
}

@end
