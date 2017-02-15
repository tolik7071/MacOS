//
//  MyColorView.m
//  SystemColors
//
//  Created by Anatoliy Goodz on 12/21/15.
//  Copyright (c) 2015 smk.private. All rights reserved.
//

#import "MyColorView.h"
#import "AppDelegate.h"

@implementation MyColorView

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    NSLog(@"%@" , [[[NSApp delegate] systemColors] description]);
    
    [[NSColor yellowColor] set];
    NSRectFill(self.bounds);
}

@end
