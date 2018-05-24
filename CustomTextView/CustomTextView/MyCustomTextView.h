//
//  MyCustomTextView.h
//  CustomTextView
//
//  Created by Anatoliy Goodz on 5/17/18.
//  Copyright © 2018 Anatoliy Goodz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MyCustomTextView : NSView

@property (nonatomic) NSMutableAttributedString * text;
@property (nonatomic) NSRange selectedRange;
@property (nonatomic) NSRange markedRange;

@end
