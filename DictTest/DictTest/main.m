//
//  main.m
//  DictTest
//
//  Created by Anatoliy Goodz on 7/8/16.
//  Copyright © 2016 Anatoliy Goodz. All rights reserved.
//

#import <Foundation/Foundation.h>

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
            @"x3" : @0,
            @"44" : @1,
            @"cc" : @2,
            @"aa" : @3,
            @"11" : @4,
            @111 : @5
        }];
        
        for (id key in dict)
        {
            NSLog(@"%@(%@) -> %lu", key, [dict objectForKey:key], [key hash]);
        }
    }
    
    return 0;
}
