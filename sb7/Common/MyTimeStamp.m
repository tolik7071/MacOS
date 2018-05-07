//
//  MyTimeStamp.m
//  3.3-Movable_Triangle
//
//  Created by Anatoliy Goodz on 5/1/18.
//  Copyright © 2018 tolik7071. All rights reserved.
//

#import "MyTimeStamp.h"

@implementation MyTimeStamp

- (instancetype)initWithTimeStamp:(const CVTimeStamp*)timeStamp
{
   self = [super init];

   if (self)
   {
      memcpy(&(_timeStamp), timeStamp, sizeof(_timeStamp));
   }

   return self;
}

@end
