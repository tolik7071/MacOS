//
//  AppDelegate.m
//  ComboboxText
//
//  Created by Anatoliy Goodz on 9/30/15.
//  Copyright (c) 2015 smk.private. All rights reserved.
//

#import "AppDelegate.h"

@interface PSXComboBoxCell : NSComboBoxCell

@end

@implementation PSXComboBoxCell

- (void) setEnabled:(BOOL)flag
{
    [super setEnabled:flag];
}

@end


@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
//    [self.combobox setCell:[[PSXComboBoxCell alloc] init]];
//    [[self.combobox cell] setFont:[NSFont systemFontOfSize:25]];
//    [[self.combobox cell] setTextColor:[NSColor redColor]];
//    [[self.combobox cell] setUsesDataSource:YES];
//    [[self.combobox cell] setDataSource:self];
//    [[self.combobox cell] setEnabled:NO];
    
    [self.combobox setUsesDataSource:YES];
    [self.combobox setDataSource:self];
    
    NSMatrix *matrix = [[NSMatrix alloc] initWithFrame:NSMakeRect(20, 20, 300, 20)
                                                  mode:NSTrackModeMatrix
                                             cellClass:[PSXComboBoxCell class]
                                          numberOfRows:1
                                       numberOfColumns:2];
    [(NSView *)self.window.contentView addSubview:matrix];
    PSXComboBoxCell *cell = [matrix cellAtRow:0 column:0];
    [cell setUsesDataSource:YES];
    [cell setDataSource:self];
    cell = [matrix cellAtRow:0 column:1];
    [cell setEnabled:NO];
    [cell setStringValue:@"dsdsads"];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox
{
    return 5;
}

- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index
{
    NSAttributedString *result = [[NSAttributedString alloc]
        initWithString:[NSString stringWithFormat:@"Item #%ld", (long)index]
        attributes:@{
            NSForegroundColorAttributeName :
                ((index % 2 != 0) ? [NSColor redColor] : [NSColor blueColor])
//            [NSColor controlTextColor]
            , NSFontAttributeName : [NSFont systemFontOfSize:(index + 10)]
        }];
    
    return result;
}

- (NSInteger)numberOfItemsInComboBoxCell:(NSComboBoxCell *)comboBoxCell
{
    return 5;
}

- (id)comboBoxCell:(NSComboBoxCell *)aComboBoxCell objectValueForItemAtIndex:(NSInteger)index
{

    NSAttributedString *result = [[NSAttributedString alloc]
        initWithString:[NSString stringWithFormat:@"Item #%ld", (long)index]
        attributes:@{
            NSForegroundColorAttributeName :
            ((index % 2 != 0) ? [NSColor redColor] : [NSColor blueColor])
            //            [NSColor controlTextColor]
            , NSFontAttributeName : [NSFont systemFontOfSize:(index + 10)]
        }];
    
    return result;
}

@end
