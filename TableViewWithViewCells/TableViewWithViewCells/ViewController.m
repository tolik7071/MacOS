//
//  ViewController.m
//  TableViewWithViewCells
//
//  Created by Anatoliy Goodz on 7/26/16.
//  Copyright © 2016 Anatoliy Goodz. All rights reserved.
//

#import "ViewController.h"
#import "MyItem.h"
#import "MyTableCellView.h"

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)setRepresentedObject:(id)representedObject
{
    [super setRepresentedObject:representedObject];
}

- (NSImage *)randomImage
{
    u_int32_t value = arc4random_uniform(2);
    NSString *imageName = (value == 0) ? @"tools-icon" : @"x-icon";
    NSImage *result = [NSImage imageNamed:imageName];
    assert(result);
    
    return result;
}

- (NSDictionary <NSString*, MyItem*> *)model
{
    static NSMutableDictionary <NSString*, MyItem*> *sModel = nil;
    
    if (sModel == nil)
    {
        sModel = [[NSMutableDictionary alloc] initWithDictionary:@{
            @"Group 1" : @[
                [[MyItem alloc] initWithImage:[self randomImage] andText:@"item 1"],
                [[MyItem alloc] initWithImage:[self randomImage] andText:@"item 2"],
                [[MyItem alloc] initWithImage:[self randomImage] andText:@"item 3"],
                [[MyItem alloc] initWithImage:[self randomImage] andText:@"item 4"]
            ],
            @"Group 2" : @[
                [[MyItem alloc] initWithImage:[self randomImage] andText:@"START dlaksjdlkasjdlkasjldksakfjhsakjfghldkafhleiuhfgiewugfliewgflkewgflkewgflkadsjkfhaslkjfhaskljhflkasjhflkuhwluhwluhfalkuhflkwahlkfuwhlauh END"]
            ],
        }];
        
        [self.outlineView reloadData];
    }
    
    return sModel;
}

#pragma mark - NSOutlineViewDataSource -

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(nullable id)item
{
    NSInteger result = 0;
    
    if (item == nil)
    {
        result = [self model].allKeys.count;
    }
    else
    {
        NSArray *childItems = (NSArray *)[[self model] objectForKey:item];
        result = childItems.count;
    }
    
    return result;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(nullable id)item
{
    id result;
    
    if (item == nil)
    {
        result = [[self model].allKeys objectAtIndex:index];
    }
    else
    {
        result = [(NSArray *)[[self model] objectForKey:item] objectAtIndex:index];
    }
    
    return result;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    BOOL result = NO;
    
    if ([item isKindOfClass:[NSString class]])
    {
        result = [(NSArray *)[[self model] objectForKey:item] count] != 0;
    }
    
    return result;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    id result;
    
    if ([item isKindOfClass:[NSString class]])
    {
        result = item;
    }
    else
    {
        result = item;
    }
    
    return result;
}

#pragma mark - NSOutlineViewDelegate -

/*
 
 NOTES:
 
 1. Height of MyTableCellView depends of a height of MAX(height : subviews) -
    -[NSView setFrameSize:] does not work.
 
 */
- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    MyTableCellView * view = [self.outlineView makeViewWithIdentifier:@"MyCellId" owner:self];
    assert(view != nil);
    
    if ([item isKindOfClass:[NSString class]])
    {
        [view.imageView removeFromSuperview];
        
        // TODO: fix constrains???
        NSLayoutConstraint *constraint = [view.textField.leftAnchor constraintEqualToAnchor:view.leftAnchor constant:10.0];
        constraint.active = YES;
        assert(constraint != nil);
        
        view.textField.stringValue = item;
    }
    else
    {
        view.textField.stringValue = [item stringValue];
        view.imageView.image = [(MyItem *)item image];
        view.backgroundColor = [NSColor yellowColor];
    }
    
    return view;
}

@end
