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

/*
 
    tableView:heightOfRow:
    tableView:rowViewForRow:
    tableView:viewForTableColumn:row:
 
 */

- (nullable NSView *)tableView:(NSTableView *)tableView
            viewForTableColumn:(nullable NSTableColumn *)tableColumn
                           row:(NSInteger)row
{
    FTFTableCellView *cellView = [tableView makeViewWithIdentifier:kFTFTableCellViewID owner:self];
    cellView.toggleButton.title = self.items[row].title;
    cellView.tableView = tableView;
    
    [self.cellViews addObject:cellView];
    
    NSView *previousView = nil;
    
    for (NSView * view in self.items[row].views)
    {
        [view setFrameOrigin:NSMakePoint(
            cellView.contentPlaceholder.frame.size.width / 2.0 - view.frame.size.width / 2.0,
            previousView.frame.size.height + [FTFTableCellView padding])];
        
        [[self class] addView:view toParentView:cellView.contentPlaceholder];
        
        previousView = view;
    }
    
    return cellView;
}

- (nullable NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row
{
    return [[FTFSidebarTableRowView alloc] initWithFrame:NSZeroRect];
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    assert([tableView tableColumns].count == 1);
    
    CGFloat rowHeight = [FTFTableCellView heightOfToggleButton];
    
    if (self.cellViews.count == 0)
    {
        rowHeight = [self heightOfContentViewForRow:row];
    }
    else
    {
        if ([self.cellViews[row] isExpanded])
        {
            rowHeight = [self heightOfContentViewForRow:row];
        }
    }
    
    return rowHeight;
}

#pragma mark -

+ (void)addView:(NSView *)view toParentView:(NSView *)parentView
{
/*
    NSLayoutConstraint *constraint;

    constraint = [NSLayoutConstraint
        constraintWithItem:view
        attribute:NSLayoutAttributeWidth
        relatedBy:NSLayoutRelationEqual
        toItem:nil
        attribute:NSLayoutAttributeNotAnAttribute
        multiplier:view.frame.size.width
        constant:0.0];
    [view addConstraint:constraint];
    
    constraint = [NSLayoutConstraint
        constraintWithItem:view
        attribute:NSLayoutAttributeHeight
        relatedBy:NSLayoutRelationEqual
        toItem:nil
        attribute:NSLayoutAttributeNotAnAttribute
        multiplier:view.frame.size.height
        constant:0.0];
    [view addConstraint:constraint];
 
    constraint = [NSLayoutConstraint
        constraintWithItem:view
        attribute:NSLayoutAttributeCenterX
        relatedBy:NSLayoutRelationEqual
        toItem:parentView
        attribute:NSLayoutAttributeCenterX
        multiplier:1.0
        constant:0.0];
    [parentView addConstraint:constraint];
 */
    
    [parentView addSubview:view];
}

- (CGFloat)heightOfContentViewForRow:(NSInteger)row
{
    CGFloat rowHeight = [FTFTableCellView heightOfToggleButton];
    
    if (self.items[row].views.count > 0)
    {
        rowHeight += [FTFTableCellView padding] * (self.items[row].views.count + 1);
    }
    
    for (NSView * view in self.items[row].views)
    {
        rowHeight += view.frame.size.height;
    }
    
    return rowHeight;
}

@end
