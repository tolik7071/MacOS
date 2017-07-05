//
//  MyView.m
//  NSComboBoxCell_Test
//
//  Created by Anatoliy Goodz on 2/5/16.
//  Copyright (c) 2016 smk.private. All rights reserved.
//

#import "MyView.h"

@interface MyView ()
{
    NSComboBoxCell *_cell;
}

@end

@implementation MyView

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
//    [[NSColor controlTextColor] setFill];
//    NSRectFill(dirtyRect);
    
    [[self cell] drawWithFrame:NSMakeRect(100, 100, 250, 22) inView:self];
}

- (NSCell *)cell
{
    if (_cell == nil)
    {
        _cell = [[NSComboBoxCell alloc] init];
        [_cell addItemsWithObjectValues:@[@"111", @"222", @"333"]];
        [_cell setObjectValue:@"222"];
    }
    
    return _cell;
}

- (IBAction)selectAction:(id)sender
{
    if ([[sender stringValue] isEqualToString:@"Disable"])
    {
        [self cell].enabled = NO;
    }
    else
    {
        [self cell].enabled = YES;
    }
    
    [self setNeedsDisplay:YES];
}

@end
