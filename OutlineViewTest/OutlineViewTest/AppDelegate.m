//
//  AppDelegate.m
//  OutlineViewTest
//
//  Created by Anatoliy Goodz on 3/20/15.
//  Copyright (c) 2015 smk.private. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
{
    NSArray *_rootElements;
}
@property (weak) IBOutlet NSWindow *window;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{    
    if (nil == _rootElements)
    {
        NSMutableArray *rootElements = [NSMutableArray array];
        for (int i = 0; i < 100; ++i)
        {
            if (i % 10 == 0)
            {
                [rootElements addObject:@[
                    @15, @558, @336, @99,
                    @15, @558, @336, @99,
                    @15, @558, @336, @99,
                    @15, @558, @336, @99,
                    @15, @558, @336, @99,
                    @15, @558, @336, @99,
                    @15, @558, @336, @99,
                    @15, @558, @336, @99,
                    @15, @558, @336, @99
                ]];
            }
            else
            {
                [rootElements addObject:[NSNumber numberWithInt:i]];
            }
        }
        
        _rootElements = [NSArray arrayWithArray:rootElements];
    }
    
    [(NSTableColumn *)[[self.myOutline tableColumns] objectAtIndex:0] setWidth:self.myOutline.superview.frame.size.width];
    [self.myOutline reloadData];
    [self.myOutline sizeLastColumnToFit];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
}

#pragma mark - NSOutlineViewDataSource -

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    NSInteger numberOfChildren = 0;
    
    if (item == nil)
    {
        numberOfChildren = _rootElements.count;
    }
    else
    {
        NSAssert([item isKindOfClass:[NSArray class]], @"Should be NSArray");
        numberOfChildren = [(NSArray *)item count];
    }
    
    return numberOfChildren;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    id result;
    
    if (nil == item)
    {
        result = [_rootElements objectAtIndex:index];
    }
    else
    {
        result = [(NSArray *)item objectAtIndex:index];
    }
    
    return result;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    NSString *result;
    
    if ([item isKindOfClass:[NSArray class]])
    {
        result = [NSString stringWithFormat:@"Some root element"];
    }
    else
    {
        result = [NSString stringWithFormat:@"---------- This is a child #%d ----------"
                  , [(NSNumber *)item intValue]];
    }
    
    return result;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    return [item isKindOfClass:[NSArray class]];
}

#pragma mark - NSOutlineViewDelegate -

//- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item
//{
//    return YES;
//}
//
//- (BOOL)selectionShouldChangeInOutlineView:(NSOutlineView *)outlineView
//{
//    return YES;    
//}

@end
