//
//  GLUtilities.m
//  OpenGL SB Tests
//
//  Created by tolik7071 on 3/30/18.
//  Copyright © 2018 tolik7071. All rights reserved.
//

#include "GLUtilities.h"
#import <OpenGL/gl3.h>

BOOL CheckCompilingStatus(GLint shaderId)
{
    GLint success;
    GLchar infoLog[512];
    memset(infoLog, 0, sizeof(infoLog));
    glGetShaderiv(shaderId, GL_COMPILE_STATUS, &success);
    if (GL_TRUE != success)
    {
        glGetShaderInfoLog(shaderId, sizeof(infoLog), NULL, infoLog);
        NSLog(@"ERROR : %s : %s", __PRETTY_FUNCTION__, infoLog);
    }
    
    return (GL_TRUE == success);
}

BOOL CheckLinkingStatus(GLint programId)
{
    GLint success;
    GLchar infoLog[512];
    memset(infoLog, 0, sizeof(infoLog));
    glGetProgramiv(programId, GL_LINK_STATUS, &success);
    if (GL_TRUE != success)
    {
        glGetProgramInfoLog(programId, sizeof(infoLog), NULL, infoLog);
        NSLog(@"ERROR : %s : %s", __PRETTY_FUNCTION__, infoLog);
    }
    
    return (GL_TRUE == success);
}

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
        CheckCompilingStatus(vertex_shader);
        
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
        CheckCompilingStatus(fragment_shader);
        
        // Create program, attach shaders to it, and link it
        
        program = glCreateProgram();
        glAttachShader(program, vertex_shader);
        glAttachShader(program, fragment_shader);
        glLinkProgram(program);
        CheckLinkingStatus(program);
        
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

GLuint CreateProgram2(NSData *vertex, NSData *tessellationControl, NSData *tessellationEvaluation, NSData *fragment)
{
    GLuint program = 0;
    
    GLuint vertex_shader = CreateShader(vertex, GL_VERTEX_SHADER);
    GLuint tessellation_control_shader = CreateShader(tessellationControl, GL_TESS_CONTROL_SHADER);
    GLuint tessellation_evaluation_shader = CreateShader(tessellationEvaluation, GL_TESS_CONTROL_SHADER);
    GLuint fragment_shader = CreateShader(fragment, GL_FRAGMENT_SHADER);
    
    // Create program, attach shaders to it, and link it
    
    program = glCreateProgram();
    glAttachShader(program, vertex_shader);
    glAttachShader(program, tessellation_control_shader);
    glAttachShader(program, tessellation_evaluation_shader);
    glAttachShader(program, fragment_shader);
    
    glLinkProgram(program);
    
    // Delete the shaders as the program has them now
    
    if (vertex_shader != 0)
    {
        glDeleteShader(vertex_shader);
    }
    
    if (tessellation_control_shader != 0)
    {
        glDeleteShader(tessellation_control_shader);
    }
    
    if (tessellation_evaluation_shader != 0)
    {
        glDeleteShader(tessellation_evaluation_shader);
    }
    
    if (fragment_shader != 0)
    {
        glDeleteShader(fragment_shader);
    }
    
    return program;
}

GLuint CreateShader(NSData* shaderContent, GLenum shaderType)
{
    GLuint shaderID = 0;
    
    GLint length = (GLint)shaderContent.length;
    GLchar *buffer = (GLchar *)malloc(length);
    if (buffer)
    {
        [shaderContent getBytes:buffer length:length];
        
        shaderID = glCreateShader(shaderType);
        glShaderSource(shaderID, 1, (const GLchar **)&buffer, &length);
        glCompileShader(shaderID);
        
        free(buffer);
    }
    
    return shaderID;
}
