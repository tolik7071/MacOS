//
//  MyTimeStamp.h
//  3.3-Movable_Triangle
//
//  Created by Anatoliy Goodz on 5/1/18.
//  Copyright © 2018 tolik7071. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>

@interface MyTimeStamp : NSObject
{
   @public
   CVTimeStamp _timeStamp;
}

- (instancetype)initWithTimeStamp:(const CVTimeStamp*)timeStamp;

@end
