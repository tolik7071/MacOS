//
//  ViewController.m
//  noperspective
//
//  Created by tolik7071 on 2/18/19.
//  Copyright © 2019 tolik7071. All rights reserved.
//

#import "ViewController.h"
#import "GLUtilities.h"
#import <OpenGL/gl3.h>
#import <OpenGL/gl3ext.h>
#include <vmath.h>

typedef struct
{
    GLint       mvp;
    GLint       use_perspective;
} TUniforms;

@implementation ViewController
{
    GLuint          _program;
    GLuint          _vao;
    GLuint          _tex_checker;
    bool            _paused;
    bool            _use_perspective;
    TUniforms       _uniforms;
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
    
    _program = CreateProgram(@"noperspective.vert", @"noperspective.frag");
    
    _uniforms.mvp = glGetUniformLocation(_program, "mvp");
    _uniforms.use_perspective = glGetUniformLocation(_program, "use_perspective");
    
    glGenVertexArrays(1, &_vao);
    glBindVertexArray(_vao);
    
    static const unsigned char checker_data[] =
    {
        0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF,
        0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00,
        0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF,
        0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00,
        0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF,
        0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00,
        0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF,
        0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00,
    };
    
    glGenTextures(1, &_tex_checker);
    glBindTexture(GL_TEXTURE_2D, _tex_checker);
    glTexStorage2D(GL_TEXTURE_2D, 1, GL_R8, 8, 8);
    glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, 8, 8, GL_RED, GL_UNSIGNED_BYTE, checker_data);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
}

- (void)renderForTime:(MyTimeStamp *)time
{
    if ([self.view inLiveResize])
    {
        return;
    }
 
    static double total_time = 0.0;
    
    GLfloat currentTime = (GLfloat)(time->_timeStamp.videoTime) / (GLfloat)(time->_timeStamp.videoTimeScale);
    _deltaTime = currentTime - _lastFrame;
    
    if (!_paused)
    {
        total_time += (currentTime - _lastFrame);
    }
    
    _lastFrame = currentTime;
    
    [self.openGLView.openGLContext makeCurrentContext];
    
    float t = (float)total_time * 14.3f;
    
    static const GLfloat black[] = { 0.0f, 0.0f, 0.0f, 0.0f };
    static const GLfloat one = 1.0f;
    
    glViewport(0, 0, self.openGLView.frame.size.width, self.openGLView.frame.size.height);
    glClearBufferfv(GL_COLOR, 0, black);
    glClearBufferfv(GL_DEPTH, 0, &one);
    
    vmath::mat4 mv_matrix = vmath::translate(0.0f, 0.0f, -1.5f) *
    vmath::rotate(t, 0.0f, 1.0f, 0.0f);
    vmath::mat4 proj_matrix = vmath::perspective(60.0f,
        (float)self.openGLView.frame.size.width / (float)self.openGLView.frame.size.height,
        0.1f, 1000.0f);
    
    glUseProgram(_program);
    
    glUniformMatrix4fv(_uniforms.mvp, 1, GL_FALSE, proj_matrix * mv_matrix);
    glUniform1i(_uniforms.use_perspective, _use_perspective);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    [self.openGLView.openGLContext flushBuffer];
}

- (BOOL)processEvent:(NSEvent *)event
{
    BOOL processed = NO;
    
    if (event.type == NSEventTypeKeyDown)
    {
        switch(event.keyCode)
        {
            case /*kVK_ANSI_M*/0x2E:
            {
                _use_perspective = !_use_perspective;
                break;
            }
                
            case /*kVK_ANSI_P*/0x23:
            {
                _paused = !_paused;
                break;
            }
        }
    }
    
    return processed;
}

@end
