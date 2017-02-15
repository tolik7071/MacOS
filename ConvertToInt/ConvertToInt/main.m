//
//  main.m
//  ConvertToInt
//
//  Created by Anatoliy Goodz on 9/9/15.
//  Copyright (c) 2015 smk.private. All rights reserved.
//

#import <Foundation/Foundation.h>

bool ConvertToIntBase10(char const inputSting[], int *outValue)
{
    if (inputSting == NULL)
    {
        return false;
    }
    
    char *endptr = NULL;
    intmax_t converted = strtoimax(inputSting, &endptr, 10);
    
    bool isValid = (inputSting && *inputSting != '\0') && (endptr && *endptr == '\0');
    if (isValid && outValue != NULL)
    {
        *outValue = (int)converted;
    }
    
    return isValid;
}

void TestWrapper(char const inputSting[])
{
    int value = 0;
    printf("`%s` -> %s; %d\n", inputSting, ConvertToIntBase10(inputSting, &value) ? "OK" : "FAIL", value);
}

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        TestWrapper("232");
        TestWrapper("dkfj");
        TestWrapper(NULL);
        TestWrapper("34 87");
        TestWrapper("");
        TestWrapper("-11");
    }
    
    return 0;
}
