//
//  MyTableCellView.h
//  MySidebars
//
//  Created by Anatoliy Goodz on 9/13/18.
//  Copyright © 2018 Anatoliy Goodz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MyTableCellView : NSTableCellView

@property (nonatomic, weak) IBOutlet NSButton * hideOrShowButton;
@property (nonatomic, weak) IBOutlet NSBox * contentBox;
@property (nonatomic, weak) NSTableView * tableView;
@property (nonatomic) BOOL isExpanded;

@end
