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
#import "FTFItemBackgroundView.h"
#import "FTFSecondaryItemView.h"

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
    
    NSColor *textColor = [manager textColorOfActivePrimaryItem];
    
    NSFont *textFont = [manager fontOfPrimaryItem];
    
    NSAttributedString *title = [manager
        attributedStringForString:self.items[row].title
        foregroundColor:textColor
        font:textFont];
    cellView.toggleButton.attributedTitle = title;
    
    cellView.toggleButton.image = [manager primaryButtonBackground];
    
    cellView.tableView = tableView;
    
    [self.cellViews addObject:cellView];
    
    NSView *previousView = nil;
    
    for (id item in self.items[row].items)
    {
        NSView *itemView = nil;
        
        if ([item isKindOfClass:[NSView class]])
        {
            itemView = (NSView *)item;
        }
        else
        {
            FTFSidebarItem *sidebarItem = (FTFSidebarItem *)item;
            assert(sidebarItem.items.count == 1);
            
            NSView *childView = (NSView *)sidebarItem.items.firstObject;
            
            FTFSidebarVisualAttributesManager *manager = [FTFSidebarVisualAttributesManager sharedManager];
            
            NSRect secondaryViewFrame =
            {
                {
                    [self padding],
                    previousView ? NSMaxY(previousView.frame) + [self padding] : [self padding]
                },
                {
                    cellView.contentPlaceholder.frame.size.width - [self padding] * 2.0,
                    childView.frame.size.height
                        + [manager secondaryItemPadding] * 2.0
                        + [manager primaryButtonHeight]
                        + 2.0
                }
            };
            
            itemView = [[FTFSecondaryItemView alloc] initWithFrame:secondaryViewFrame];
            [(FTFSecondaryItemView *)itemView setTitle:sidebarItem.title];
            [(FTFSecondaryItemView *)itemView setParentCellView:cellView];
            
            NSRect childViewRect =
            {
                {
                    [manager secondaryItemPadding],
                    [manager secondaryItemPadding]
                },
                {
                    secondaryViewFrame.size.width - [manager secondaryItemPadding] * 2.0,
                    childView.frame.size.height
                }
            };

            [childView setFrame:childViewRect];

            [[(FTFSecondaryItemView *)itemView contentPlaceholder] addSubview:childView];
        }
        
        NSView *backgroundView = nil;
        
        if ([itemView isKindOfClass:[FTFSecondaryItemView class]])
        {
            backgroundView = itemView;
        }
        else
        {
            NSRect backgroundFrame =
            {
                {
                    [self padding],
                    previousView ? NSMaxY(previousView.frame) + [self padding] : [self padding]
                },
                {
                    cellView.contentPlaceholder.frame.size.width - [self padding] * 2.0,
                    itemView.frame.size.height + [self padding] * 2.0
                }
            };
            
            NSRect itemViewFrame =
            {
                {
                    [self padding],
                    [self padding]
                },
                {
                    backgroundFrame.size.width - [self padding] * 2,
                    itemView.frame.size.height
                }
            };
            
            [itemView setFrame:itemViewFrame];
            
            backgroundView = [[FTFItemBackgroundView alloc]
                initWithFrame:backgroundFrame];
            
            [backgroundView addSubview:itemView];
        }
        
        [cellView.contentPlaceholder addSubview:backgroundView];
        
        previousView = backgroundView;
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
        rowHeight += [self heightOfContentViewForRow:row];
    }
    else
    {
        if ([self.cellViews[row] isExpanded])
        {
            rowHeight += [self heightOfContentViewForRow:row];
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
    CGFloat rowHeight = 0;
    
    if (self.items[row].items.count > 0)
    {
        rowHeight += [self padding] * (3 * self.items[row].items.count + 1);
    }
    
    for (id item in self.items[row].items)
    {
        NSView *itemView = nil;
        
        if ([item isKindOfClass:[NSView class]])
        {
            itemView = (NSView *)item;
        }
        else
        {
            itemView = [[(FTFSidebarItem *)item items] firstObject];
        }
        
        rowHeight += itemView.frame.size.height;
    }
    
    return rowHeight;
}

- (CGFloat)heightOfButton
{
    CGFloat height = [[FTFSidebarVisualAttributesManager sharedManager] primaryButtonHeight];
    
    return height;
}

- (CGFloat)padding
{
    CGFloat padding = [[FTFSidebarVisualAttributesManager sharedManager] primaryItemPadding];
    
    return padding;
}

@end
