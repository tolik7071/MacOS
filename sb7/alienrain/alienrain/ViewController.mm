//
//  ViewController.m
//  alienrain
//
//  Created by tolik7071 on 6/5/18.
//  Copyright © 2018 tolik7071. All rights reserved.
//

#import "ViewController.h"
#import "GLUtilities.h"
#import <OpenGL/gl3.h>
#import <OpenGL/gl3ext.h>
#include <sb7ktx.h>
#include <vmath.h>
#include <cmath>

#define ALIEN_NUMBER 10

static unsigned int seed = 0x13371337;

static inline float random_float()
{
    float res;
    unsigned int tmp;
    
    seed *= 16807;
    
    tmp = seed ^ (seed >> 4) ^ (seed << 15);
    
    *((unsigned int *) &res) = (tmp >> 9) | 0x3F800000;
    
    return (res - 1.0f);
}

@implementation ViewController
{
    GLuint      _programID;
    GLuint      _VAO;
    GLuint      _tex_alien_array;
    GLuint      _rain_buffer;
    
    float       _droplet_x_offset[ALIEN_NUMBER];
    float       _droplet_rot_speed[ALIEN_NUMBER];
    float       _droplet_fall_speed[ALIEN_NUMBER];
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
    
    if (0 != _rain_buffer)
    {
        glDeleteBuffers(1, &_rain_buffer);
        _rain_buffer = 0;
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
    
    _programID = CreateProgram(@"alienrain.vert", @"alienrain.frag");
    
    glGenVertexArrays(1, &_VAO);
    glBindVertexArray(_VAO);
    
    _tex_alien_array = sb7::ktx::file::load([FindResourceWithName(@"aliens.ktx") fileSystemRepresentation]);
    glBindTexture(GL_TEXTURE_2D_ARRAY, _tex_alien_array);
    glTexParameteri(GL_TEXTURE_2D_ARRAY, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
    
    glGenBuffers(1, &_rain_buffer);
    glBindBuffer(GL_UNIFORM_BUFFER, _rain_buffer);
    glBufferData(GL_UNIFORM_BUFFER, ALIEN_NUMBER * sizeof(vmath::vec4), NULL, GL_DYNAMIC_DRAW);
    
    for (int i = 0; i < ALIEN_NUMBER; i++)
    {
        _droplet_x_offset[i] = random_float() * 2.0f - 1.0f;
        _droplet_rot_speed[i] = (random_float() + 0.5f) * ((i & 1) ? -3.0f : 3.0f);
        _droplet_fall_speed[i] = random_float() + 0.2f;
    }
    
    glBindVertexArray(_VAO);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
}

- (void)renderForTime:(MyTimeStamp *)time
{
    if ([self.view inLiveResize])
    {
        return;
    }
    
    [self.openGLView.openGLContext makeCurrentContext];
    
    GLfloat currentTime = (GLfloat)(time->_timeStamp.videoTime) / (GLfloat)(time->_timeStamp.videoTimeScale);
    _deltaTime = currentTime - _lastFrame;
    _lastFrame = currentTime;
    
    static const GLfloat black[] = { 0.0f, 0.0f, 0.0f, 0.0f };
    glClearBufferfv(GL_COLOR, 0, black);
    
    static const GLfloat ones[] = { 1.0f };
    glClearBufferfv(GL_DEPTH, 0, ones);
    
    if (0 != _programID)
    {
        glUseProgram(_programID);
        
        glBindBufferBase(GL_UNIFORM_BUFFER, 0, _rain_buffer);
        vmath::vec4 * droplet = (vmath::vec4 *)glMapBufferRange(
            GL_UNIFORM_BUFFER,
            0,
            ALIEN_NUMBER * sizeof(vmath::vec4),
            GL_MAP_WRITE_BIT | GL_MAP_INVALIDATE_BUFFER_BIT);
        
        for (int i = 0; i < ALIEN_NUMBER; i++)
        {
            droplet[i][0] = _droplet_x_offset[i];
            droplet[i][1] = 2.0f - fmodf((currentTime + float(i)) * _droplet_fall_speed[i], 4.31f);
            droplet[i][2] = currentTime * _droplet_rot_speed[i];
            droplet[i][3] = 0.0f;
        }
        glUnmapBuffer(GL_UNIFORM_BUFFER);
        
        int alien_index;
        for (alien_index = 0; alien_index < ALIEN_NUMBER; alien_index++)
        {
            glVertexAttribI1i(0, alien_index);
            glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        }
    }
    
    [self.openGLView.openGLContext flushBuffer];
}

@end
