//
//  MyViewController.h
//  MySidebars
//
//  Created by Anatoliy Goodz on 9/13/18.
//  Copyright © 2018 Anatoliy Goodz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol SidebarDataSource

- (NSArray <NSView * > *)sidebars;

@end

@interface MyViewController : NSViewController

@property (nonatomic, weak) IBOutlet NSTableView * tableView;
@property (nullable, nonatomic, weak) id<SidebarDataSource> dataSource;

@end
