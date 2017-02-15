//
//  main.m
//  DEPLOYMENT_TARGET_TEST
//
//  Created by Anatoliy Goodz on 4/14/16.
//  Copyright (c) 2016 smk.private. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
    MACOSX_DEPLOYMENT_TARGET = 10.7 do not work!
 */

//#if !defined(MACOSX_DEPLOYMENT_TARGET)
//
//#error !!!
//
//#endif

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        NSString *someString = @"Test string";
        if ([someString containsString:@"Test"])
        {
            NSLog(@"OK");
        }
    }
    
    return 0;
}
