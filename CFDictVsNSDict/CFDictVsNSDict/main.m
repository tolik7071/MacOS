//
//  main.m
//  CFDictVsNSDict
//
//  Created by Anatoliy Goodz on 3/16/16.
//  Copyright © 2016 Anatoliy Goodz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyClass : NSObject

- (instancetype)initWithName:(NSString *)aName;
@property (nonatomic, retain) NSString *name;

@end

@implementation MyClass

- (instancetype)initWithName:(NSString *)aName
{
    self = [super init];
    if (self)
    {
        _name = [aName retain];
    }
    
    return self;
}

- (void)dealloc
{
    NSLog(@"%s: %@", __FUNCTION__, [self description]);
    
    [super dealloc];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%p: %@", self, self.name];
}

@end

int main(int argc, const char * argv[])
{
    NSString *key = @"";
    
    @autoreleasepool
    {
        MyClass *someObject = [[MyClass alloc] initWithName:@"#1"];
        NSDictionary *dict = @{ key : someObject };
#pragma unused(dict)
        [someObject release];
    }
    
#define USE_DEFAULT_CALLBACKS
    
    @autoreleasepool
    {
        MyClass *someObject = [[MyClass alloc] initWithName:@"#2"];
        CFDictionaryRef dict = CFDictionaryCreate(
            NULL,
            (const void **)&key,
            (const void **)&someObject,
            1,
#if defined(USE_DEFAULT_CALLBACKS)
            &kCFTypeDictionaryKeyCallBacks,
            &kCFTypeDictionaryValueCallBacks
#else
            NULL,
            NULL
#endif
        );
        
        [someObject release];
        
        CFRelease(dict);
    }
    
    return 0;
}
