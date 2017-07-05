//
//  TestWindowController.m
//  WindowStyleIssue
//
//  Created by Anatoliy Goodz on 3/5/15.
//  Copyright (c) 2015 smk.private. All rights reserved.
//

#import "TestWindowController.h"

@interface TestWindowController ()

@end

@implementation TestWindowController

- (BOOL)isInModalModel
{
    return ([NSApp modalWindow] != nil);
}

- (IBAction)close:(id)aSender {

    if (! aSender)
    {
        return;
    }
    
    if ([self isInModalModel])
    {
        // Dialog
        [NSApp stopModal];
    }
    else
    {
        // Sheet
        [NSApp endSheet:self.window];
    }

    [super close];
}

@end
