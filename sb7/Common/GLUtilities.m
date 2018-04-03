//
//  GLUtilities.c
//  First_Triangle
//
//  Created by tolik7071 on 3/30/18.
//  Copyright © 2018 tolik7071. All rights reserved.
//

#include "GLUtilities.h"
#import <OpenGL/gl3.h>

NSURL* FindResourceWithName(NSString* aName)
{
    NSURL *result = [[NSBundle mainBundle]
                     URLForResource:[aName stringByDeletingPathExtension]
                     withExtension:[aName pathExtension]];
    
    return result;
}

NSData* ReadFile(NSURL* anURL)
{
    NSData *bytes = nil;
    
    if (anURL && [[NSFileManager defaultManager] isReadableFileAtPath:[anURL path]])
    {
        NSFileHandle* fileHandle = [NSFileHandle fileHandleForReadingFromURL:anURL error:nil];
        bytes = [fileHandle readDataToEndOfFile];
    }
    
    return bytes;
}

GLuint CreateProgram(NSData *vertex, NSData *fragment)
{
    GLuint program = 0;
    GLchar *vertexBuffer = NULL;
    GLchar *fragmentBuffer = NULL;
    GLuint vertex_shader = 0;
    GLuint fragment_shader = 0;
    
    do
    {
        GLint length = 0;
        
        // Create and compile vertex shader
        
        length = (GLint)vertex.length;
        vertexBuffer = (GLchar *)malloc(length);
        if (!vertexBuffer)
        {
            break;
        }
        [vertex getBytes:vertexBuffer length:length];
        
        vertex_shader = glCreateShader(GL_VERTEX_SHADER);
        glShaderSource(vertex_shader, 1, (const GLchar **)&vertexBuffer, &length);
        glCompileShader(vertex_shader);
        
        // Create and compile fragment shader
        
        length = (GLint)fragment.length;
        fragmentBuffer = (GLchar *)malloc(length);
        if (!fragmentBuffer)
        {
            break;
        }
        [fragment getBytes:fragmentBuffer length:length];
        
        fragment_shader = glCreateShader(GL_FRAGMENT_SHADER);
        glShaderSource(fragment_shader, 1, (const GLchar **)&fragmentBuffer, &length);
        glCompileShader(fragment_shader);
        
        // Create program, attach shaders to it, and link it
        
        program = glCreateProgram();
        glAttachShader(program, vertex_shader);
        glAttachShader(program, fragment_shader);
        glLinkProgram(program);
        
    } while (NO);
    
    // Free buffers
    
    if (vertexBuffer)
    {
        free(vertexBuffer);
    }
    
    if (fragmentBuffer)
    {
        free(fragmentBuffer);
    }
    
    // Delete the shaders as the program has them now
    
    if (vertex_shader != 0)
    {
        glDeleteShader(vertex_shader);
    }
    
    if (fragment_shader != 0)
    {
        glDeleteShader(fragment_shader);
    }
    
    return program;
}
