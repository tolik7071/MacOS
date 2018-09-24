//
//  ContentView.m
//  FTFSidebar
//
//  Created by tolik7071 on 9/24/18.
//  Copyright © 2018 Anatoliy Goodz. All rights reserved.
//

#import "ContentView.h"

@implementation ContentView

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    [[NSColor lightGrayColor] setFill];
    NSRectFill(dirtyRect);
    
    [[NSColor redColor] setStroke];
    NSBezierPath * path = [NSBezierPath bezierPathWithRoundedRect:
        NSInsetRect(self.bounds, 2, 2) xRadius:10 yRadius:10];
    [path setLineWidth:1];
    [path stroke];
}

@end
