//
//  main.cpp
//  SB_3.3
//
//  Created by tolik7071 on 6/15/17.
//  Copyright © 2017 tolik7071. All rights reserved.
//

#include <iostream>
#include <OpenGL/OpenGL.h>
#include <OpenGL/gl3.h>
#include <ApplicationServices/ApplicationServices.h>

int main(int argc, const char * argv[])
{
    CGDirectDisplayID mainDisplay = CGMainDisplayID();
    CGOpenGLDisplayMask displayMask = CGDisplayIDToOpenGLDisplayMask(mainDisplay);
    
    CGLPixelFormatAttribute attribs[] =
    {
        kCGLPFADisplayMask, (CGLPixelFormatAttribute)displayMask,
        (CGLPixelFormatAttribute)0
    };
    
    CGLPixelFormatObj pixelFormat = NULL;
    GLint numPixelFormats = 0;
    
    CGLContextObj currurentContext = CGLGetCurrentContext();
    
    CGLChoosePixelFormat(attribs, &pixelFormat, &numPixelFormats);
    
    if (pixelFormat)
    {
        CGLContextObj context = 0;
        
        CGLCreateContext(pixelFormat, NULL, &context);
        
        CGLDestroyPixelFormat(pixelFormat);
        CGLSetCurrentContext(context);
        
        if (context)
        {
            const GLubyte *version = glGetString(GL_VERSION);
            std::cout << "version: " << (const char *)(version) << std::endl;
            
            GLint count = 0;
            glGetIntegerv(GL_NUM_EXTENSIONS, &count);
            
            CGLDestroyContext(context);
        }
    }
    
    CGLSetCurrentContext(currurentContext);
    
//    const GLubyte *version = glGetString(GL_VERSION);
//    GLint count = 0;
//    glGetIntegerv(GL_NUM_EXTENSIONS, &count);
//    for (GLint i = 0; i < count; i++)
//    {
//        std::cout << (const char *)glGetStringi(GL_EXTENSIONS, i) << std::endl;
//    }
    
    return 0;
}
