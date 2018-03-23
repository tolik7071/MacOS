//
//  MyControl.m
//  ControlWithoutCll
//
//  Created by Anatoliy Goodz on 1/22/18.
//  Copyright © 2018 Anatoliy Goodz. All rights reserved.
//

#import "MyControl.h"

@implementation MyControl

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    [self.color setFill];
    NSRectFill(self.bounds);
}

- (BOOL)acceptsFirstMouse:(NSEvent *)anEvent
{
    return YES;
}

- (void)mouseDown:(NSEvent *)anEvent
{
    if (([anEvent clickCount] % 2) == 0)
    {
        [self sendAction:self.action to:self.target];
    }
}

@end
