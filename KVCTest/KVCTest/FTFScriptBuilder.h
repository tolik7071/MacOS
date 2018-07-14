//
//  FTFScriptBuilder.h
//  KVCTest
//
//  Created by Anatoliy Goodz on 7/12/18.
//  Copyright © 2018 Anatoliy Goodz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FTFScriptBuilder : NSObject

+ (NSString *)buildAssignmentUsingKey:(NSString *)key value:(id)value;

@end
