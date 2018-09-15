//
//  MyViewController.m
//  MySidebars
//
//  Created by Anatoliy Goodz on 9/13/18.
//  Copyright © 2018 Anatoliy Goodz. All rights reserved.
//

#import "MyViewController.h"
#import "MyTableCellView.h"
#import "MyTableRowView.h"

typedef NSMutableArray <MyTableCellView * > * TCellViewsArray;

@interface MyViewController ()
{
    TCellViewsArray _cellViews;
}

@end

@implementation MyViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    assert(self.tableView);
    
    [self.tableView reloadData];
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return 3;
}

- (nullable id)tableView:(NSTableView *)tableView
    objectValueForTableColumn:(nullable NSTableColumn *)tableColumn
    row:(NSInteger)row
{
    return @"";
}

#pragma mark - NSTableViewDelegate

- (nullable NSView *)tableView:(NSTableView *)tableView
            viewForTableColumn:(nullable NSTableColumn *)tableColumn
                           row:(NSInteger)row
{
    MyTableCellView *cellView = [self.tableView makeViewWithIdentifier:@"headerCellView" owner:self];
    cellView.tableView = tableView;
    [[self cellViews] insertObject:cellView atIndex:row];
    
    return cellView;
}

- (nullable NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row
{
    return [[MyTableRowView alloc] initWithFrame:NSZeroRect];
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    return [tableView rowHeight];
}

- (TCellViewsArray)cellViews
{
    if (!_cellViews)
    {
        _cellViews = [NSMutableArray new];
    }
    
    return _cellViews;
}

@end
