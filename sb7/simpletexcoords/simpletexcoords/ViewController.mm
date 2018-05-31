//
//  ViewController.m
//  simpletexcoords
//
//  Created by tolik7071 on 5/29/18.
//  Copyright © 2018 tolik7071. All rights reserved.
//

#import "ViewController.h"
#import "GLUtilities.h"
#import <OpenGL/gl3.h>
#import <OpenGL/gl3ext.h>
//#include <OpenGL/OpenGL.h>
#include <vmath.h>
#include <object.h>
#include <shader.h>
#include <sb7ktx.h>

typedef struct _uniforms_tag
{
    GLint       mv_matrix;
    GLint       proj_matrix;
} Uniforms;

@implementation ViewController
{
    GLuint      _programID;
    GLuint      _VAO;
    GLuint      _tex_object[2];
    GLuint      _tex_index;
    sb7::object _object;
    Uniforms    _uniforms;
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
    
    if (0 != _tex_object[0])
    {
        glDeleteTextures(2, _tex_object);
        memset(_tex_object, 0, sizeof(_tex_object));
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
    
#define B 0x00, 0x00, 0x00, 0x00
#define W 0xFF, 0xFF, 0xFF, 0xFF
    static const GLubyte tex_data[] =
    {
        B, W, B, W, B, W, B, W, B, W, B, W, B, W, B, W,
        W, B, W, B, W, B, W, B, W, B, W, B, W, B, W, B,
        B, W, B, W, B, W, B, W, B, W, B, W, B, W, B, W,
        W, B, W, B, W, B, W, B, W, B, W, B, W, B, W, B,
        B, W, B, W, B, W, B, W, B, W, B, W, B, W, B, W,
        W, B, W, B, W, B, W, B, W, B, W, B, W, B, W, B,
        B, W, B, W, B, W, B, W, B, W, B, W, B, W, B, W,
        W, B, W, B, W, B, W, B, W, B, W, B, W, B, W, B,
        B, W, B, W, B, W, B, W, B, W, B, W, B, W, B, W,
        W, B, W, B, W, B, W, B, W, B, W, B, W, B, W, B,
        B, W, B, W, B, W, B, W, B, W, B, W, B, W, B, W,
        W, B, W, B, W, B, W, B, W, B, W, B, W, B, W, B,
        B, W, B, W, B, W, B, W, B, W, B, W, B, W, B, W,
        W, B, W, B, W, B, W, B, W, B, W, B, W, B, W, B,
        B, W, B, W, B, W, B, W, B, W, B, W, B, W, B, W,
        W, B, W, B, W, B, W, B, W, B, W, B, W, B, W, B,
    };
#undef B
#undef W
 
    glGenTextures(1, &_tex_object[0]);
    glBindTexture(GL_TEXTURE_2D, _tex_object[0]);
    glTexStorage2D(GL_TEXTURE_2D, 1, GL_RGB8, 16, 16);

    glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, 16, 16, GL_RGBA, GL_UNSIGNED_BYTE, tex_data);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    
    NSURL *url = FindResourceWithName(@"pattern1.ktx");
    NSAssert(url, @"Resource not found.");
    _tex_object[1] = sb7::ktx::file::load([url fileSystemRepresentation]);
    
    url = FindResourceWithName(@"torus_nrms_tc.sbm");
    NSAssert(url, @"Resource not found.");
    _object.load([url fileSystemRepresentation]);
    
    [self loadShaders];
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
    
    static const GLfloat gray[] = { 0.2f, 0.2f, 0.2f, 1.0f };
    static const GLfloat ones[] = { 1.0f };
    
    glClearBufferfv(GL_COLOR, 0, gray);
    glClearBufferfv(GL_DEPTH, 0, ones);
    
    if (0 != _programID)
    {
        glBindTexture(GL_TEXTURE_2D, _tex_object[_tex_index]);
        
        glUseProgram(_programID);
        
        vmath::mat4 proj_matrix = vmath::perspective(
            60.0f,
            (float)self.openGLView.frame.size.width / (float)self.openGLView.frame.size.height,
            0.1f,
            1000.0f);
        vmath::mat4 mv_matrix = vmath::translate(0.0f, 0.0f, -3.0f) *
        vmath::rotate((float)currentTime * 19.3f, 0.0f, 1.0f, 0.0f) *
        vmath::rotate((float)currentTime * 21.1f, 0.0f, 0.0f, 1.0f);
        
        glUniformMatrix4fv(_uniforms.mv_matrix, 1, GL_FALSE, mv_matrix);
        glUniformMatrix4fv(_uniforms.proj_matrix, 1, GL_FALSE, proj_matrix);
        
        _object.render();
    }
    
    [self.openGLView.openGLContext flushBuffer];
}

- (void)loadShaders
{
    if (0 != _programID)
    {
        glDeleteProgram(_programID);
    }
    
    _programID = CreateProgram(@"render.vs.glsl", @"render.fs.glsl");
    
    _uniforms.mv_matrix = glGetUniformLocation(_programID, "mv_matrix");
    _uniforms.proj_matrix = glGetUniformLocation(_programID, "proj_matrix");
}

- (BOOL)processEvent:(NSEvent *)event
{
    BOOL processed = NO;
    
    if (event.type == NSEventTypeKeyDown)
    {
        switch(event.keyCode)
        {
            case /*kVK_ANSI_R*/ 0x0F:
            {
                [self loadShaders];
                break;
            }
            
            case /*kVK_ANSI_T*/ 0x11:
            {
                if (++_tex_index > 1)
                {
                    _tex_index = 0;
                }
                break;
            }
        }
    }
    
    return processed;
}

@end
