//
//  SB_FPS_Counter.m
//  alienrain
//
//  Created by Anatoliy Goodz on 6/12/18.
//  Copyright © 2018 tolik7071. All rights reserved.
//

#import "SB_FPS_Counter.h"
#include <chrono>


@implementation SB_FPS_Counter
{
   TTicks _ticks;
   double _fps;
}

- (void)increase
{
   typedef std::chrono::high_resolution_clock TClock;

   static TClock::time_point start;

   if (0 == _ticks)
   {
      start = TClock::now();
   }

   _ticks++;

   TClock::time_point now = TClock::now();
   TClock::duration elapsed = now - start;

   std::chrono::milliseconds::rep milliseconds = std::chrono::duration_cast<std::chrono::milliseconds>(elapsed).count();
   if (1000 <= milliseconds)
   {
      _fps = (double)_ticks / (double)(milliseconds / 1000);
      start = now;
      _ticks = 0;
   }
}

- (double)fps
{
   return _fps;
}

@end
