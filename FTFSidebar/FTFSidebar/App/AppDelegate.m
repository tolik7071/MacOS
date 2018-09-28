//
//  AppDelegate.m
//  FTFSidebar
//
//  Created by Anatoliy Goodz on 9/17/18.
//  Copyright © 2018 Anatoliy Goodz. All rights reserved.
//

#import "AppDelegate.h"
#import "FTFSidebarController.h"
#import "DataViewController.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (nonatomic, weak) IBOutlet NSView * placeholder;
@property (nonatomic) DataViewController * dataViewController;

@property (nonatomic) FTFSidebarController * sidebarController;

@end

@implementation AppDelegate

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    assert(_placeholder);
    
    [self loadSidebar];
    assert(_sidebarController && _sidebarController.view);
    
    [self.placeholder addSubview:self.sidebarController.view];
    
    {
        NSLayoutConstraint *constraint = [NSLayoutConstraint
            constraintWithItem:self.sidebarController.view
            attribute:NSLayoutAttributeLeading
            relatedBy:NSLayoutRelationEqual
            toItem:self.placeholder
            attribute:NSLayoutAttributeLeading
            multiplier:1.0
            constant:0.0];
        [self.placeholder addConstraint:constraint];
    }
    
    {
        NSLayoutConstraint *constraint = [NSLayoutConstraint
            constraintWithItem:self.sidebarController.view
            attribute:NSLayoutAttributeTop
            relatedBy:NSLayoutRelationEqual
            toItem:self.placeholder
            attribute:NSLayoutAttributeTop
            multiplier:1.0
            constant:0.0];
        [self.placeholder addConstraint:constraint];
    }
    
    {
        NSLayoutConstraint *constraint = [NSLayoutConstraint
            constraintWithItem:self.sidebarController.view
            attribute:NSLayoutAttributeTrailing
            relatedBy:NSLayoutRelationEqual
            toItem:self.placeholder
            attribute:NSLayoutAttributeTrailing
            multiplier:1.0
            constant:0.0];
        [self.placeholder addConstraint:constraint];
    }
    
    {
        NSLayoutConstraint *constraint = [NSLayoutConstraint
            constraintWithItem:self.sidebarController.view
            attribute:NSLayoutAttributeBottom
            relatedBy:NSLayoutRelationEqual
            toItem:self.placeholder
            attribute:NSLayoutAttributeBottom
            multiplier:1.0
            constant:0.0];
        [self.placeholder addConstraint:constraint];
    }
    
    [self loadData];
}

- (void)loadSidebar
{
    if (!_sidebarController)
    {
        _sidebarController = [[FTFSidebarController alloc]
            initWithNibName:@"FTFSidebarController" bundle:nil];
        _sidebarController.primary = YES;
    }
}

- (void)loadData
{
    if (!_dataViewController)
    {
        _dataViewController = [[DataViewController alloc]
            initWithNibName:@"DataViewController" bundle:nil];
        assert(_dataViewController.view);
        
        FTFSidebarItem *item = [[FTFSidebarItem alloc] initWithTitle:@"THIS IS A TEST."];
        item.views = @[_dataViewController.view];
        
        [[self.sidebarController items] addObject:item];
        
        [self.sidebarController reload];
    }
}

@end
