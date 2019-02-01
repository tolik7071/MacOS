//
//  ViewController.m
//  dispmap
//
//  Created by tolik7071 on 2/1/19.
//  Copyright © 2019 tolik7071. All rights reserved.
//

#import "ViewController.h"
#import "GLUtilities.h"
#import <OpenGL/gl3.h>
#import <OpenGL/gl3ext.h>
#include <sb7ktx.h>
#include <vmath.h>
#include <shader.h>

typedef struct
{
    GLint mvp_matrix;
    GLint mv_matrix;
    GLint proj_matrix;
    GLint dmap_depth;
    GLint enable_fog;
} TUniforms;

@implementation ViewController
{
    GLuint _VAO;
    GLuint _programID;
    GLuint _tex_displacement;
    GLuint _tex_color;
    float _dmap_depth;
    bool _enable_displacement;
    bool _wireframe;
    bool _enable_fog;
    bool _paused;
}

- (void)cleanup
{
    [super cleanup];
    
    if (0 != _VAO)
    {
        glDeleteVertexArrays(1, &_VAO);
        _VAO = 0;
    }
    
    if (0 != _programID)
    {
        glDeleteProgram(_programID);
        _programID = 0;
    }
}

- (void)configOpenGLEnvironment
{
    NSAssert(self.openGLView != nil, @"ERROR: openGLView is NULL");
    
    [self.openGLView.openGLContext makeCurrentContext];
    
    _enable_displacement = true;
    _enable_fog = true;
    
    // TODO: load shaders
    
    glGenVertexArrays(1, &_VAO);
    glBindVertexArray(_VAO);
    
    glPatchParameteri(GL_PATCH_VERTICES, 4);
    glEnable(GL_CULL_FACE);
    
    NSURL *url = FindResourceWithName(@"terragen1.ktx");
    _tex_displacement = sb7::ktx::file::load([url fileSystemRepresentation]);
    
    glActiveTexture(GL_TEXTURE1);
    
    url = FindResourceWithName(@"terragen_color.ktx");
    _tex_color = sb7::ktx::file::load([url fileSystemRepresentation]);
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
    
    [self.openGLView.openGLContext makeCurrentContext];
    
    const GLfloat backgroundColor[] = { 0.2f, 0.2f, 0.2f, 1.0f };
    glClearBufferfv(GL_COLOR, 0, backgroundColor);
    
    [self.openGLView.openGLContext flushBuffer];
}

@end
