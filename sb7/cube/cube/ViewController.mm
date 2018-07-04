//
//  ViewController.m
//  cube
//
//  Created by tolik7071 on 6/22/18.
//  Copyright © 2018 tolik7071. All rights reserved.
//

#import "ViewController.h"
#import "GLUtilities.h"
#import <OpenGL/gl3.h>
#import <OpenGL/gl3ext.h>
#import "SB_FPS_Counter.h"
#include <vmath.h>

#define MANY_CUBES

@implementation ViewController
{
    GLuint          _programID;
    GLuint          _VAO;
    GLint           _mv_location;
    GLint           _proj_location;
    GLuint          _position_buffer;
    GLuint          _index_buffer;
    SB_FPS_Counter *_counter;
}

- (nullable instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    
    if (self)
    {
        _counter = [[SB_FPS_Counter alloc] init];
    }
    
    return self;
}

- (void)cleanup
{
    [super cleanup];
    
    if (0 != _programID)
    {
        glDeleteProgram(_programID);
        _programID = 0;
    }
    
    if (0 != _VAO)
    {
        glDeleteVertexArrays(1, &_VAO);
        _VAO = 0;
    }
    
    if (0 != _position_buffer)
    {
        glDeleteBuffers(1, &_position_buffer);
    }
    
    if (0 != _index_buffer)
    {
        glDeleteBuffers(1, &_index_buffer);
    }
}

- (void)viewDidLayout
{
    [super viewDidLayout];
    
    glViewport(0, 0, self.openGLView.bounds.size.width, self.openGLView.bounds.size.height);
}

- (void)configOpenGLEnvironment
{
    NSAssert(self.openGLView != nil, @"ERROR: openGLView is NULL");
    
    [self.openGLView.openGLContext makeCurrentContext];
    
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LEQUAL);
    glEnable(GL_CULL_FACE);
    // glFrontFace(GL_CW);
    
    _programID = CreateProgram(@"cube.vert", @"cube.frag");
    
    _mv_location = glGetUniformLocation(_programID, "mv_matrix");
    _proj_location = glGetUniformLocation(_programID, "proj_matrix");
    
    glGenVertexArrays(1, &_VAO);
    glBindVertexArray(_VAO);
    
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
}

- (void)renderForTime:(MyTimeStamp *)time
{
    if ([self.view inLiveResize])
    {
        return;
    }
    
    [_counter increase];
    [self.fps setStringValue:[NSString stringWithFormat:@"%.02f", [_counter fps]]];
    
    GLfloat currentTime = (GLfloat)(time->_timeStamp.videoTime) / (GLfloat)(time->_timeStamp.videoTimeScale);
    _deltaTime = currentTime - _lastFrame;
    _lastFrame = currentTime;
    
    [self.openGLView.openGLContext makeCurrentContext];
    
    static const GLfloat green[] = { 0.0f, 0.25f, 0.0f, 1.0f };
    static const GLfloat one = 1.0f;
    
    glClearBufferfv(GL_COLOR, 0, green);
    glClearBufferfv(GL_DEPTH, 0, &one);
    
    if (0 != _programID)
    {
        glUseProgram(_programID);
        
        vmath::mat4 proj_matrix = vmath::perspective(
            30.0f,
            (float)self.openGLView.frame.size.width / (float)self.openGLView.frame.size.height,
            0.1f,
            1000.0f);
        glUniformMatrix4fv(_proj_location, 1, GL_FALSE, proj_matrix);
        
#ifdef MANY_CUBES
        for (int i = 0; i < 24; i++)
        {
            float f = (float)i + (float)currentTime * 0.3f;
            vmath::mat4 mv_matrix = vmath::translate(0.0f, 0.0f, -20.0f) *
            vmath::rotate((float)currentTime * 45.0f, 0.0f, 1.0f, 0.0f) *
            vmath::rotate((float)currentTime * 21.0f, 1.0f, 0.0f, 0.0f) *
            vmath::translate(sinf(2.1f * f) * 2.0f,
                             cosf(1.7f * f) * 2.0f,
                             sinf(1.3f * f) * cosf(1.5f * f) * 2.0f);
            glUniformMatrix4fv(_mv_location, 1, GL_FALSE, mv_matrix);
            glDrawElements(GL_TRIANGLES, 36, GL_UNSIGNED_SHORT, 0);
        }
#else
        float f = (float)currentTime * 0.3f;
        vmath::mat4 mv_matrix = vmath::translate(0.0f, 0.0f, -4.0f) *
        vmath::translate(sinf(2.1f * f) * 0.5f,
                         cosf(1.7f * f) * 0.5f,
                         sinf(1.3f * f) * cosf(1.5f * f) * 2.0f) *
        vmath::rotate((float)currentTime * 45.0f, 0.0f, 1.0f, 0.0f) *
        vmath::rotate((float)currentTime * 81.0f, 1.0f, 0.0f, 0.0f);
        glUniformMatrix4fv(_mv_location, 1, GL_FALSE, mv_matrix);
        glDrawElements(GL_TRIANGLES, 36, GL_UNSIGNED_SHORT, 0);
#endif
    }
    
    [self.openGLView.openGLContext flushBuffer];
}

@end
