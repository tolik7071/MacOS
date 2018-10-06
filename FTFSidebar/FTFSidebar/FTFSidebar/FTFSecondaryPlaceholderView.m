//
//  FTFSecondaryPlaceholderView.m
//  FTFSidebar
//
//  Created by Anatoliy Goodz on 10/5/18.
//  Copyright © 2018 Anatoliy Goodz. All rights reserved.
//

#import "FTFSecondaryPlaceholderView.h"
#import "FTFSidebarVisualAttributesManager.h"

@implementation FTFSecondaryPlaceholderView

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    FTFSidebarVisualAttributesManager *manager = [FTFSidebarVisualAttributesManager sharedManager];
    
    [[manager itemBackground] setFill];
    
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:self.bounds xRadius:3.0 yRadius:3.0];
    [path fill];
}

- (BOOL)isFlipped
{
    return YES;
}

@end
