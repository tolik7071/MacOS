//
//  MyItem.m
//  TableViewWithViewCells
//
//  Created by Anatoliy Goodz on 7/26/16.
//  Copyright © 2016 Anatoliy Goodz. All rights reserved.
//

#import "MyItem.h"

@implementation MyItem

- (instancetype)initWithImage:(nullable NSImage *)anImage andText:(NSString *)aText
{
    self = [super init];
    
    if (self != nil)
    {
        _image = anImage;
        _text = [[NSAttributedString alloc] initWithString:aText];
    }
    
    return self;
}

- (NSString *)stringValue
{
    return self.text.string;
}

@end
