//
//  main.m
//  UnicodeTest
//
//  Created by Anatoliy Goodz on 10/15/14.
//  Copyright (c) 2014 tolik7071. All rights reserved.
//

#import <Foundation/Foundation.h>

NSAttributedString * CreateFormattedString(NSString* text, NSStringEncoding encoding);

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        // "ÅÆÇÈ" in CP-1252
        char kSomeText[] =
        //"αβχδ";
        { 0xC5, 0xC6, 0xC7, 0xC8/*, 0x00*/ };
        
        NSString *convertedText = [[NSString alloc] initWithBytes:kSomeText
            length:sizeof(kSomeText)
            encoding:NSWindowsCP1252StringEncoding];
        NSLog(@"\'%@\'", convertedText);
    
        CFStringEncoding encoding[] = { kCFStringEncodingUTF8, kCFStringEncodingWindowsLatin1 };
        const CFIndex kEncodingCount = sizeof(encoding) / sizeof(*encoding);
        CFIndex currentEncoding = 0;
        for (; currentEncoding < kEncodingCount; ++currentEncoding)
        {
            char buffer[256] = { 0 };
            memset(buffer, 0, sizeof(buffer));
            
            CFIndex convertedChars = CFStringGetBytes(
                (CFStringRef)convertedText
                , CFRangeMake(0, CFStringGetLength((CFStringRef)convertedText))
                , encoding[currentEncoding]
                , '?'
                , FALSE
                , (UInt8*)buffer
                , sizeof(buffer)
                , NULL);
            buffer[convertedChars] = 0;
            
            int i = 0;
            printf("Encoding %X:\t", encoding[currentEncoding]);
            while (TRUE)
            {
                if (0 == buffer[i])
                {
                    printf("\n");
                    break;
                }
                
                printf("%08X ", buffer[i]);
                ++i;
            }
        }
        
        
    }
    
    return 0;
}

NSAttributedString * CreateFormattedString(NSString* text, NSStringEncoding encoding)
{
    NSMutableAttributedString *result = [[NSMutableAttributedString alloc] initWithString:text];
    
    NSUInteger currentCharIndex = 0;
    for (; currentCharIndex < [text length]; ++currentCharIndex)
    {
        unichar currentChar = [text characterAtIndex:currentCharIndex];
    }
    
    return result;
}
