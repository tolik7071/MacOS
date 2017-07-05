//
//  main.m
//  IncludeObjCTest
//
//  Created by Anatoliy Goodz on 7/28/16.
//  Copyright © 2016 Anatoliy Goodz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Common.h"
#import "MyTest.h"

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        MyTest *test = [[MyTest alloc] initWithSheetKind:kPSXGraphSheet];
        NSLog(@"%@", [test description]);
    }
    return 0;
}
