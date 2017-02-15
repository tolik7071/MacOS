//
//  MyView.m
//  CheckBoxWithImage
//
//  Created by Anatoliy Goodz on 9/26/16.
//  Copyright © 2016 Anatoliy Goodz. All rights reserved.
//

#import "MyView.h"

@implementation MyView

- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor yellowColor] set];
    NSRectFill(dirtyRect);
    
//    NSButtonCell *cell = [[NSButtonCell alloc] initTextCell:@"Check it!"];
//    [cell setBezelStyle:NSRegularSquareBezelStyle];
//    [cell setButtonType:NSSwitchButton];
//    [cell setState:NSOnState];
    
//    [self.cell drawWithFrame:self.bounds inView:self];
}

@end
