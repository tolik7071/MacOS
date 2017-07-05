//
//  AppDelegate.m
//  SystemColors
//
//  Created by Anatoliy Goodz on 12/21/15.
//  Copyright (c) 2015 smk.private. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (NSArray *)systemColorsSelectors
{
    static NSMutableArray *result = nil;
    
    if (result == nil)
    {
        result = [NSMutableArray arrayWithArray:@[
            @"blackColor",
            @"darkGrayColor",
            @"lightGrayColor",
            @"whiteColor",
            @"grayColor",
            @"redColor",
            @"greenColor",
            @"blueColor",
            @"cyanColor",
            @"yellowColor",
            @"magentaColor",
            @"orangeColor",
            @"purpleColor",
            @"brownColor",
            @"clearColor",
            @"controlShadowColor",
            @"controlDarkShadowColor",
            @"controlColor",
            @"controlHighlightColor",
            @"controlLightHighlightColor",
            @"controlTextColor",
            @"controlBackgroundColor",
            @"selectedControlColor",
            @"secondarySelectedControlColor",
            @"selectedControlTextColor",
            @"disabledControlTextColor",
            @"textColor",
            @"textBackgroundColor",
            @"selectedTextColor",
            @"selectedTextBackgroundColor",
            @"gridColor",
            @"keyboardFocusIndicatorColor",
            @"windowBackgroundColor",
            @"underPageBackgroundColor",
            @"labelColor",
            @"secondaryLabelColor",
            @"tertiaryLabelColor",
            @"quaternaryLabelColor",
            @"scrollBarColor",
            @"knobColor",
            @"selectedKnobColor",
            @"windowFrameColor",
            @"windowFrameTextColor",
            @"selectedMenuItemColor",
            @"selectedMenuItemTextColor",
            @"highlightColor",
            @"shadowColor",
            @"headerColor",
            @"headerTextColor",
            @"alternateSelectedControlColor",
            @"alternateSelectedControlTextColor" ]];
    }
    
    return result;
}

- (NSDictionary *)systemColors
{
    static NSMutableDictionary *result = nil;
    
    if (result == nil)
    {
        result = [NSMutableDictionary dictionary];
        
        for (NSString *colorSelector in [self systemColorsSelectors])
        {
            [result setObject:[[NSColor class] performSelector:NSSelectorFromString(colorSelector)]
                       forKey:colorSelector];
        }
        
        int index = 0;
        for (NSColor *color in [NSColor controlAlternatingRowBackgroundColors])
        {
            [result setObject:color
                       forKey:[NSString stringWithFormat:@"Alternating#%d", index++]];
        }
    }
    
    return result;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [[self systemColors] count];
}

- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row
{
    NSTextField *result = [[NSTextField alloc] initWithFrame:NSZeroRect];
    
    NSString *key = [[[self systemColors] allKeys] objectAtIndex:row];
    NSColor *value = [[[self systemColors] allValues] objectAtIndex:row];
    
    [result setStringValue:key];
    [result setBackgroundColor:value];
    if (! result.drawsBackground)
    {
        result.drawsBackground = YES;
    }
    
    return result;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    return 64.0;
}

@end
