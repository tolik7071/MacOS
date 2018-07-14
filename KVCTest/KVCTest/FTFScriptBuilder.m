//
//  FTFScriptBuilder.m
//  KVCTest
//
//  Created by Anatoliy Goodz on 7/12/18.
//  Copyright © 2018 Anatoliy Goodz. All rights reserved.
//

#import "FTFScriptBuilder.h"

@implementation FTFScriptBuilder

+ (NSString *)buildAssignmentUsingKey:(NSString *)key value:(id)value
{
    return [NSString stringWithFormat:@"%@=%@", key, [[self class] stringRepresentationOf:value]];
}

+ (NSMutableString *)stringRepresentationOf:(id)value
{
    NSMutableString *result = [NSMutableString new];
    
    if ([value isKindOfClass:[NSArray class]])
    {
        [result appendString:@"["];
        
        for (NSUInteger i = 0; i < [(NSArray *)value count]; ++i)
        {
            if (i != 0)
            {
                [result appendString:@", "];
            }
            
            [result appendFormat:@"%@", [[self class] stringRepresentationOf:[(NSArray *)value objectAtIndex:i]]];
        }
        
        [result appendString:@"]"];
    }
    else if ([value isKindOfClass:[NSDictionary class]])
    {
        [result appendString:@"{"];
        
        for (NSUInteger i = 0; i < [[(NSDictionary *)value allKeys] count]; ++i)
        {
            if (i != 0)
            {
                [result appendString:@", "];
            }
            
            id key = [[(NSDictionary *)value allKeys] objectAtIndex:i];
            
            [result appendFormat:@"%@ : %@"
             , [[self class] stringRepresentationOf:key]
             , [[self class] stringRepresentationOf:[(NSDictionary *)value objectForKey:key]]];
        }
        
        [result appendString:@"}"];
    }
    else
    {
        [result appendFormat:@"%@", value];
    }
    
    return result;
}

@end
