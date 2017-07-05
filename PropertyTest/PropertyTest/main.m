//
//  main.m
//  PropertyTest
//
//  Created by Anatoliy Goodz on 1/20/17.
//  Copyright © 2017 Anatoliy Goodz. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark -

@interface XYZParent : NSObject

@property (nonatomic, assign, getter=isLinking) BOOL linking;

@end

@implementation XYZParent

- (void)setLinking:(BOOL)aFlag
{
    _linking = aFlag;
}

@end

#pragma mark -

@interface XYZChild : XYZParent

@end

@implementation XYZChild

//@synthesize linking = _linking;

- (BOOL)isLinking
{
    return [super isLinking];
}

- (void)setLinking:(BOOL)aFlag
{
    [super setLinking:aFlag];
}

@end

#pragma mark -

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        XYZChild *child = [[XYZChild alloc] init];
        NSLog(@"%s", [child isLinking] ? "YES" : "NO");
        [child setLinking:YES];
        NSLog(@"%s", [child isLinking] ? "YES" : "NO");
        
        NSLog(@"%s", child.linking ? "YES" : "NO");
        child.linking = NO;
        NSLog(@"%s", child.linking ? "YES" : "NO");
    }
    
    return 0;
}
