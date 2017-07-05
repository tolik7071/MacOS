//
//  main.m
//  ARCTest
//
//  Created by Anatoliy Goodz on 3/25/16.
//  Copyright (c) 2016 smk.private. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Client;

@interface Server : NSObject

@property (/*strong*/) Client *client;

@end


@implementation Server

- (void)dealloc
{
    NSLog(@"%s: %@", __FUNCTION__, [self class]);
}

@end

@interface Client : NSObject

@property (weak) Server *server;

@end

#pragma mark -

@implementation Client

- (void)dealloc
{
    NSLog(@"%s: %@", __FUNCTION__, [self class]);
}

@end

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        // 1. Do not use retain, release
        {
            NSString *someString = [[NSString alloc] initWithFormat:@"item #%d", 77];
            #pragma unused(someString)
//            [someString release];
        }
        
        // 2. Still use CFRetain, CFRelease
        {
            CFStringRef someString = CFStringCreateWithFormat(
                kCFAllocatorDefault,
                NULL,
                CFSTR("item #%d"),
                45);
            if (someString != NULL)
            {
                CFRelease(someString);
            }
        }
        
        // 3. Do not use object pointers in C structures
        {
            struct SomeData
            {
                int id;
//                NSString *name;
            };
        }
        
        // TODO: 4. No casual casting between id and void*
        {
            NSString *someString = [[NSString alloc] initWithFormat:@"item #%d", 55];
            #pragma unused(someString)
//            const void * pData = someString;
        }
        
        // 5. Do not use NSAutoreleasePool, use @autoreleasepool
        {
            
        }
        
        // TODO: 6. NSZone using
        {
            NSString *someString = [[NSString alloc] initWithFormat:@"item #%d", 12];
            NSString *otherString = [someString copyWithZone:nil];
            #pragma unused(otherString)
        }
        
        // 7. 'strong' and 'weak' qualifiers
        {
            Server *server = [Server new];
            Client *client = [Client new];
            
            server.client = client;
            client.server = server;
        }
        
        // 8.1 Bridge: CF -> NS
        {
            CFStringRef someString = CFStringCreateWithFormat(
                kCFAllocatorDefault,
                NULL,
                CFSTR("item #%d"),
                15);            
            if (someString)
            {
                // ownership not transfered
                NSString * someString2 = (__bridge NSString *)(someString);
                #pragma unused(someString2)
                CFRelease(someString);
            }
        }
        
        // 8.2 Bridge: NS -> CF
        {
            NSString *someString = [[NSString alloc] initWithFormat:@"item #%d", 14];
            
            CFStringRef someString2 = (__bridge_retained CFStringRef)someString;
            if (someString2)
            {
                CFRelease(someString2);
            }
        }
        
        // 8.1 Bridge: CF -> NS
        {
            CFStringRef someString = CFStringCreateWithFormat(
                kCFAllocatorDefault,
                NULL,
                CFSTR("item #%d"),
                19);
            NSString * someString2 = (__bridge_transfer NSString *)someString;
            #pragma unused(someString2)
        }
    }
    
    return 0;
}
