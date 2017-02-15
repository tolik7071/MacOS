//
//  main.cpp
//  StringCopyTest
//
//  Created by Anatoliy Goodz on 6/6/16.
//  Copyright © 2016 Anatoliy Goodz. All rights reserved.
//

#include <iostream>
#include <typeinfo>

int main(int argc, const char * argv[])
{
    char dest[8];
    memset(dest, '?', sizeof(dest));
    
    const char *source = "1234567890";
    
    strncpy(dest, source, sizeof(dest));
    dest[sizeof(dest) - 1] = 0;
    
    for (int i = 0; i < sizeof(dest); ++i)
    {
        printf("%2d: %c (%x)\n", i, dest[i], dest[i]);
    }
    
    std::cout << typeid(dest).name() << std::endl;
    
    return 0;
}
