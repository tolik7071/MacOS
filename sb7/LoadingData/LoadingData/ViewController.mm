//
//  ViewController.m
//  LoadingData
//
//  Created by tolik7071 on 5/5/18.
//  Copyright © 2018 tolik7071. All rights reserved.
//

#import "ViewController.h"
#import <OpenGL/gl3.h>
#include "object.h"
#import "GLUtilities.h"

@implementation ViewController
{
    GLuint  _VAO;
    sb7::object *_objectReader;
}

- (void)cleanup
{
    [super cleanup];
    
    if (0 != _VAO)
    {
        glDeleteVertexArrays(1, &_VAO);
    }
    
    if (_objectReader)
    {
        _objectReader->free();
        delete _objectReader;
        _objectReader = NULL;
    }
}

- (void)configOpenGLEnvironment
{
    NSAssert(self.openGLView != nil, @"ERROR: openGLView is NULL");
    
    [self.openGLView.openGLContext makeCurrentContext];
    
    glEnable(GL_DEPTH_TEST);
    
//    glGenVertexArrays(1, &_VAO);
//    glBindVertexArray(_VAO);
    
    NSURL *dataUrl = ::FindResourceWithName(@"cube.sbm");
    NSAssert(dataUrl, @"Cannot find resource.");
    
    _objectReader = new sb7::object();
    _objectReader->load([dataUrl fileSystemRepresentation]);
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
    
    glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    if (_objectReader)
    {
        _objectReader->render();
    }
    
    [self.openGLView.openGLContext flushBuffer];
}

@end
