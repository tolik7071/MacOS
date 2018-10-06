//
//  FTFSecondaryItemView.h
//  FTFSidebar
//
//  Created by Anatoliy Goodz on 10/3/18.
//  Copyright © 2018 Anatoliy Goodz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class FTFTableCellView;

@interface FTFSecondaryItemView : NSView

@property (nonatomic, readonly) BOOL isExpanded;
@property (nonatomic, weak) FTFTableCellView * parentCellView;
@property (nonatomic) NSView * contentPlaceholder;

- (void)setTitle:(NSString *)title;

@end
