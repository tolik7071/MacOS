//
//  main.m
//  RegularExpressionTest
//
//  Created by Anatoliy Goodz on 12/2/14.
//  Copyright (c) 2014 tolik7071. All rights reserved.
//

#import <Foundation/Foundation.h>

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        NSString *textBody = @"~/Desktop/%s_%D.txt";
        NSString *expessionTemplate = @"$1Prism7";
        
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\%."
            options:NSRegularExpressionCaseInsensitive error:nil];
        
        NSArray *matches = [regex matchesInString:textBody options:0
           range:NSMakeRange(0, [textBody length])];
        for (NSTextCheckingResult *match in matches)
        {
            NSLog(@"%@", [textBody substringWithRange:[match range]]);
        }
        
        NSString *result = [regex stringByReplacingMatchesInString:textBody
            options:0 range:NSMakeRange(0, [textBody length]) withTemplate:expessionTemplate];
        
        NSLog(@"`%@`", result);
  
#if __MAC_OS_X_VERSION_MAX_ALLOWED >= 1010
        typedef NSOperatingSystemVersion PSXOperatingSystemVersion;
#else
        typedef struct
        {
            NSInteger majorVersion;
            NSInteger minorVersion;
            NSInteger patchVersion;
        } PSXOperatingSystemVersion;
#endif // __MAC_OS_X_VERSION_MAX_ALLOWED
        
        NSScanner *scanner = [NSScanner scannerWithString:@"11.22.3"];
        {
            PSXOperatingSystemVersion version;
            memset(&version, 0, sizeof(version));
            
            BOOL result = [scanner scanInteger:&version.majorVersion];
            if (![scanner isAtEnd])
            {
                scanner.scanLocation += 1;
                result = [scanner scanInteger:&version.minorVersion];
                if (![scanner isAtEnd])
                {
                    scanner.scanLocation += 1;
                    result = [scanner scanInteger:&version.patchVersion];
                }
            }
            NSLog(@"%ld %ld %ld", version.majorVersion, version.minorVersion, version.patchVersion);
        }
    }
    
    return 0;
}
