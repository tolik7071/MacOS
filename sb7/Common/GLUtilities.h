//
//  GLUtilities.h
//  First_Triangle
//
//  Created by tolik7071 on 3/30/18.
//  Copyright © 2018 tolik7071. All rights reserved.
//

#ifndef GLUtilities_h
#define GLUtilities_h

#if defined(__OBJC__)
#include <Cocoa/Cocoa.h>

NSURL* FindResourceWithName(NSString*);
NSData* ReadFile(NSURL*);
GLuint CreateProgram(NSData*, NSData*);
#endif // __OBJC__

#endif /* GLUtilities_h */
