//
//  ViewController.m
//  grass
//
//  Created by tolik7071 on 7/4/18.
//  Copyright © 2018 tolik7071. All rights reserved.
//

#import "ViewController.h"
#import "GLUtilities.h"
#import <OpenGL/gl3.h>
#import <OpenGL/gl3ext.h>
#include <sb7ktx.h>
#include <vmath.h>

@implementation ViewController
{
    GLuint  _programID;
    GLuint  _grass_buffer;
    GLuint  _grass_vao;
    GLuint  _tex_grass_color;
    GLuint  _tex_grass_length;
    GLuint  _tex_grass_orientation;
    GLuint  _tex_grass_bend;
    GLint   _mvpMatrix;
}

- (void)cleanup
{
    [super cleanup];
    
    if (0 != _programID)
    {
        glDeleteProgram(_programID);
        _programID = 0;
    }
    
    if (0 != _grass_vao)
    {
        glDeleteVertexArrays(1, &_grass_vao);
        _grass_vao = 0;
    }
    
    if (0 != _grass_buffer)
    {
        glDeleteBuffers(1, &_grass_buffer);
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
    
    _programID = CreateProgram(@"grass.vert", @"grass.frag");
    NSAssert(0 != _programID, @"ERROR: cannot create programm.");
    
    static const GLfloat grass_blade[] =
    {
        -0.3f,  0.0f,
         0.3f,  0.0f,
        -0.20f, 1.0f,
         0.1f,  1.3f,
        -0.05f, 2.3f,
         0.0f,  3.3f
    };
    
    glGenBuffers(1, &_grass_buffer);
    glBindBuffer(GL_ARRAY_BUFFER, _grass_buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(grass_blade), grass_blade, GL_STATIC_DRAW);
    
    glGenVertexArrays(1, &_grass_vao);
    glBindVertexArray(_grass_vao);
    
    glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 0, NULL);
    glEnableVertexAttribArray(0);
    
    _mvpMatrix = glGetUniformLocation(_programID, "mvpMatrix");
    
    glActiveTexture(GL_TEXTURE1);
    _tex_grass_length = sb7::ktx::file::load([FindResourceWithName(@"grass_length.ktx") fileSystemRepresentation]);
    NSAssert(0 != _tex_grass_length, @"ERROR: file not found.");
    
    glActiveTexture(GL_TEXTURE2);
    _tex_grass_orientation = sb7::ktx::file::load([FindResourceWithName(@"grass_orientation.ktx") fileSystemRepresentation]);
    NSAssert(0 != _tex_grass_orientation, @"ERROR: file not found.");
    
    glActiveTexture(GL_TEXTURE3);
    _tex_grass_color = sb7::ktx::file::load([FindResourceWithName(@"grass_color.ktx") fileSystemRepresentation]);
    NSAssert(0 != _tex_grass_color, @"ERROR: file not found.");
    
    glActiveTexture(GL_TEXTURE4);
    _tex_grass_bend = sb7::ktx::file::load([FindResourceWithName(@"grass_bend.ktx") fileSystemRepresentation]);
    NSAssert(0 != _tex_grass_bend, @"ERROR: file not found.");
}

- (void)renderForTime:(MyTimeStamp *)time
{
    if ([self.view inLiveResize])
    {
        return;
    }
    
    GLfloat currentTime = (GLfloat)(time->_timeStamp.videoTime) / (GLfloat)(time->_timeStamp.videoTimeScale);
    _deltaTime = currentTime - _lastFrame;
    _lastFrame = currentTime;
    
    static const GLfloat black[] = { 0.0f, 0.0f, 0.0f, 1.0f };
    static const GLfloat one = 1.0f;
    
    glClearBufferfv(GL_COLOR, 0, black);
    glClearBufferfv(GL_DEPTH, 0, &one);
    
    if (0 != _programID)
    {
        glUseProgram(_programID);
        
        float t = (float)currentTime * 0.02f;
        float r = 550.0f;
        
        vmath::mat4 mv_matrix = vmath::lookat(vmath::vec3(sinf(t) * r, 25.0f, cosf(t) * r),
                                              vmath::vec3(0.0f, -50.0f, 0.0f),
                                              vmath::vec3(0.0, 1.0, 0.0));
        vmath::mat4 prj_matrix = vmath::perspective(45.0f,
            (float)self.openGLView.frame.size.width / (float)self.openGLView.frame.size.height, 0.1f, 1000.0f);
        
        glUseProgram(_programID);
        glUniformMatrix4fv(_mvpMatrix, 1, GL_FALSE, (prj_matrix * mv_matrix));
        
        glEnable(GL_DEPTH_TEST);
        glDepthFunc(GL_LEQUAL);
        
        glBindVertexArray(_grass_vao);
        glDrawArraysInstanced(GL_TRIANGLE_STRIP, 0, 6, 1024 * 1024);
    }
    
    [self.openGLView.openGLContext flushBuffer];
}

@end
