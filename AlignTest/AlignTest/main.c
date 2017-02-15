//
//  main.c
//  AlignTest
//
//  Created by Anatoliy Goodz on 8/12/16.
//  Copyright © 2016 Anatoliy Goodz. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct _Data
{
    unsigned int number;
    char id;
    
    union
    {
        size_t numberOfChars;
        char * string;
    };
    
    union
    {
        size_t nuberOfDigits;
        int *array;
    };
    
} Data;

int main(int argc, const char * argv[])
{
    char someString[] = "Test string";
    int someArray[] = { 99, 45, -2, 0 };
    size_t lengthOfArray = sizeof(someArray) / sizeof(someArray[0]);
    
    Data data = { 0 };
    
    data.number = 99;
    data.id = 'A';
    
    data.string = malloc(strlen(someString));
    strcpy(data.string, someString);
    
    data.numberOfChars = strlen(someString);
    
    data.nuberOfDigits = lengthOfArray;
    
    data.array = malloc(lengthOfArray);
    memcpy(data.array, someArray, lengthOfArray * sizeof(int)); 
    
    return 0;
}
