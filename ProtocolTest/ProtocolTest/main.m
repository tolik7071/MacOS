//
//  main.m
//  ProtocolTest
//
//  Created by Anatoliy Goodz on 1/19/16.
//  Copyright (c) 2016 smk.private. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@protocol MyPrintable <NSObject>

- (void)print;

@end

@interface MyClass : NSObject <MyPrintable>

- (void)print;

@end

@implementation MyClass

- (void)print
{
    
}

@end

@interface MyClass2 : MyClass

@end

@implementation MyClass2

@end

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
//        MyClass *myClass = [MyClass new];
        
        unsigned int outCount = 0;
        Protocol * __unsafe_unretained * protocolList = class_copyProtocolList([MyClass2 class], &outCount);
        if (protocolList)
        {
            printf("%s supports:\n", [NSStringFromClass([MyClass2 class]) UTF8String]);
            for (unsigned int i = 0; i < outCount; ++i)
            {
                printf("\t%.2u: %s\n", i, protocol_getName(protocolList[i]));
            }
            free(protocolList);
        }
    }
    
    return 0;
}
