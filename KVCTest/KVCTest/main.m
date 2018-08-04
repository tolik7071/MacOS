//
//  main.m
//  KVCTest
//
//  Created by Anatoliy Goodz on 6/27/18.
//  Copyright © 2018 Anatoliy Goodz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/objc-runtime.h>
#import "FTFScriptBuilder.h"

@interface MyClass : NSObject
{
    int _index;
    NSNumber *_value;
}

@property (nonatomic) NSString * title;

+ (double)pi;
- (double)div:(NSNumber *)first to:(double)second;

@end

@implementation MyClass

+ (double)pi
{
    return 3.14;
}

- (double)div:(NSNumber *)first to:(double)second
{
    return [first doubleValue] / second;
}

+ (double)div:(NSNumber *)first to:(NSNumber *)second
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
        
        typedef double(*TDivPtr)(id, SEL, id, double);
        TDivPtr div = (TDivPtr)[obj methodForSelector:@selector(div:to:)];
        printf("%f\n", div(obj, @selector(div:to:), [NSNumber numberWithDouble:10], (double)3));
        
        typedef double(*TDivClassPtr)(Class, SEL, id, id);
        TDivClassPtr TDivClass = (TDivClassPtr)[[obj class] methodForSelector:@selector(div:to:)];
        NSLog(@"!! %f", TDivClass([obj class], @selector(div:to:), @(3), @(9)));
        
//        NSLog(@"%s", [[NSNumber numberWithBool:YES] objCType]);
//        NSLog(@"%s", [[NSNumber numberWithInt:10] objCType]);
//        NSLog(@"%s", [[NSNumber numberWithDouble:0.555] objCType]);
//        NSLog(@"%s", [[NSNumber numberWithFloat:3.1415] objCType]);
        
        BOOL b = NO;
        NSNumber *number = [NSNumber numberWithBool:b];
        NSString *format = [NSString stringWithFormat:@"%%%s", [number objCType]];
        NSLog(format, [number boolValue]);
        
        assert([@"def=1" isEqualToString:[FTFScriptBuilder buildAssignmentUsingKey:@"def" value:@1]]);
        NSLog(@"%@", [FTFScriptBuilder buildAssignmentUsingKey:@"def" value:@[@1, @[@"abs", @4]]]);
        NSLog(@"%@", [FTFScriptBuilder buildAssignmentUsingKey:@"def2" value:@[@1, @{@"abs" : @4}]]);
        NSLog(@"%@", [FTFScriptBuilder buildAssignmentUsingKey:@"def3" value:@[@1, @{@"abs" : @[]}]]);
        NSLog(@"%@", [FTFScriptBuilder buildAssignmentUsingKey:@"def4" value:@[@1, @{@"abs" : @[@1, @4, @"sdaldk"]}]]);
        NSLog(@"%@", [FTFScriptBuilder buildAssignmentUsingKey:@"def4" value:@[@1, @{@"abs" : @[@1, @4, @{@1 : @10, @2 : @20}]}, @""]]);
        NSLog(@"%@", [FTFScriptBuilder buildAssignmentUsingKey:@"def5" value:@[]]);
        NSLog(@"%@", [FTFScriptBuilder buildAssignmentUsingKey:@"def5" value:@{}]);
        
        CGRect rect = { {-10.0, 20.0}, {100.0, 200.0} };
        NSValue *decodedRect = [[NSValue alloc] initWithBytes:&rect objCType:@encode(CGRect)];
        CGRect encodedRect = { {0.0, 0.0},{0.0, 0.0} };
        [decodedRect getValue:&encodedRect size:sizeof(CGRect)];
        NSLog(@"%f, %f, %f, %f", encodedRect.origin.x, encodedRect.origin.y,
              encodedRect.size.width, encodedRect.size.height);
    }
    
    return 0;
}
