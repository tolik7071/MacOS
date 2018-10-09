//
//  FTFTableCellView.h
//  FTFSidebar
//
//  Created by Anatoliy Goodz on 9/17/18.
//  Copyright © 2018 Anatoliy Goodz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSUserInterfaceItemIdentifier kFTFTableCellViewID;

@interface FTFTableCellView : NSTableCellView

@property (nonatomic, weak) IBOutlet NSButton * toggleButton;
@property (nonatomic, weak) IBOutlet NSView * contentPlaceholder;
@property (nonatomic, readonly) BOOL isExpanded;
@property (nonatomic, weak) NSTableView * tableView;

- (void)performClick:(nullable id)sender;

@end
