//
//  ViewController.m
//  tunnel
//
//  Created by tolik7071 on 6/1/18.
//  Copyright © 2018 tolik7071. All rights reserved.
//

#import "ViewController.h"
#import "GLUtilities.h"
#import <OpenGL/gl3.h>
#import <OpenGL/gl3ext.h>
#include <sb7ktx.h>
#include <vmath.h>

typedef struct _uniforms_tag
{
    GLint       mvp;
    GLint       offset;
} Uniforms;

@implementation ViewController
{
    GLuint      _programID;
    GLuint      _VAO;
    Uniforms    _uniforms;
    GLuint      _tex_wall;
    GLuint      _tex_ceiling;
    GLuint      _tex_floor;
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
    
    if (0 != _tex_wall)
    {
        glDeleteTextures(1, &_tex_wall);
        _tex_wall = 0;
    }
    
    if (0 != _tex_ceiling)
    {
        glDeleteTextures(1, &_tex_ceiling);
        _tex_wall = 0;
    }
    
    if (0 != _tex_floor)
    {
        glDeleteTextures(1, &_tex_floor);
        _tex_wall = 0;
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
    
    _programID = CreateProgram(@"tunnel.vert", @"tunnel.frag");
    NSAssert(_programID != 0, @"Can not create programm.");
    
    glUseProgram(_programID);
    
    _uniforms.mvp = glGetUniformLocation(_programID, "mvp");
    NSAssert(_uniforms.mvp >= 0, @"Can not locate an uniform.");
    _uniforms.offset = glGetUniformLocation(_programID, "offset");
    NSAssert(_uniforms.offset >= 0, @"Can not locate an uniform.");
    
    glGenVertexArrays(1, &_VAO);
    glBindVertexArray(_VAO);
    
    NSURL *url;
    
    url = FindResourceWithName(@"brick.ktx");
    NSAssert(url != nil, @"Can not find resource.");
    _tex_wall = sb7::ktx::file::load([url fileSystemRepresentation]);
    
    url = FindResourceWithName(@"ceiling.ktx");
    NSAssert(url != nil, @"Can not find resource.");
    _tex_ceiling = sb7::ktx::file::load([url fileSystemRepresentation]);
    
    url = FindResourceWithName(@"floor.ktx");
    NSAssert(url != nil, @"Can not find resource.");
    _tex_floor = sb7::ktx::file::load([url fileSystemRepresentation]);
    
    GLuint textures[] = { _tex_floor, _tex_wall, _tex_ceiling };
    
    for (int i = 0; i < 3; i++)
    {
        glBindTexture(GL_TEXTURE_2D, textures[i]);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    }
    
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
    
    static const GLfloat black[] = { 0.0f, 0.0f, 0.0f, 0.0f };
    static const GLfloat ones[] = { 1.0f };
    
    glClearBufferfv(GL_COLOR, 0, black);
    glClearBufferfv(GL_DEPTH, 0, ones);
    
    if (0 != _programID)
    {
        glUseProgram(_programID);
        
        vmath::mat4 proj_matrix = vmath::perspective(
            60.0f,
            (float)self.openGLView.frame.size.width / (float)self.openGLView.frame.size.height,
            0.1f,
            100.0f);
        
        glUniform1f(_uniforms.offset, currentTime * 0.003f);
        
        GLuint textures[] = { _tex_wall, _tex_floor, _tex_wall, _tex_ceiling };
        
        for (int i = 0; i < 4; i++)
        {
            vmath::mat4 mv_matrix = vmath::rotate(
                90.0f * (float)i, vmath::vec3(0.0f, 0.0f, 1.0f)) *
                vmath::translate(-0.5f, 0.0f, -10.0f) *
                vmath::rotate(90.0f, 0.0f, 1.0f, 0.0f) *
                vmath::scale(30.0f, 1.0f, 1.0f);
            vmath::mat4 mvp = proj_matrix * mv_matrix;
            
            glUniformMatrix4fv(_uniforms.mvp, 1, GL_FALSE, mvp);
            
            glBindTexture(GL_TEXTURE_2D, textures[i]);
            glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        }
    }
    
    [self.openGLView.openGLContext flushBuffer];
}

@end
