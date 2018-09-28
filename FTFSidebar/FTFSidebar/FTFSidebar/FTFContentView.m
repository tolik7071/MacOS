//
//  ContentView.m
//  FTFSidebar
//
//  Created by tolik7071 on 9/24/18.
//  Copyright © 2018 Anatoliy Goodz. All rights reserved.
//

#import "FTFContentView.h"
#import "FTFSidebarVisualAttributesManager.h"

@implementation FTFContentView

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    [[[FTFSidebarVisualAttributesManager sharedManager] background] setFill];
    NSRectFill(dirtyRect);
}

@end
