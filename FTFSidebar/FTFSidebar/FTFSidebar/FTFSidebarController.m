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
#import "FTFSidebarVisualAttributesManager.h"
#import "FTFSidebarButtonCell.h"

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
    
    FTFSidebarVisualAttributesManager *manager = [FTFSidebarVisualAttributesManager sharedManager];
    
    NSColor *textColor = self.primary
        ? [manager textColorOfActivePrimaryItem]
        : [manager textColorOfSecondaryItem];
    
    NSFont *textFont = self.primary
        ? [manager fontOfPrimaryItem]
        : [manager fontOfSecondaryItem];
    
    NSAttributedString *title = [manager
        attributedStringForString:self.items[row].title
        foregroundColor:textColor
        font:textFont];
    cellView.toggleButton.attributedTitle = title;
    
    cellView.toggleButton.image = self.primary
        ? [manager primaryButtonBackground]
        : [manager secondaryButtonBackground];
    
    [(FTFSidebarButtonCell *)cellView.toggleButton.cell setPrimary:self.isPrimary];
    
    cellView.tableView = tableView;
    
    [self.cellViews addObject:cellView];
    
    NSView *previousView = nil;
    
    for (NSView * view in self.items[row].views)
    {
        NSPoint origin =
        {
            [self padding],
            previousView ? NSMaxY(previousView.frame) + [self padding] : [self padding]
        };
        
        [view setFrameOrigin:origin];
        
        [view setFrameSize:NSMakeSize(
            cellView.contentPlaceholder.frame.size.width - [self padding] * 2.0,
            view.frame.size.height)];
        
        [self addView:view toParentView:cellView.contentPlaceholder];
        
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
    
    CGFloat rowHeight = [self heightOfButton];
    
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

- (void)addView:(NSView *)view toParentView:(NSView *)parentView
{
    [parentView addSubview:view];
}

- (CGFloat)heightOfContentViewForRow:(NSInteger)row
{
    CGFloat rowHeight = [self heightOfButton];
    
    if (self.items[row].views.count > 0)
    {
        rowHeight += [self padding] * (self.items[row].views.count + 1);
    }
    
    for (NSView * view in self.items[row].views)
    {
        rowHeight += view.frame.size.height;
    }
    
    return rowHeight;
}

- (CGFloat)heightOfButton
{
    CGFloat height = self.primary
        ? [[FTFSidebarVisualAttributesManager sharedManager] primaryButtonHeight]
        : [[FTFSidebarVisualAttributesManager sharedManager] secondaryButtonHeight];
    
    return height;
}

- (CGFloat)padding
{
    CGFloat padding = self.primary
        ? [[FTFSidebarVisualAttributesManager sharedManager] primaryItemPadding]
        : [[FTFSidebarVisualAttributesManager sharedManager] secondaryItemPadding];
    
    return padding;
}

@end
