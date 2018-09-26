//
//  ChildView.m
//  ConstraintsTest
//
//  Created by Anatoliy Goodz on 9/26/18.
//  Copyright © 2018 Anatoliy Goodz. All rights reserved.
//

#import "ChildView.h"

@implementation ChildView

- (void)drawRect:(NSRect)dirtyRect
{
   [super drawRect:dirtyRect];

   [self.backgroundColor setFill];
   NSRectFill(dirtyRect);
}

@end
