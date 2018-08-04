//
//  FTFText.h
//  MovableResizableTextField
//
//  Created by Anatoliy Goodz on 7/27/18.
//  Copyright © 2018 Anatoliy Goodz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FTFGraphic.h"

extern NSString *FTFTextScriptingContentsKey;
extern NSString *FTFTextUndoContentsKey;

@interface FTFText : FTFGraphic <NSTextStorageDelegate>

@end
