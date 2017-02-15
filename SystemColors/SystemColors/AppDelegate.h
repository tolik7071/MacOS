//
//  AppDelegate.h
//  SystemColors
//
//  Created by Anatoliy Goodz on 12/21/15.
//  Copyright (c) 2015 smk.private. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

- (NSArray *)systemColorsSelectors;
- (NSDictionary *)systemColors;

@end

