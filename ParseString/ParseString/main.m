//
//  main.m
//  ParseString
//
//  Created by Anatoliy Goodz on 6/30/17.
//  Copyright © 2017 Anatoliy Goodz. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MAX_BUFFER_LENGTH 1024

NSString* ParseMultiLineString(const char inString[], size_t inLength);
void RemoveNullTerminators(char inString[], size_t inLength);

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        {
            const char strings[] =
            {
                "First string.\0\nSecond String\0\n.LAST STRING."
            };
            
            NSString *result = ParseMultiLineString(strings, sizeof(strings));
            
            assert([result containsString:@"First string."]);
            assert([result containsString:@"\nSecond String"]);
            assert([result containsString:@"\n.LAST STRING."]);
        }

        // Cannot to detect!
//        {
//            const char strings[] =
//            {
//                "First string."
//            };
//            
//            NSString *result = ParseMultiLineString(strings, 1024);
//            
//            assert([result containsString:@"First string."]);
//        }
        
        {
            const char strings[] =
            {
                "First string.Garbadge..................."
            };
            
            NSString *result = ParseMultiLineString(strings, 13);
            assert([result isEqualToString:@"First string."]);
        }
        
        {
            const char strings[] =
            {
                "First string"
            };
            
            NSString *result = ParseMultiLineString(strings, strlen(strings));
            assert([result isEqualToString:@"First string"]);
        }
        
        {
            const char strings[] =
            {
                ""
            };
            
            NSString *result = ParseMultiLineString(strings, strlen(strings));
            assert([result isEqualToString:@""]);
        }
        
        {
            const char strings[] =
            {
                "12345"
            };
            
            NSString *result = ParseMultiLineString(strings, 1);
            assert([result isEqualToString:@"1"]);
        }
        
        {
            const char strings[] =
            {
                "123\0ABCDE"
            };
            
            NSString *result = ParseMultiLineString(strings, 6);
            assert([result isEqualToString:@"123AB"]);
        }
        
        {
            const char strings[] =
            {
                "\0\0\0\0"
            };
            
            NSString *result = ParseMultiLineString(strings, 4);
            assert([result isEqualToString:@""]);
        }
        
        {
            const char strings[] =
            {
                "123"
            };
            
            NSString *result = ParseMultiLineString(strings, 0);
            assert([result isEqualToString:@""]);
        }
        
        {
            char string[] = {'1', '2', '3', '\0', '4', '5', '6', '\0', '\0', 'A', 'B', 'C', '\0'};
            RemoveNullTerminators(string, sizeof(string));
        }
    }
    
    return 0;
}

NSString* ParseMultiLineString(const char inString[], size_t inLength)
{
    if (NULL == inString)
    {
        return NULL;
    }
    
    NSMutableString *result = [NSMutableString new];
    
    for (size_t index = 0, startIndex = 0, endIndex = 0; index < inLength; index++)
    {
        char currentChar = inString[index];
        
        BOOL isTerminator = currentChar == '\0';
        BOOL isLastChar = index == inLength - 1;
        
        if (isTerminator || isLastChar)
        {
            // end of the current string or a last character
            
            endIndex = index;
            
            const char *ptr = inString + startIndex;
            size_t length = endIndex - startIndex + (isLastChar && !isTerminator ? 1 : 0);
            if (0 != length)
            {
                NSString *string = [[NSString alloc] initWithBytes:ptr length:length encoding:NSUTF8StringEncoding];
                [result appendString:string];
            }
            
            startIndex = index + 1;
        }
    }
    
    return result;
}

void RemoveNullTerminators(char inString[], size_t inLength)
{
    for (size_t index = 0; index < inLength; index++)
    {
        char currentChar = inString[index];
        
        if (currentChar == '\0')
        {
            // find next non-null character
            
            size_t nextIndex = index;
            for (; nextIndex < inLength; nextIndex++)
            {
                if (currentChar != '\0')
                {
                    break;
                }
            }
            
            size_t length = nextIndex - index;
            memcpy(&inString[index], &inString[nextIndex], length);
        }
    }
}
