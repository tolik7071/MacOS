//
//  ViewController.m
//  4.1.textures
//
//  Created by tolik7071 on 9/12/17.
//  Copyright © 2017 tolik7071. All rights reserved.
//

#import "ViewController.h"
#import <OpenGL/gl3.h>
#include <learnopengl/filesystem.h>
#include <learnopengl/shader_m.h>
#define STB_IMAGE_IMPLEMENTATION
#include <stb_image.h>
//#include <glm/glm.hpp>
//#include <glm/gtc/matrix_transform.hpp>
//#include <glm/gtc/type_ptr.hpp>

CVReturn DisplayCallback(CVDisplayLinkRef, const CVTimeStamp*, const CVTimeStamp*, CVOptionFlags, CVOptionFlags*, void*);

@implementation ViewController
{
    id                  _monitor;
    CVDisplayLinkRef    _displayLink;
    GLuint              _VBO, _VAO, _EBO;
    Shader*             _shader;
    unsigned int        _texture;
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
    
    glDeleteVertexArrays(1, &_VAO);
    glDeleteBuffers(1, &_VBO);
    glDeleteBuffers(1, &_EBO);
    
    delete _shader;
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

- (void)configEventMonitor
{
    _monitor = [NSEvent addLocalMonitorForEventsMatchingMask:
        (NSEventMaskKeyDown)handler:^NSEvent* (NSEvent* event)
        {
            [self processEvent:event];
            return event;
        }];
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

- (void)configOpenGLEnvironment
{
    NSAssert(self.openGLView != nil, @"ERROR: openGLView is NULL");
    
    [self.openGLView.openGLContext makeCurrentContext];
    
    NSURL *vs = [self findResourceWithName:@"4.1.texture.vs"];
    NSURL *fs = [self findResourceWithName:@"4.1.texture.fs"];
    _shader = new Shader([vs fileSystemRepresentation], [fs fileSystemRepresentation]);
    
    float vertices[] =
    {
        // positions          // colors           // texture coords
         0.5f,  0.5f, 0.0f,   1.0f, 0.0f, 0.0f,   1.0f, 1.0f, // top right
         0.5f, -0.5f, 0.0f,   0.0f, 1.0f, 0.0f,   1.0f, 0.0f, // bottom right
        -0.5f, -0.5f, 0.0f,   0.0f, 0.0f, 1.0f,   0.0f, 0.0f, // bottom left
        -0.5f,  0.5f, 0.0f,   1.0f, 1.0f, 0.0f,   0.0f, 1.0f  // top left
    };
    
    const size_t kElementSize = sizeof(vertices[0]);
    
    unsigned int indices[] =
    {
        0, 1, 3, // first triangle
        1, 2, 3  // second triangle
    };
    
    glGenVertexArrays(1, &_VAO);
    glGenBuffers(1, &_VBO);
    glGenBuffers(1, &_EBO);
    
    glBindVertexArray(_VAO);
    
    glBindBuffer(GL_ARRAY_BUFFER, _VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _EBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    
    // layout (location = 0) in vec3 aPos;
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 8 * kElementSize, (void*)0);
    glEnableVertexAttribArray(0);
    
    // layout (location = 1) in vec3 aColor;
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 8 * kElementSize, (void*)(3 * kElementSize));
    glEnableVertexAttribArray(1);
    
    // layout (location = 2) in vec2 aTexCoord;
    glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, 8 * kElementSize, (void*)(6 * kElementSize));
    glEnableVertexAttribArray(2);
    
    glActiveTexture(GL_TEXTURE0);
    
    glGenTextures(1, &_texture);
    glBindTexture(GL_TEXTURE_2D, _texture);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    NSURL *background = [self findResourceWithName:@"background.jpg"];
    
    stbi_set_flip_vertically_on_load(true);
    
    int width = 0, height = 0, nrChannels = 0;
    unsigned char *data = stbi_load([background fileSystemRepresentation], &width, &height, &nrChannels, 0);
    if (data != NULL)
    {
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, data);
        glGenerateMipmap(GL_TEXTURE_2D);
    }
    else
    {
        NSLog(@"ERROR: Failed to load texture.");
    }
    
    stbi_image_free(data);
    
    glEnable(GL_DEPTH_TEST);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configOpenGLView];
    
    [self configEventMonitor];
    
    [self configDisplayLink];
    
    [self configOpenGLEnvironment];
}

- (void)viewWillLayout
{
    [super viewWillLayout];
    
    [self.openGLView.openGLContext makeCurrentContext];
    
    glViewport(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

- (NSURL *)findResourceWithName:(NSString *)aName
{
    NSURL *result = [[NSBundle mainBundle]
        URLForResource:[aName stringByDeletingPathExtension]
        withExtension:[aName pathExtension]];
    
    return result;
}

- (void)renderForTime:(CVTimeStamp)time
{
    if ([self.view inLiveResize])
    {
        return;
    }
    
    [self.openGLView.openGLContext makeCurrentContext];
    
    glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    if (_shader != NULL)
    {
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, _texture);
        
        _shader->use();
        
        glBindVertexArray(_VAO);
        
        glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
    }
    
    [self.openGLView.openGLContext flushBuffer];
}

- (BOOL)processEvent:(NSEvent *)event
{
    return YES;
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
