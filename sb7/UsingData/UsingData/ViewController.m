//
//  ViewController.m
//  UsingData
//
//  Created by tolik7071 on 5/3/18.
//  Copyright © 2018 tolik7071. All rights reserved.
//

#import "ViewController.h"
#import <OpenGL/gl3.h>
#import "GLUtilities.h"

@implementation ViewController
{
    GLuint  _programID;
    GLuint  _VAO;
    GLuint  _VBO;
}

- (void)cleanup
{
    [super cleanup];
    
    if (0 != _programID)
    {
        glDeleteProgram(_programID);
    }
    
    if (0 != _VAO)
    {
        glDeleteVertexArrays(1, &_VAO);
    }
    
    if (0 != _VBO)
    {
        glDeleteBuffers(1, &_VBO);
    }
}

- (void)configOpenGLEnvironment
{
    NSAssert(self.openGLView != nil, @"ERROR: openGLView is NULL");
    
    [self.openGLView.openGLContext makeCurrentContext];
    
    glEnable(GL_DEPTH_TEST);
    
    NSURL *vertexShader = FindResourceWithName(@"triangle.vert");
    NSAssert(vertexShader, @"Cannot find shader.");
    NSData *vertexShaderContent = ReadFile(vertexShader);
    NSAssert([vertexShaderContent length] > 0, @"Empty shader.");
    
    NSURL *fragmentShader = FindResourceWithName(@"triangle.frag");
    NSAssert(fragmentShader, @"Cannot find shader.");
    NSData *fragmentShaderContent = ReadFile(fragmentShader);
    NSAssert([fragmentShaderContent length] > 0, @"Empty shader.");
    
    _programID = CreateProgram(vertexShaderContent, fragmentShaderContent);
    NSAssert(_programID != 0, @"Cannot compile program.");
    
    glUseProgram(_programID);
    
    GLfloat vertices[] =
    {
        // verteces           // colors
        -0.5f, -0.5f, -0.5f,  0.0f, 0.0f, 1.0f,
         0.5f, -0.5f, -0.5f,  1.0f, 0.0f, 0.0f,
         0.5f,  0.5f, -0.5f,  1.0f, 1.0f, 0.0f
    };
    
    glGenVertexArrays(1, &_VAO);
    glGenBuffers(1, &_VBO);
    
    glBindVertexArray(_VAO);
    
    glBindBuffer(GL_ARRAY_BUFFER, _VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    assert(0 == glGetAttribLocation(_programID, "position"));
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(GLfloat), (void*)0);
    glEnableVertexAttribArray(0);
    
    assert(1 == glGetAttribLocation(_programID, "color"));
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(GLfloat), (void*)(3 * sizeof(GLfloat)));
    glEnableVertexAttribArray(1);
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
    
    if (0 != _programID)
    {
        glUseProgram(_programID);
        
        glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        
        glBindVertexArray(_VAO);
        
        glDrawArrays(GL_TRIANGLES, 0, 3);
    }
    
    [self.openGLView.openGLContext flushBuffer];
}

@end
