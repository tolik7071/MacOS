//
//  main.m
//  DispatchTimer
//
//  Created by Anatoliy Goodz on 12/18/17.
//  Copyright © 2017 Anatoliy Goodz. All rights reserved.
//

#import <Foundation/Foundation.h>

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        static int count = 0;
        
        dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
        
        if (timer != NULL)
        {
            dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), 2ull * NSEC_PER_SEC, 0ull * NSEC_PER_SEC);
            
            dispatch_source_set_event_handler(timer, ^()
                {
                    if (++count > 10)
                    {
                        exit(0);
                    }
                    
                    NSLog(@"%d", count);
                }
            );
            
            dispatch_resume(timer);
        }
        
        dispatch_main();
    }

    return 0;
}
