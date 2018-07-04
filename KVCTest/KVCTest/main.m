//
//  main.m
//  KVCTest
//
//  Created by Anatoliy Goodz on 6/27/18.
//  Copyright © 2018 Anatoliy Goodz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/objc-runtime.h>

@interface MyClass : NSObject
{
    int _index;
    NSNumber *_value;
}

@property (nonatomic) NSString * title;

+ (double)pi;
- (double)div:(NSNumber *)first to:(NSNumber *)second;

@end

@implementation MyClass

+ (double)pi
{
    return 3.14;
}

- (double)div:(NSNumber *)first to:(NSNumber *)second
{
    return [first doubleValue] / [second doubleValue];
}

@end

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        MyClass *obj = [MyClass new];
        
        [obj setValue:[NSNumber numberWithInt:10] forKey:@"index"];
        [obj setValue:[NSNumber numberWithInt:-10] forKey:@"value"];
        [obj setValue:@"WOW!" forKey:@"title"];
        
        unsigned int ivarsCount = 0;
        Ivar *ivars = class_copyIvarList([obj class], &ivarsCount);
        for (unsigned int i = 0; i < ivarsCount; ++i)
        {
            printf("%s\n", ivar_getName(ivars[i]));
        }
        
        SEL sel = NSSelectorFromString(@"pi");
        BOOL isOk = [[obj class] respondsToSelector:sel];
        assert(isOk);
        
//        id res = [[obj class] performSelector:sel];
//        NSLog(@"%@\n", res);
        typedef double(*TFunction)(void);
        TFunction getPi = (TFunction)[[obj class] methodForSelector:sel];
        printf("%f\n", getPi());
        
        id ups;
        NSLog(@"%@", [ups class]);
        
        unsigned int methodsCount = 0;
        Method *methods = class_copyMethodList([obj class], &methodsCount);
        for (unsigned int i = 0; i < methodsCount; ++i)
        {
            printf("%s\n", [NSStringFromSelector(method_getName(methods[i])) UTF8String]);
        }
        
        typedef double(*TDivPtr)(id, SEL, id, id);
        TDivPtr div = (TDivPtr)[obj methodForSelector:@selector(div:to:)];
        printf("%f\n", div(obj, @selector(div:to:), [NSNumber numberWithDouble:10], [NSNumber numberWithDouble:3]));
    }
    
    return 0;
}
