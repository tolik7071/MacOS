//
//  FTFTableView.m
//  FTFSidebar
//
//  Created by Anatoliy Goodz on 10/17/18.
//  Copyright © 2018 Anatoliy Goodz. All rights reserved.
//

#import "FTFTableView.h"
#import "FTFSidebarVisualAttributesManager.h"

@implementation FTFTableView

- (void)drawRect:(NSRect)dirtyRect
{
//    [super drawRect:dirtyRect];
    
    [[[FTFSidebarVisualAttributesManager sharedManager] background] setFill];
    NSRectFill(self.frame);
}

@end
