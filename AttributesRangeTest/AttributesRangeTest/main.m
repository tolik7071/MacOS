//
//  main.m
//  AttributesRangeTest
//
//  Created by Anatoliy Goodz on 8/17/16.
//  Copyright © 2016 Anatoliy Goodz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        NSString *someText = @"This is a simple string!";
        NSDictionary *attr1 = @{
            NSFontAttributeName : [NSFont systemFontOfSize:28],
            NSForegroundColorAttributeName : [NSColor redColor]
        };
        NSDictionary *attr2 = @{
            NSFontAttributeName : [NSFont boldSystemFontOfSize:14],
            NSBackgroundColorAttributeName : [NSColor yellowColor]
        };
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:someText];
        
        [attributedString setAttributes:attr1 range:NSMakeRange(0, 4)];
        [attributedString setAttributes:attr2 range:NSMakeRange(5, 11)];
        [attributedString setAttributes:attr1 range:NSMakeRange(17, 6)];
        
        {
            NSRange effectiveRange = {0, 0};
            [attributedString attributesAtIndex:1 effectiveRange:&effectiveRange];
            printf("Effective Range = %lu %lu\n", effectiveRange.location, effectiveRange.length);
        }
        
        {
            NSRange effectiveRange = {0, 0};
            [attributedString attributesAtIndex:1 longestEffectiveRange:&effectiveRange inRange:NSMakeRange(0, attributedString.string.length)];
            printf("Longest Effective Range = %lu %lu\n", effectiveRange.location, effectiveRange.length);
        }
    }

    return 0;
}
