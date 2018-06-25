//
//  ViewController.m
//  wrapmodes
//
//  Created by tolik7071 on 6/4/18.
//  Copyright © 2018 tolik7071. All rights reserved.
//

#import "ViewController.h"
#import "GLUtilities.h"
#import <OpenGL/gl3.h>
#import <OpenGL/gl3ext.h>
//#import <OpenGL/gl.h>
#include <sb7ktx.h>
#include <vmath.h>

@implementation ViewController
{
    GLuint      _programID;
    GLuint      _VAO;
    GLuint      _texture;
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
    
    if (0 != _texture)
    {
        glDeleteTextures(1, &_texture);
        _texture = 0;
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
    
    glGenTextures(1, &_texture);
    sb7::ktx::file::load([FindResourceWithName(@"rightarrows.ktx") fileSystemRepresentation], _texture);
    glBindTexture(GL_TEXTURE_2D, _texture);
    
    _programID = CreateProgram(@"wrapmodes.vert", @"wrapmodes.frag");
    
    glGenVertexArrays(1, &_VAO);
    glBindVertexArray(_VAO);
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
    
    static const GLfloat green[] = { 0.0f, 0.1f, 0.0f, 1.0f };
    static const GLfloat ones[] = { 1.0f };
    glClearBufferfv(GL_COLOR, 0, green);
    glClearBufferfv(GL_DEPTH, 0, ones);
    
    if (0 != _programID)
    {
        static const GLfloat yellow[] = { 0.4f, 0.4f, 0.0f, 1.0f };
        static const GLenum wrapmodes[] = { GL_CLAMP_TO_EDGE, GL_REPEAT, GL_CLAMP_TO_BORDER, GL_MIRRORED_REPEAT };
        static const float offsets[] =
        {
            -0.5f, -0.5f,
             0.5f, -0.5f,
            -0.5f,  0.5f,
             0.5f,  0.5f
        };
        
        glUseProgram(_programID);
        
        glTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_BORDER_COLOR, yellow);
        
        for (int i = 0; i < 4; i++)
        {
            glUniform2fv(0, 1, &offsets[i * 2]);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, wrapmodes[i]);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, wrapmodes[i]);
            
            glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        }
    }
    
    [self.openGLView.openGLContext flushBuffer];
}

@end
