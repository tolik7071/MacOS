//
//  main.m
//  StringsTests
//
//  Created by Anatoliy Goodz on 3/17/15.
//  Copyright (c) 2015 smk.private. All rights reserved.
//

#import <Foundation/Foundation.h>

// Returns a string object containing the characters of the receiver. A length of the resulting string do not exceeds a value specifed in aMaxLength.
// If aPadding is  not nil and a length of the original string is greater than specifed in aMaxLength it will be added to the end of the resulting string
// -[NSString stringUsingMaxLength:(NSUInteger)aMaxLength paddingString:(NSString*)aPadding];
NSString* stringUsingRestriction(NSString* originalString, NSUInteger maxCharNumber, NSString* suffix)
{
    if (originalString == nil)
    {
        return nil;
    }
    
    const NSUInteger originalStringLength = originalString.length;
    
    if (originalStringLength <= maxCharNumber)
    {
        return originalString;
    }
    
    NSMutableString *result = [NSMutableString stringWithString:
        [originalString substringToIndex:maxCharNumber]];
    if (suffix != nil)
    {
        [result appendString:suffix];
    }
    
    return result;
}

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
//        NSString *original = @"This is a string.";
//        
//        NSInteger i;
//        for (i = 0; i < 20; i++)
//        {
//            NSString *result = stringUsingRestriction(original, i, @"…");
//            NSLog(@"%lu: `%@` -> `%@` (%lu)", i, original, result, result.length);
//        }
//        
//        NSLog(@"`\n\t%lu\n\t%lu\n\t%lu`", [@"test" hash], [@"test1" hash], [@"1" hash]);

        NSString *someString = @"This is a text.";
        
#define USE_SET
#if defined(USE_SET)
        NSSet *data = [NSSet setWithObjects:@"23", someString, @"555", someString, nil];
#else
        NSArray *data = [NSArray arrayWithObjects:@"23", someString, @"555", someString, nil];
#endif // USE_SET
        
        for (NSString *text in data)
        {
            NSLog(@"`%@`", text);
        }
        
        NSLog(@"%lu %lu", sizeof(bool), sizeof(BOOL));
    }

    NSMutableString *string = [NSMutableString new];
    [string appendFormat:@"ضص%d", 91];
    NSLog(string);
    NSLog(@"صض");
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"us_Arab"];
    [numberFormatter setLocale:usLocale];
    NSLog(@"%@", [numberFormatter stringFromNumber:@14.0]);
    
    return 0;
}
