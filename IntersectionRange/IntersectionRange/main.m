//
//  main.m
//  IntersectionRange
//
//  Created by Anatoliy Goodz on 3/12/15.
//  Copyright (c) 2015 smk.private. All rights reserved.
//

#import <Foundation/Foundation.h>

NSRange PSXUnionRangeNew(NSRange aLeftRange, NSRange aRightRange)
{
    NSRange range;
    
    range.location = MIN(aLeftRange.location, aRightRange.location);
    range.length = MAX(NSMaxRange(aLeftRange), NSMaxRange(aRightRange)) - range.location;

    return range;
}

NSRange PSXUnionRangeOld(NSRange iRange1, NSRange iRange2)
{
    NSRange retVal;
    
    if (!iRange1.length)
    {
        return iRange2;
    }
    
    if (!iRange2.length)
    {
        return iRange1;
    }
    
    retVal.location = MIN(iRange1.location, iRange2.location);
    retVal.length = MAX(iRange1.location + iRange1.length, 
        iRange2.location + iRange2.length) - retVal.location;
    
    return retVal;
}

NSRange PSXIntersectionRangeNew(NSRange aLeftRange, NSRange aRightRange)
{
    NSRange range = { .0, .0 };
    
    if (!(NSMaxRange(aLeftRange) < aRightRange.location || NSMaxRange(aRightRange) < aLeftRange.location))
    {
        range.location = MAX(aLeftRange.location, aRightRange.location);
        range.length = MIN(NSMaxRange(aLeftRange), NSMaxRange(aRightRange)) - range.location;
    }
    
    return range;
}

NSRange PSXIntersectionRangeOld(NSRange range1, NSRange range2)
{
    NSRange result;
    result.location = MAX(range1.location, range2.location);
    result.length = MIN(
        range1.length - MIN(range1.length, (result.location - range1.location)), 
        range2.length - MIN(range2.length, (result.location - range2.location)));
    
    return result;
}

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        NSRange r1 = { 17, 12 }, r2 = { 1, 8 };
        NSRange result = { 0, 0 };
        
        {
            result = PSXIntersectionRangeNew(r1, r2);
            NSLog(@"NEW INTERSECTION: %lu %lu", (unsigned long)result.location, (unsigned long)result.length);
            
            result = PSXIntersectionRangeOld(r1, r2);
            NSLog(@"OLD INTERSECTION: %lu %lu", (unsigned long)result.location, (unsigned long)result.length);
        }
        {
            result = PSXUnionRangeNew(r1, r2);
            NSLog(@"NEW UNION: %lu %lu", (unsigned long)result.location, (unsigned long)result.length);
            
            result = PSXUnionRangeOld(r1, r2);
            NSLog(@"OLD UNION: %lu %lu", (unsigned long)result.location, (unsigned long)result.length);
        }
        
        double val = 1.900019;
        printf("!!! %f -> %f\n", val, floor(val));
    }
    
    return 0;
}
