//
//  main.m
//  PrivateCategoryTest
//
//  Created by Anatoliy Goodz on 4/27/16.
//  Copyright © 2016 Anatoliy Goodz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Person.h"

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        Person *person = [Person new];
        [person run];
    }
    
    return 0;
}
