//
//  MyTableCellView.m
//  MySidebars
//
//  Created by Anatoliy Goodz on 9/13/18.
//  Copyright © 2018 Anatoliy Goodz. All rights reserved.
//

#import "MyTableCellView.h"

@implementation MyTableCellView

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    [[NSColor yellowColor] setFill];
    NSRectFill(dirtyRect);
}

- (BOOL)isFlipped
{
    return YES;
}

- (IBAction)hideOrShowContent:(id)sender
{
    self.contentBox.hidden = !self.contentBox.hidden;
    
    [self.tableView noteHeightOfRowsWithIndexesChanged:
        [NSIndexSet indexSetWithIndex:[self.tableView rowForView:self]]];
}

- (BOOL)isExpanded
{
    return !self.contentBox.hidden;
}

@end
