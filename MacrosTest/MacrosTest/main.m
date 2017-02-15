//
//  main.m
//  MacrosTest
//
//  Created by Anatoliy Goodz on 10/9/14.
//  Copyright (c) 2014 tolik7071. All rights reserved.
//

#import <Foundation/Foundation.h>

#define PSXMajorVersion			7
#define PSXFeaturesVersion		0
#define PSXMinorVersion			a
#define PSXBuildNumber			17

//#define VER(a, b, c, d) a"."b"."c"."d

const char * GetVersion()
{
    static char sVersion[256] = { 0 };
    if (0 == sVersion[0])
    {
        
    }
    
    return sVersion;
}

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {    
//        printf("`%s`\n", VER(PSXMajorVersion, PSXFeaturesVersion, PSXMinorVersion, PSXBuildNumber));
        
        BOOL value = NO;
        
        for (int i = 0; i < 10; ++i)
        {
            BOOL newValue = (i % 2 == 0);
            value ^= newValue;
            
            printf("%d: %s -> %s\n", i, newValue ? "TRUE" : "FALSE", value ? "TRUE" : "FALSE");
        }
    }
    
    return 0;
}

