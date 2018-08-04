//
//  FTFLine.h
//  MovableResizableTextField
//
//  Created by Anatoliy Goodz on 7/27/18.
//  Copyright © 2018 Anatoliy Goodz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FTFGraphic.h"

extern NSString *FTFLineBeginPointKey;
extern NSString *FTFLineEndPointKey;

enum
{
    FTFLineBeginHandle = 1,
    FTFLineEndHandle = 2
};

@interface FTFLine : FTFGraphic

@end
