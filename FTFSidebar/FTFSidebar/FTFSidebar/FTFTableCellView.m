//
//  FTFTableCellView.m
//  FTFSidebar
//
//  Created by Anatoliy Goodz on 9/17/18.
//  Copyright © 2018 Anatoliy Goodz. All rights reserved.
//

#import "FTFTableCellView.h"

NSUserInterfaceItemIdentifier kFTFTableCellViewID = @"FTFTableCellView";

@implementation FTFTableCellView

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
}

- (BOOL)isExpanded
{
    return !self.contentPlaceholder.hidden;
}

- (IBAction)hideOrShowContent:(id)sender
{
    self.contentPlaceholder.hidden = !self.contentPlaceholder.hidden;
    
    [self.tableView noteHeightOfRowsWithIndexesChanged:
        [NSIndexSet indexSetWithIndex:[self.tableView rowForView:self]]];
}

- (BOOL)isFlipped
{
    return YES;
}

+ (CGFloat)heightOfToggleButton
{
    return 71.0;
}

@end
