//
//  SB_FPS_Counter.h
//  alienrain
//
//  Created by Anatoliy Goodz on 6/12/18.
//  Copyright © 2018 tolik7071. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef unsigned long long TTicks;

@interface SB_FPS_Counter : NSObject

- (void)increase;
- (double)fps;

@end
