//
//  ViewController.h
//  MovableResizableTextField
//
//  Created by Anatoliy Goodz on 7/24/18.
//  Copyright © 2018 Anatoliy Goodz. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FTFGraphicView.h"

@interface ViewController : NSViewController <FTFGraphicToolsSelection>

@property (nonatomic, weak) IBOutlet FTFGraphicView * graphicView;
@property (nonatomic, weak) IBOutlet NSSegmentedControl * currentGraphicTool;

@end
