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
{
    BOOL _firstCall;
}

@property (nonatomic) NSMutableArray <FTFTableCellView * > * cellViews;

@end

@implementation FTFSidebarController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _firstCall = YES;
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
            
            NSRect secondaryViewFrame =
            {
                {
                    [self padding],
                    previousView ? NSMaxY(previousView.frame) + [self padding] : [self padding]
                },
                {
                    [self rowWidth] - [self padding] * 2.0,
                    [self heightOfSecondaryButton]
                        + 2.0
                        + [self paddingForSecondaryElement] * 2.0
                        + childView.frame.size.height
                }
            };
            
            itemView = [[FTFSecondaryItemView alloc] initWithFrame:secondaryViewFrame];
            [(FTFSecondaryItemView *)itemView setTitle:sidebarItem.title];
            [(FTFSecondaryItemView *)itemView setParentCellView:cellView];
            
            NSRect childViewRect =
            {
                {
                    [self paddingForSecondaryElement],
                    [self paddingForSecondaryElement]
                },
                {
                    secondaryViewFrame.size.width - [self paddingForSecondaryElement] * 2.0,
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
                    [self rowWidth] - [self padding] * 2.0,
                    itemView.frame.size.height + [self padding] * 2.0
                }
            };
            
            NSRect itemViewFrame =
            {
                {
                    [self paddingForSecondaryElement],
                    [self paddingForSecondaryElement]
                },
                {
                    backgroundFrame.size.width - [self paddingForSecondaryElement] * 2,
                    itemView.frame.size.height
                }
            };
            
            [itemView setFrame:itemViewFrame];
            
            backgroundView = [[FTFItemBackgroundView alloc]
                initWithFrame:backgroundFrame];
            
            [backgroundView addSubview:itemView];
        }
        
//        [cellView.contentPlaceholder addSubview:backgroundView];
        [self addView:backgroundView
            toParentView:cellView.contentPlaceholder
            usingLastSiblingView:previousView];
        
        previousView = backgroundView;
    }
    
    if (_firstCall)
    {
        _firstCall = NO;
        [cellView performClick:self];
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
            rowHeight += [self heightOfCellView:self.cellViews[row]];
        }
    }
    
    NSLog(@"%2.f", rowHeight);
    
    return rowHeight;
}

- (void)addView:(NSView *)childView
    toParentView:(NSView *)parentView
    usingLastSiblingView:(NSView *)siblingView
{
    assert(childView && parentView);
    
    [parentView addSubview:childView];
    
/*
    NSLayoutConstraint *constraint;
    
    constraint = [NSLayoutConstraint
        constraintWithItem:childView
        attribute:NSLayoutAttributeTop
        relatedBy:NSLayoutRelationEqual
        toItem:(siblingView ? siblingView : parentView)
        attribute:NSLayoutAttributeTop
        multiplier:1.0
        constant:20.0];
    [parentView addConstraint:constraint];
 */
}

- (CGFloat)heightOfCellView:(FTFTableCellView *)cellView
{
    assert(cellView);
    
    CGFloat height = 0;
    
    NSView *previousView = nil;
    
    for (NSView *itemView in cellView.contentPlaceholder.subviews)
    {
        NSPoint newOrigin =
        {
            [self padding],
            previousView ? NSMaxY(previousView.frame) + [self padding] : [self padding]
        };
        
        [itemView setFrameOrigin:newOrigin];
        
        previousView = itemView;
    }
    
    [cellView.contentPlaceholder setFrameSize:
        NSMakeSize(
            cellView.contentPlaceholder.frame.size.width,
            NSMaxY(previousView.frame) + [self padding]
                  )
    ];
    
    height += cellView.contentPlaceholder.frame.size.height;
    
    return height;
}

#pragma mark -

- (CGFloat)rowWidth
{
    CGFloat rowWidth = [[self.tableView tableColumns][0] width];

    return rowWidth;
}

- (CGFloat)heightOfContentViewForRow:(NSInteger)row
{
    CGFloat rowHeight = 0;
    
    if (self.items[row].items.count > 0)
    {
        rowHeight += [self padding] * (self.items[row].items.count + 1);
    }
    
    for (id item in self.items[row].items)
    {
        NSView *itemView = nil;
        
        if ([item isKindOfClass:[NSView class]])
        {
            itemView = (NSView *)item;
            rowHeight += [self padding] * 2.0;
        }
        else
        {
            assert([item isKindOfClass:[FTFSidebarItem class]]);
            itemView = [[(FTFSidebarItem *)item items] firstObject];
            
            rowHeight += [self heightOfSecondaryButton];
            rowHeight += 2.0;
            rowHeight += [self paddingForSecondaryElement] * 2.0;
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

- (CGFloat)heightOfSecondaryButton
{
    CGFloat padding = [[FTFSidebarVisualAttributesManager sharedManager] secondaryButtonHeight];
    
    return padding;
}

- (CGFloat)paddingForSecondaryElement
{
    CGFloat padding = [[FTFSidebarVisualAttributesManager sharedManager] secondaryItemPadding];
    
    return padding;
}

@end
