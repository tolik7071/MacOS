//
//  ViewController.h
//  flip_view_test
//
//  Created by Anatoliy Goodz on 9/4/18.
//  Copyright © 2018 Anatoliy Goodz. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MyView.h"

@interface ViewController : NSViewController

@property (nonatomic, weak) IBOutlet MyView * leftView;
@property (nonatomic, weak) IBOutlet MyView * rightView;

@end

