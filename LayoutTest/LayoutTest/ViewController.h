//
//  ViewController.h
//  LayoutTest
//
//  Created by Anatoliy Goodz on 12/21/16.
//  Copyright © 2016 Anatoliy Goodz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController

@property (weak) IBOutlet NSTextField* secondTextField;
@property (weak) IBOutlet NSBox* secondBox;

- (IBAction)hideMiddleLine:(id)sender;

@end

