//
//  main.m
//  XPSServer
//
//  Created by Anatoliy Goodz on 10/12/17.
//  Copyright © 2017 Anatoliy Goodz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSXConnectionAcceptor.h"

int main(int argc, const char *argv[])
{
    __attribute__((objc_precise_lifetime))PSXConnectionAcceptor *acceptor =
        [[PSXConnectionAcceptor alloc] init];
    
    [acceptor resume];
    
    return 0;
}
