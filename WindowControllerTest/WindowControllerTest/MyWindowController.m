//
//  MyWindowController.m
//  WindowControllerTest
//
//  Created by Anatoliy Goodz on 10/30/15.
//  Copyright (c) 2015 smk.private. All rights reserved.
//

#import "MyWindowController.h"

@interface MyWindowController ()

- (void)hideUtilityPanels;
- (void)showUtilityPanels;

@end

@implementation MyWindowController

- (instancetype)init
{
    NSLog(@"%s: %p", __FUNCTION__, self);
    self = [super initWithWindowNibName:[self nibName]];
    return self;
}

- (NSString *)nibName
{
    return @"MyWindowController";
}

- (void)dealloc
{
    NSLog(@"%s: %p", __FUNCTION__, self);
    [super dealloc];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
}

- (NSInteger)showWindowModal
{    
    NSWindow *keyWindow = [NSApp keyWindow];
    [keyWindow endEditingFor:[keyWindow firstResponder]];
    
    [self window];
    
    [self hideUtilityPanels];
    
    return [NSApp runModalForWindow:[self window]];
}

- (IBAction)closeMe:(id)sender
{
    [self showUtilityPanels];
    [NSApp stopModalWithCode:NSOKButton];
    [[self window] close];
}

- (void)hideUtilityPanels
{
    if ([NSColorPanel sharedColorPanelExists] && [[NSColorPanel sharedColorPanel] isVisible])
    {
        self.colorPanelIsVisible = YES;
        [[NSColorPanel sharedColorPanel] orderOut:self];
    }
    else
    {
        self.colorPanelIsVisible = NO;
    }
}

- (void)showUtilityPanels
{
    if (self.colorPanelIsVisible)
    {
        if (![[NSColorPanel sharedColorPanel] isVisible])
        {
            [[NSColorPanel sharedColorPanel] orderFront:self];
        }
    }
    else if ([NSColorPanel sharedColorPanelExists] &&
             [[NSColorPanel sharedColorPanel] isVisible])
    {
        [[NSColorPanel sharedColorPanel] orderOut:self];
    }
}

@end
