//
//  GLUtilities.h
//  OpenGL SB Tests
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
GLuint CreateProgram(NSString*, NSString*);
GLuint CreateProgram2(NSData*, NSData*, NSData*, NSData*);
GLuint CreateProgram3(NSData*, NSData*, NSData*);
GLuint CreateShader(NSData*, GLenum);

#endif // __OBJC__

#ifdef __cplusplus
#include <string>

//std::string FindResourceWithName(const std::string& name);

extern "C" {
#endif
    
#ifdef __cplusplus
}
#endif

#endif /* GLUtilities_h */
