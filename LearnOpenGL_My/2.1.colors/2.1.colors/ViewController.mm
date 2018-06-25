//
//  ViewController.m
//  2.1.colors
//
//  Created by tolik7071 on 9/18/17.
//  Copyright © 2017 tolik7071. All rights reserved.
//

#import "ViewController.h"
#import <OpenGL/gl3.h>
#include <learnopengl/filesystem.h>
#include <learnopengl/shader_m.h>
#include <learnopengl/camera.h>
#define STB_IMAGE_IMPLEMENTATION
#include <stb_image.h>

CVReturn DisplayCallback(CVDisplayLinkRef, const CVTimeStamp*, const CVTimeStamp*, CVOptionFlags, CVOptionFlags*, void*);

@implementation ViewController
{
    id                  _monitor;
    CVDisplayLinkRef    _displayLink;
    GLuint              _VBO, _cubeVAO, _lightVAO;
    Camera*             _camera;
    Shader*             _lightingShader;
    Shader*             _lampShader;
    float               _deltaTime, _lastFrame;
}

- (void)dealloc
{
    if (NULL != _displayLink)
    {
        CVDisplayLinkStop(_displayLink);
        CVDisplayLinkRelease(_displayLink);
    }
    
    if (nil != _monitor)
    {
        [NSEvent removeMonitor:_monitor];
    }
    
    glDeleteVertexArrays(1, &_cubeVAO);
    glDeleteVertexArrays(1, &_lightVAO);
    glDeleteBuffers(1, &_VBO);
    
    delete _lightingShader;
    delete _lampShader;
    delete _camera;
}

- (void)configOpenGLView
{
    NSAssert(self.openGLView != nil, @"ERROR: openGLView is NULL");
    
    NSOpenGLPixelFormatAttribute pixelFormatAttributes[] =
    {
        NSOpenGLPFAOpenGLProfile, NSOpenGLProfileVersion3_2Core,
        NSOpenGLPFAColorSize    , 24                           ,
        NSOpenGLPFAAlphaSize    , 8                            ,
        NSOpenGLPFADepthSize    , 16                           ,
        NSOpenGLPFADoubleBuffer ,
        NSOpenGLPFAAccelerated  ,
        NSOpenGLPFANoRecovery   ,
        0
    };
    
    NSOpenGLPixelFormat *pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:pixelFormatAttributes];
    self.openGLView.pixelFormat = pixelFormat;
}

- (void)configDisplayLink
{
    CGDirectDisplayID displayID = CGMainDisplayID();
    CVReturn error = CVDisplayLinkCreateWithCGDisplay(displayID, &_displayLink);
    
    if (kCVReturnSuccess == error)
    {
        CVDisplayLinkSetOutputCallback(_displayLink, DisplayCallback, (__bridge void * _Nullable)(self));
        CVDisplayLinkStart(_displayLink);
    }
    else
    {
        NSLog(@"Display Link created with error: %d", error);
    }
}

- (void)configEventMonitor
{
    _monitor = [NSEvent addLocalMonitorForEventsMatchingMask:
                (NSEventMaskKeyDown | NSEventMaskScrollWheel)handler:^NSEvent* (NSEvent* event)
                {
                    [self processEvent:event];
                    return event;
                }];
}

- (void)configOpenGLEnvironment
{
    NSAssert(self.openGLView != nil, @"ERROR: openGLView is NULL");
    
    [self.openGLView.openGLContext makeCurrentContext];
    
    NSURL *color_vs = [self findResourceWithName:@"1.colors.vs"];
    NSAssert(color_vs, @"Cannot to find out a shader");
    NSURL *color_fs = [self findResourceWithName:@"1.colors.fs"];
    NSAssert(color_fs, @"Cannot to find out a shader");
    
    _lightingShader = new Shader([color_vs fileSystemRepresentation], [color_fs fileSystemRepresentation]);
    
    NSURL *lamp_vs = [self findResourceWithName:@"1.lamp.vs"];
    NSAssert(lamp_vs, @"Cannot to find out a shader");
    NSURL *lamp_fs = [self findResourceWithName:@"1.lamp.fs"];
    NSAssert(lamp_fs, @"Cannot to find out a shader");
    
    _lampShader = new Shader([lamp_vs fileSystemRepresentation], [lamp_fs fileSystemRepresentation]);
    
    _camera = new Camera(glm::vec3(0.0f, 0.0f, 3.0f));
    
    glEnable(GL_DEPTH_TEST);
    
    float vertices[] =
    {
        -0.5f, -0.5f, -0.5f,
         0.5f, -0.5f, -0.5f,
         0.5f,  0.5f, -0.5f,
         0.5f,  0.5f, -0.5f,
        -0.5f,  0.5f, -0.5f,
        -0.5f, -0.5f, -0.5f,
        
        -0.5f, -0.5f,  0.5f,
         0.5f, -0.5f,  0.5f,
         0.5f,  0.5f,  0.5f,
         0.5f,  0.5f,  0.5f,
        -0.5f,  0.5f,  0.5f,
        -0.5f, -0.5f,  0.5f,
        
        -0.5f,  0.5f,  0.5f,
        -0.5f,  0.5f, -0.5f,
        -0.5f, -0.5f, -0.5f,
        -0.5f, -0.5f, -0.5f,
        -0.5f, -0.5f,  0.5f,
        -0.5f,  0.5f,  0.5f,
        
         0.5f,  0.5f,  0.5f,
         0.5f,  0.5f, -0.5f,
         0.5f, -0.5f, -0.5f,
         0.5f, -0.5f, -0.5f,
         0.5f, -0.5f,  0.5f,
         0.5f,  0.5f,  0.5f,
        
        -0.5f, -0.5f, -0.5f,
         0.5f, -0.5f, -0.5f,
         0.5f, -0.5f,  0.5f,
         0.5f, -0.5f,  0.5f,
        -0.5f, -0.5f,  0.5f,
        -0.5f, -0.5f, -0.5f,
        
        -0.5f,  0.5f, -0.5f,
         0.5f,  0.5f, -0.5f,
         0.5f,  0.5f,  0.5f,
         0.5f,  0.5f,  0.5f,
        -0.5f,  0.5f,  0.5f,
        -0.5f,  0.5f, -0.5f,
    };
    
    glGenBuffers(1, &_VBO);
    
    glBindBuffer(GL_ARRAY_BUFFER, _VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    glGenVertexArrays(1, &_cubeVAO);
    
    glBindVertexArray(_cubeVAO);
    
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void*)0);
    glEnableVertexAttribArray(0);
    
    glGenVertexArrays(1, &_lightVAO);
    glBindVertexArray(_lightVAO);
    
    glBindBuffer(GL_ARRAY_BUFFER, _VBO);
    
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void*)0);
    glEnableVertexAttribArray(0);
}

- (BOOL)processEvent:(NSEvent *)event
{
    if (event.type == NSEventTypeKeyDown)
    {
        switch(event.keyCode)
        {
            case /*kVK_ANSI_W*/0x0D:
            {
                _camera->ProcessKeyboard(FORWARD, _deltaTime);
                break;
            }
                
            case /*kVK_ANSI_S*/0x01:
            {
                _camera->ProcessKeyboard(BACKWARD, _deltaTime);
                break;
            }
                
            case /*kVK_ANSI_A*/0x00:
            {
                _camera->ProcessKeyboard(LEFT, _deltaTime);
                break;
            }
                
            case /*kVK_ANSI_D*/0x02:
            {
                _camera->ProcessKeyboard(RIGHT, _deltaTime);
                break;
            }
        }
    }
    else if (event.type == NSEventTypeScrollWheel)
    {
        _camera->ProcessMouseScroll(event.deltaY);
    }
    
    return YES;
}

- (NSURL *)findResourceWithName:(NSString *)aName
{
    NSURL *result = [[NSBundle mainBundle]
                     URLForResource:[aName stringByDeletingPathExtension]
                     withExtension:[aName pathExtension]];
    
    return result;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configOpenGLView];
    
    [self configOpenGLEnvironment];
    
    [self configEventMonitor];
    
    [self configDisplayLink];
}

- (void)viewWillLayout
{
    [super viewWillLayout];
    
    [self.openGLView.openGLContext makeCurrentContext];
    
    glViewport(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

- (void)renderForTime:(CVTimeStamp)time
{
    if ([self.view inLiveResize])
    {
        return;
    }
    
    [self.openGLView.openGLContext makeCurrentContext];
    
    GLfloat currentTime = (GLfloat)(time.videoTime) / (GLfloat)(time.videoTimeScale);
    _deltaTime = currentTime - _lastFrame;
    _lastFrame = currentTime;
    
    glClearColor(0.1f, 0.1f, 0.1f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    if (_lightingShader != NULL && _lampShader != NULL)
    {
        _lightingShader->use();
        _lightingShader->setVec3("objectColor", 1.0f, 0.5f, 0.31f);
        _lightingShader->setVec3("lightColor",  1.0f, 1.0f, 1.0f);
        
        glm::mat4 projection = glm::perspective(
            glm::radians(_camera->Zoom),
            (float)self.view.frame.size.width / (float)self.view.frame.size.height,
            0.1f, 100.0f);
        glm::mat4 view = _camera->GetViewMatrix();
        
        _lightingShader->setMat4("projection", projection);
        _lightingShader->setMat4("view", view);
        
        glm::mat4 model;
        _lightingShader->setMat4("model", model);
        
        glBindVertexArray(_cubeVAO);
        glDrawArrays(GL_TRIANGLES, 0, 36);
        
        _lampShader->use();
        _lampShader->setMat4("projection", projection);
        _lampShader->setMat4("view", view);
        model = glm::mat4();
        model = glm::translate(model, [self lightPos]);
        model = glm::scale(model, glm::vec3(0.2f));
        _lampShader->setMat4("model", model);
        
        glBindVertexArray(_lightVAO);
        glDrawArrays(GL_TRIANGLES, 0, 36);
    }
    
    [self.openGLView.openGLContext flushBuffer];
}

- (glm::vec3)lightPos
{
    return glm::vec3(1.2f, 1.0f, 2.0f);
}

@end

CVReturn DisplayCallback(
    CVDisplayLinkRef displayLink,
    const CVTimeStamp *inNow,
    const CVTimeStamp *inOutputTime,
    CVOptionFlags flagsIn,
    CVOptionFlags *flagsOut,
    void *displayLinkContext)
{
    ViewController *controller = (__bridge ViewController *)displayLinkContext;
    [controller renderForTime:*inOutputTime];
    
    return kCVReturnSuccess;
}
