//
//  FTFSidebarController.h
//  FTFSidebar
//
//  Created by Anatoliy Goodz on 9/17/18.
//  Copyright © 2018 Anatoliy Goodz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FTFSidebarItem : NSObject

@property (nonatomic) NSString * title;
@property (nonatomic) NSArray <NSView *> * views;

- (instancetype)initWithTitle:(NSString *)title;

@end

@interface FTFSidebarController : NSViewController

@property (nonatomic) NSMutableArray <FTFSidebarItem * > * items;

- (void)reload;

@property (nonatomic, getter=isPrimary) BOOL primary;

@property (nonatomic) NSImage * titleImage;
@property (nonatomic) NSFont * titleFont;
@property (nonatomic) NSColor * titleColor;

@property (nonatomic) NSColor * contentBackground;

@end
