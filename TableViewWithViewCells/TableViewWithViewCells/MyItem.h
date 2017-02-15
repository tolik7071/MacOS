//
//  MyItem.h
//  TableViewWithViewCells
//
//  Created by Anatoliy Goodz on 7/26/16.
//  Copyright © 2016 Anatoliy Goodz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyItem : NSObject

@property (nonatomic, retain, readonly) NSImage *image;
@property (nonatomic, retain, readonly) NSAttributedString *text;

- (instancetype)initWithImage:(NSImage *)anImage andText:(NSString *)aText;
- (NSString *)stringValue;

@end
