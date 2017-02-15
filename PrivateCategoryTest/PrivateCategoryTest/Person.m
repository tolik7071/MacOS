//
//  Person.m
//  PrivateCategoryTest
//
//  Created by Anatoliy Goodz on 4/27/16.
//  Copyright © 2016 Anatoliy Goodz. All rights reserved.
//

#import "Person.h"

@interface Person(Private)

// It seems getters/setters for properties in named categories do not generated automatically by the compiler (Objective-C 2.0).
@property (nonatomic) BOOL isMale;
@property (nonatomic) NSUInteger payment;

@end

@interface Person()

@property (nonatomic) NSDate* birthdate;

@end

@implementation Person (Private)

@dynamic isMale;

// Property 'payment' requires method 'payment' to be defined - use @dynamic or provide a method implementation in this category.
@dynamic payment;

@end


@implementation Person

- (BOOL)isMale
{
    return YES;
}

- (void)setIsMale:(BOOL)aFlag
{
    // _isMale - no such ivar
}

- (void)someMethod
{
    if(![self respondsToSelector:@selector(name)])
    {
        NSLog(@"%@ - no such method", NSStringFromSelector(@selector(name)));
    }
    
    if(![self respondsToSelector:@selector(isMale)])
    {
        NSLog(@"%@ - no such method", NSStringFromSelector(@selector(isMale)));
    }
    else
    {
        self.isMale = NO;
//        assert(self.isMale == NO);
    }
    
    if(![self respondsToSelector:@selector(birthdate)])
    {
        NSLog(@"%@ - no such method", NSStringFromSelector(@selector(birthdate)));
    }
    
    if(![self respondsToSelector:@selector(payment)])
    {
        NSLog(@"%@ - no such method", NSStringFromSelector(@selector(payment)));
    }
}

- (void)run
{
    [self someMethod];
}

@end
