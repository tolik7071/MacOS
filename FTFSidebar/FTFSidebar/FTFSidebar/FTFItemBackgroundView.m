//
//  FTFItemBackgroundView.m
//  FTFSidebar
//
//  Created by Anatoliy Goodz on 10/1/18.
//  Copyright © 2018 Anatoliy Goodz. All rights reserved.
//

#import "FTFItemBackgroundView.h"
#import "FTFSidebarVisualAttributesManager.h"

@implementation FTFItemBackgroundView

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    [[[FTFSidebarVisualAttributesManager sharedManager] itemBackground] setFill];
    
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:self.bounds xRadius:3.0 yRadius:3.0];
    [path fill];
}

@end
