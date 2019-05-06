//
//  ViewController.m
//  multiscissor
//
//  Created by tolik7071 on 2/19/19.
//  Copyright © 2019 tolik7071. All rights reserved.
//

#import "ViewController.h"
#import "GLUtilities.h"
#import <OpenGL/gl3.h>
#import <OpenGL/gl3ext.h>
#include <vmath.h>

@implementation ViewController
{
    GLuint          _program;
    GLuint          _vao;
    GLuint          _position_buffer;
    GLuint          _index_buffer;
    GLuint          _uniform_buffer;
    GLint           _mv_location;
    GLint           _proj_location;
}

- (void)cleanup
{
    [super cleanup];
    
    if (0 != _vao)
    {
        glDeleteVertexArrays(1, &_vao);
        _vao = 0;
    }
    
    if (0 != _program)
    {
        glDeleteProgram(_program);
        _program = 0;
    }
}

- (void)configOpenGLEnvironment
{
    NSAssert(self.openGLView != nil, @"ERROR: openGLView is NULL");
    
    [self.openGLView.openGLContext makeCurrentContext];
    
    NSURL *vertexShaderUrl = FindResourceWithName(@"multiscissor.vert");
    assert(vertexShaderUrl);
    NSData *vertexShaderData = ReadFile(vertexShaderUrl);
    assert(0 < vertexShaderData.length);
    
    NSURL *geometryShaderUrl = FindResourceWithName(@"multiscissor.geom");
    assert(geometryShaderUrl);
    NSData *geometryShaderData = ReadFile(geometryShaderUrl);
    assert(0 < geometryShaderData.length);
    
    NSURL *fragmentShaderUrl = FindResourceWithName(@"multiscissor.frag");
    assert(fragmentShaderUrl);
    NSData *fragmentShaderData = ReadFile(fragmentShaderUrl);
    assert(0 < fragmentShaderData.length);
    
    _program = CreateProgram3(vertexShaderData, geometryShaderData, fragmentShaderData);
    assert(0 < _program);
    
    _mv_location = glGetUniformLocation(_program, "mv_matrix");
    _proj_location = glGetUniformLocation(_program, "proj_matrix");
    
    glGenVertexArrays(1, &_vao);
    glBindVertexArray(_vao);
    
    static const GLushort vertex_indices[] =
    {
        0, 1, 2,
        2, 1, 3,
        2, 3, 4,
        4, 3, 5,
        4, 5, 6,
        6, 5, 7,
        6, 7, 0,
        0, 7, 1,
        6, 0, 2,
        2, 4, 6,
        7, 5, 3,
        7, 3, 1
    };
    
    static const GLfloat vertex_positions[] =
    {
        -0.25f, -0.25f, -0.25f,
        -0.25f,  0.25f, -0.25f,
         0.25f, -0.25f, -0.25f,
         0.25f,  0.25f, -0.25f,
         0.25f, -0.25f,  0.25f,
         0.25f,  0.25f,  0.25f,
        -0.25f, -0.25f,  0.25f,
        -0.25f,  0.25f,  0.25f,
    };
    
    glGenBuffers(1, &_position_buffer);
    glBindBuffer(GL_ARRAY_BUFFER, _position_buffer);
    glBufferData(GL_ARRAY_BUFFER,
                 sizeof(vertex_positions),
                 vertex_positions,
                 GL_STATIC_DRAW);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, NULL);
    glEnableVertexAttribArray(0);
    
    glGenBuffers(1, &_index_buffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _index_buffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER,
                 sizeof(vertex_indices),
                 vertex_indices,
                 GL_STATIC_DRAW);
    
    glGenBuffers(1, &_uniform_buffer);
    glBindBuffer(GL_UNIFORM_BUFFER, _uniform_buffer);
    glBufferData(GL_UNIFORM_BUFFER, 4 * sizeof(vmath::mat4), NULL, GL_DYNAMIC_DRAW);
    
    glEnable(GL_CULL_FACE);
    glFrontFace(GL_CW);
    
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LEQUAL);
}

- (void)renderForTime:(MyTimeStamp *)time
{
    if ([self.view inLiveResize])
    {
        return;
    }
    
    GLfloat currentTime = (GLfloat)(time->_timeStamp.videoTime) / (GLfloat)(time->_timeStamp.videoTimeScale);
    _deltaTime = currentTime - _lastFrame;
    
    static const GLfloat black[] = { 0.0f, 0.0f, 0.0f, 1.0f };
    static const GLfloat one = 1.0f;
    
    glDisable(GL_SCISSOR_TEST);
    
    glViewport(0, 0, self.openGLView.frame.size.width, self.openGLView.frame.size.height);
    glClearBufferfv(GL_COLOR, 0, black);
    glClearBufferfv(GL_DEPTH, 0, &one);
    
    // Turn on scissor testing
    glEnable(GL_SCISSOR_TEST);
    
    if (0 != _program)
    {
        // Each rectangle will be 7/16 of the screen
        int scissor_width = (7 * self.openGLView.frame.size.width) / 16;
        int scissor_height = (7 * self.openGLView.frame.size.height) / 16;
        
        // Four rectangles - lower left first...
        glScissorIndexed(0,
                         0,
                         0,
                         scissor_width,
                         scissor_height);
        
        // Lower right...
        glScissorIndexed(1,
                         self.openGLView.frame.size.width - scissor_width,
                         0,
                         scissor_width,
                         scissor_height);
        
        // Upper left...
        glScissorIndexed(2,
                         0,
                         self.openGLView.frame.size.height - scissor_height,
                         scissor_width,
                         scissor_height);
        
        // Upper right...
        glScissorIndexed(3,
                         self.openGLView.frame.size.width - scissor_width,
                         self.openGLView.frame.size.height - scissor_height,
                         scissor_width,
                         scissor_height);
        
        glUseProgram(_program);
        
        vmath::mat4 proj_matrix = vmath::perspective(
            50.0f,
            (float)self.openGLView.frame.size.width / (float)self.openGLView.frame.size.height,
            0.1f,
            1000.0f);
        
//        float f = (float)currentTime * 0.3f;
        
        glBindBufferBase(GL_UNIFORM_BUFFER, 0, _uniform_buffer);
        vmath::mat4 * mv_matrix_array = (vmath::mat4 *)glMapBufferRange(
            GL_UNIFORM_BUFFER,
            0,
            4 * sizeof(vmath::mat4),
            GL_MAP_WRITE_BIT | GL_MAP_INVALIDATE_BUFFER_BIT);
        
        for (int i = 0; i < 4; i++)
        {
            mv_matrix_array[i] = proj_matrix *
            vmath::translate(0.0f, 0.0f, -2.0f) *
            vmath::rotate((float)currentTime * 45.0f * (float)(i + 1), 0.0f, 1.0f, 0.0f) *
            vmath::rotate((float)currentTime * 81.0f * (float)(i + 1), 1.0f, 0.0f, 0.0f);
        }
        
        glUnmapBuffer(GL_UNIFORM_BUFFER);
        
        glDrawElements(GL_TRIANGLES, 36, GL_UNSIGNED_SHORT, 0);
    }
    
    [self.openGLView.openGLContext flushBuffer];
}

@end
