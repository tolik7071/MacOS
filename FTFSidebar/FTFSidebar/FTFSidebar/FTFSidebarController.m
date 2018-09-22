//
//  FTFSidebarController.m
//  FTFSidebar
//
//  Created by Anatoliy Goodz on 9/17/18.
//  Copyright © 2018 Anatoliy Goodz. All rights reserved.
//

#import "FTFSidebarController.h"
#import "FTFTableCellView.h"
#import "FTFSidebarTableRowView.h"

@implementation FTFSidebarItem

- (instancetype)initWithTitle:(NSString *)title
{
    self = [super init];
    
    if (self)
    {
        _title = title;
    }
    
    return self;
}

@end

@interface FTFSidebarController ()

@property (nonatomic, weak) IBOutlet NSTableView * tableView;
@property (nonatomic) NSMutableArray <FTFTableCellView * > * cellViews;

@end

@implementation FTFSidebarController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (NSMutableArray <FTFTableCellView * > *)cellViews
{
    if (!_cellViews)
    {
        _cellViews = [NSMutableArray new];
    }
    
    return _cellViews;
}

- (NSMutableArray <FTFSidebarItem * > *)items
{
    if (!_items)
    {
        _items = [NSMutableArray new];
    }
    
    return _items;
}

- (void)reload
{
    [self.tableView reloadData];
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.items.count;
}

- (nullable id)tableView:(NSTableView *)tableView
    objectValueForTableColumn:(nullable NSTableColumn *)tableColumn
    row:(NSInteger)row
{
    return self.items[row];
}

#pragma mark - NSTableViewDelegate

- (nullable NSView *)tableView:(NSTableView *)tableView
            viewForTableColumn:(nullable NSTableColumn *)tableColumn
                           row:(NSInteger)row
{
    FTFTableCellView *cellView = [tableView makeViewWithIdentifier:kFTFTableCellViewID owner:self];
    cellView.toggleButton.title = self.items[row].title;
    cellView.tableView = tableView;
    
    [self.cellViews addObject:cellView];
    
    for (NSView * view in self.items[row].views)
    {
        [[self class] addView:view toParentView:cellView.contentPlaceholder];
    }
    
    return cellView;
}

- (nullable NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row
{
    return [[FTFSidebarTableRowView alloc] initWithFrame:NSZeroRect];
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    CGFloat rowHeight = [FTFTableCellView heightOfToggleButton];
    
    if (self.cellViews.count == 0)
    {
        for (NSView * view in self.items[row].views)
        {
//            rowHeight += 20.0;
            rowHeight += view.frame.size.height;
        }
    }
    else
    {
        for (FTFTableCellView * cellView in self.cellViews)
        {
            if (cellView.isExpanded)
            {
                rowHeight += cellView.contentPlaceholder.frame.size.height;
            }
        }
    }
    
    return rowHeight;
}

#pragma mark -

+ (void)addView:(NSView *)view toParentView:(NSView *)parentView
{
    [parentView addSubview:view];
}

@end
