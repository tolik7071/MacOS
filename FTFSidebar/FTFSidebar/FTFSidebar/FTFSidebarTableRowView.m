//
//  FTFSidebarTableRowView.m
//  FTFSidebar
//
//  Created by Anatoliy Goodz on 9/17/18.
//  Copyright © 2018 Anatoliy Goodz. All rights reserved.
//

#import "FTFSidebarTableRowView.h"

@implementation FTFSidebarTableRowView

- (void)drawSelectionInRect:(NSRect)dirtyRect
{
    [[NSColor yellowColor] setFill];
    NSRectFill(dirtyRect);
}

@end
