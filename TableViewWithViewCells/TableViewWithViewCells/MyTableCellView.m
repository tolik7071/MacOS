//
//  MyTableCellView.m
//  TableViewWithViewCells
//
//  Created by Anatoliy Goodz on 7/29/16.
//  Copyright © 2016 Anatoliy Goodz. All rights reserved.
//

#import "MyTableCellView.h"

@implementation MyTableCellView

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    if (self.backgroundColor != nil)
    {
        NSRect rectToFill = NSOffsetRect(self.bounds, 0.0, 1.0);
        [self.backgroundColor setFill];
        NSRectFill(rectToFill);
    }
}

@end
