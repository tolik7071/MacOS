//
//  ViewController.m
//  clipdistance
//
//  Created by tolik7071 on 6/15/18.
//  Copyright © 2018 tolik7071. All rights reserved.
//

#import "ViewController.h"
#import "GLUtilities.h"
#import <OpenGL/gl3.h>
#import <OpenGL/gl3ext.h>
#include <object.h>
#include <shader.h>
#include <vmath.h>

typedef struct _tag_uniforms
{
    GLint   proj_matrix;
    GLint   mv_matrix;
    GLint   clip_plane;
    GLint   clip_sphere;
} Uniforms;

@implementation ViewController
{
    GLuint       _programID;
    GLuint       _VAO;
    BOOL         _paused;
    Uniforms    _uniforms;
    sb7::object *_object;
}

- (nullable instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    
    if (self)
    {
        _object = new sb7::object();
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
    
    delete _object;
    _object = NULL;
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
    
    NSURL *url = FindResourceWithName(@"dragon.sbm");
    
    if (url)
    {
        _object->load([url fileSystemRepresentation]);
    }
    else
    {
        NSLog(@"dragon.sbm - No such resource.");
    }
    
    GLuint shaders[] =
    {
        sb7::shader::load([FindResourceWithName(@"render.vs.glsl") fileSystemRepresentation], GL_VERTEX_SHADER),
        sb7::shader::load([FindResourceWithName(@"render.fs.glsl") fileSystemRepresentation], GL_FRAGMENT_SHADER)
    };
    
    _programID = sb7::program::link_from_shaders(shaders, 2, true);
    
    glUseProgram(_programID);
    
    _uniforms.proj_matrix = glGetUniformLocation(_programID, "proj_matrix");
    _uniforms.mv_matrix = glGetUniformLocation(_programID, "mv_matrix");
    _uniforms.clip_plane = glGetUniformLocation(_programID, "clip_plane");
    _uniforms.clip_sphere = glGetUniformLocation(_programID, "clip_sphere");
}

- (void)renderForTime:(MyTimeStamp *)time
{
    if ([self.view inLiveResize])
    {
        return;
    }
    
    [self.openGLView.openGLContext makeCurrentContext];
    
    static double total_time = 0.0;
    
    GLfloat currentTime = (GLfloat)(time->_timeStamp.videoTime) / (GLfloat)(time->_timeStamp.videoTimeScale);
    _deltaTime = currentTime - _lastFrame;
    
    if (!_paused)
        total_time += (currentTime - _lastFrame);
    
    _lastFrame = currentTime;
    
    static const GLfloat black[] = { 0.0f, 0.0f, 0.0f, 0.0f };
    glClearBufferfv(GL_COLOR, 0, black);
    
    static const GLfloat ones[] = { 1.0f };
    glClearBufferfv(GL_DEPTH, 0, ones);
    
    float f = (float)total_time;
    
    if (0 != _programID)
    {
        glUseProgram(_programID);
        
        vmath::mat4 proj_matrix = vmath::perspective(
            50.0f,
            (float)self.openGLView.frame.size.width / (float)self.openGLView.frame.size.height,
            0.1f,
            1000.0f);
        
        vmath::mat4 mv_matrix = vmath::translate(0.0f, 0.0f, -15.0f) *
        vmath::rotate(f * 0.34f, 0.0f, 1.0f, 0.0f) *
        vmath::translate(0.0f, -4.0f, 0.0f);
        
        vmath::mat4 plane_matrix = vmath::rotate(f * 6.0f, 1.0f, 0.0f, 0.0f) *
        vmath::rotate(f * 7.3f, 0.0f, 1.0f, 0.0f);
        
        vmath::vec4 plane = plane_matrix[0];
        plane[3] = 0.0f;
        plane = vmath::normalize(plane);
        
        vmath::vec4 clip_sphere = vmath::vec4(sinf(f * 0.7f) * 3.0f, cosf(f * 1.9f) * 3.0f, sinf(f * 0.1f) * 3.0f, cosf(f * 1.7f) + 2.5f);
        
        glUniformMatrix4fv(_uniforms.proj_matrix, 1, GL_FALSE, proj_matrix);
        glUniformMatrix4fv(_uniforms.mv_matrix, 1, GL_FALSE, mv_matrix);
        glUniform4fv(_uniforms.clip_plane, 1, plane);
        glUniform4fv(_uniforms.clip_sphere, 1, clip_sphere);
        
        glEnable(GL_DEPTH_TEST);
        glEnable(GL_CLIP_DISTANCE0);
        glEnable(GL_CLIP_DISTANCE1);
        
        _object->render();
    }
    
    [self.openGLView.openGLContext flushBuffer];
}

- (BOOL)processEvent:(NSEvent *)event
{
    BOOL processed = NO;
    
    if (event.type == NSEventTypeKeyDown)
    {
        switch(event.keyCode)
        {
            case /*kVK_ANSI_P*/0x23:
            {
                _paused = !_paused;
                break;
            }
                
            case /*kVK_ANSI_R*/0x0F:
            {
                break;
            }
        }
    }
    
    return processed;
}

@end
