//
//  MyPreview.h
//  InscribeRectangle
//
//  Created by Anatoliy Goodz on 1/5/18.
//  Copyright © 2018 Anatoliy Goodz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MyPreview : NSView

@property (nonatomic) NSSize inscribedRectSize;

- (void)inscribe;

@end
