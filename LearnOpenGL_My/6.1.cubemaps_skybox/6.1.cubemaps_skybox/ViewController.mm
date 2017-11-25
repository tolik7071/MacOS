//
//  ViewController.m
//  4.2.lighting_maps_specular_map
//
//  Created by tolik7071 on 9/25/17.
//  Copyright © 2017 tolik7071. All rights reserved.
//

#import "ViewController.h"
#import <OpenGL/gl3.h>
#include <glad/glad.h>
#include <stb_image.h>
#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/type_ptr.hpp>
#include <learnopengl/filesystem.h>
#include <learnopengl/shader_m.h>
#include <learnopengl/camera.h>
#include <learnopengl/model.h>
#include <vector>
#include <map>

CVReturn DisplayCallback(CVDisplayLinkRef, const CVTimeStamp*, const CVTimeStamp*, CVOptionFlags, CVOptionFlags*, void*);

@implementation ViewController
{
    id                  _monitor;
    CVDisplayLinkRef    _displayLink;
    GLuint              _cubeVAO, _cubeVBO;
    GLuint              _skyboxVAO, _skyboxVBO;
    Camera*             _camera;
    Shader*             _shader;
    Shader*             _skyboxShader;
    GLfloat             _deltaTime;
    GLfloat             _lastFrame;
    GLuint              _cubeTexture;
    GLuint              _cubemapTexture;
}

- (void)dealloc
{
    [self cleanup];
}

- (void)cleanup
{
    if (NULL != _displayLink)
    {
        CVDisplayLinkStop(_displayLink);
        CVDisplayLinkRelease(_displayLink);
        _displayLink = NULL;
    }
    
    if (nil != _monitor)
    {
        [NSEvent removeMonitor:_monitor];
        _monitor = nil;
    }
    
    glDeleteVertexArrays(1, &_cubeVAO);
    glDeleteBuffers(1, &_cubeVBO);
    _cubeVAO = _cubeVBO = 0;
    
    glDeleteVertexArrays(1, &_skyboxVAO);
    glDeleteBuffers(1, &_skyboxVBO);
    _skyboxVAO = _skyboxVBO = 0;
    
    delete _shader;
    _shader = NULL;
    delete _skyboxShader;
    _skyboxShader = NULL;
    delete _camera;
    _camera = NULL;
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
        NSOpenGLPFAAllowOfflineRenderers,
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
    _monitor = [NSEvent addLocalMonitorForEventsMatchingMask:(NSEventMaskKeyDown | NSEventMaskScrollWheel | NSEventMaskLeftMouseDragged)
        handler:^NSEvent* (NSEvent* event)
        {
            BOOL processEvent = [self processEvent:event];
            return processEvent ? event : nil;
        }
    ];
}

- (void)configOpenGLEnvironment
{
    NSAssert(self.openGLView != nil, @"ERROR: openGLView is NULL");
    
    [self.openGLView.openGLContext makeCurrentContext];
    
    glEnable(GL_TEXTURE_CUBE_MAP);
    glEnable(GL_DEPTH_TEST);
    
    {
        NSURL *shader_vs = [self findResourceWithName:@"6.1.cubemaps.vs"];
        NSAssert(shader_vs, @"Cannot to find out a shader");
        
        NSURL *shader_fs = [self findResourceWithName:@"6.1.cubemaps.fs"];
        NSAssert(shader_fs, @"Cannot to find out a shader");
        
        _shader = new Shader([shader_vs fileSystemRepresentation], [shader_fs fileSystemRepresentation]);
    }
    
    {
        NSURL *shader_vs = [self findResourceWithName:@"6.1.skybox.vs"];
        NSAssert(shader_vs, @"Cannot to find out a shader");
        
        NSURL *shader_fs = [self findResourceWithName:@"6.1.skybox.fs"];
        NSAssert(shader_fs, @"Cannot to find out a shader");
        
        _skyboxShader = new Shader([shader_vs fileSystemRepresentation], [shader_fs fileSystemRepresentation]);
    }
    
    // set up vertex data (and buffer(s)) and configure vertex attributes
    
    float cubeVertices[] =
    {
        // positions          // texture Coords
        -0.5f, -0.5f, -0.5f,  0.0f, 0.0f,
         0.5f, -0.5f, -0.5f,  1.0f, 0.0f,
         0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
         0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
        -0.5f,  0.5f, -0.5f,  0.0f, 1.0f,
        -0.5f, -0.5f, -0.5f,  0.0f, 0.0f,
        
        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
         0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
         0.5f,  0.5f,  0.5f,  1.0f, 1.0f,
         0.5f,  0.5f,  0.5f,  1.0f, 1.0f,
        -0.5f,  0.5f,  0.5f,  0.0f, 1.0f,
        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
        
        -0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
        -0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
        -0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
        
         0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
         0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
         0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
         0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
         0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
         0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
        
        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
         0.5f, -0.5f, -0.5f,  1.0f, 1.0f,
         0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
         0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
        
        -0.5f,  0.5f, -0.5f,  0.0f, 1.0f,
         0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
         0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
         0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
        -0.5f,  0.5f,  0.5f,  0.0f, 0.0f,
        -0.5f,  0.5f, -0.5f,  0.0f, 1.0f
    };
    
    float skyboxVertices[] =
    {
        // positions
        -1.0f,  1.0f, -1.0f,
        -1.0f, -1.0f, -1.0f,
         1.0f, -1.0f, -1.0f,
         1.0f, -1.0f, -1.0f,
         1.0f,  1.0f, -1.0f,
        -1.0f,  1.0f, -1.0f,
        
        -1.0f, -1.0f,  1.0f,
        -1.0f, -1.0f, -1.0f,
        -1.0f,  1.0f, -1.0f,
        -1.0f,  1.0f, -1.0f,
        -1.0f,  1.0f,  1.0f,
        -1.0f, -1.0f,  1.0f,
        
         1.0f, -1.0f, -1.0f,
         1.0f, -1.0f,  1.0f,
         1.0f,  1.0f,  1.0f,
         1.0f,  1.0f,  1.0f,
         1.0f,  1.0f, -1.0f,
         1.0f, -1.0f, -1.0f,
        
        -1.0f, -1.0f,  1.0f,
        -1.0f,  1.0f,  1.0f,
         1.0f,  1.0f,  1.0f,
         1.0f,  1.0f,  1.0f,
         1.0f, -1.0f,  1.0f,
        -1.0f, -1.0f,  1.0f,
        
        -1.0f,  1.0f, -1.0f,
         1.0f,  1.0f, -1.0f,
         1.0f,  1.0f,  1.0f,
         1.0f,  1.0f,  1.0f,
        -1.0f,  1.0f,  1.0f,
        -1.0f,  1.0f, -1.0f,
        
        -1.0f, -1.0f, -1.0f,
        -1.0f, -1.0f,  1.0f,
         1.0f, -1.0f, -1.0f,
         1.0f, -1.0f, -1.0f,
        -1.0f, -1.0f,  1.0f,
         1.0f, -1.0f,  1.0f
    };
    
    // cube VAO
    
    glGenVertexArrays(1, &_cubeVAO);
    glGenBuffers(1, &_cubeVBO);
    glBindVertexArray(_cubeVAO);
    glBindBuffer(GL_ARRAY_BUFFER, _cubeVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(cubeVertices), &cubeVertices, GL_STATIC_DRAW);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void*)0);
    glEnableVertexAttribArray(1);
    glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void*)(3 * sizeof(float)));
    
    // skybox VAO
    
    glGenVertexArrays(1, &_skyboxVAO);
    glGenBuffers(1, &_skyboxVBO);
    glBindVertexArray(_skyboxVAO);
    glBindBuffer(GL_ARRAY_BUFFER, _skyboxVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(skyboxVertices), &skyboxVertices, GL_STATIC_DRAW);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void*)0);
    
    // load textures
    
    _cubeTexture = [self loadTexture:[[self findResourceWithName:@"textures/marble.jpg"] fileSystemRepresentation]];
    
    vector<std::string> faces
    {
        [[self findResourceWithName:@"textures/skybox/right.jpg"] fileSystemRepresentation],
        [[self findResourceWithName:@"textures/skybox/left.jpg"] fileSystemRepresentation],
        [[self findResourceWithName:@"textures/skybox/top.jpg"] fileSystemRepresentation],
        [[self findResourceWithName:@"textures/skybox/bottom.jpg"] fileSystemRepresentation],
        [[self findResourceWithName:@"textures/skybox/back.jpg"] fileSystemRepresentation],
        [[self findResourceWithName:@"textures/skybox/front.jpg"] fileSystemRepresentation]
    };
    
    _cubemapTexture = [self loadCubemap:faces];
    
    // shader configuration
    
    _shader->use();
    _shader->setInt("texture1", 0);
    
    _skyboxShader->use();
    _skyboxShader->setInt("skybox", 0);
    
    // camera
    
    _camera = new Camera(glm::vec3(0.0f, 0.0f, 3.0f));
}

- (BOOL)processEvent:(NSEvent *)event
{
    BOOL processEvent = YES;
    
    if (event.type == NSEventTypeKeyDown)
    {
        switch(event.keyCode)
        {
            case /*kVK_ANSI_W*/0x0D:
            {
                _camera->ProcessKeyboard(FORWARD, _deltaTime);
                processEvent = NO;
                break;
            }
                
            case /*kVK_ANSI_S*/0x01:
            {
                _camera->ProcessKeyboard(BACKWARD, _deltaTime);
                processEvent = NO;
                break;
            }
                
            case /*kVK_ANSI_A*/0x00:
            {
                _camera->ProcessKeyboard(LEFT, _deltaTime);
                processEvent = NO;
                break;
            }
                
            case /*kVK_ANSI_D*/0x02:
            {
                _camera->ProcessKeyboard(RIGHT, _deltaTime);
                processEvent = NO;
                break;
            }
        }
    }
    else if (event.type == NSEventTypeScrollWheel)
    {
        _camera->ProcessMouseScroll(event.deltaY);
        processEvent = NO;
    }
    else if (event.type == NSEventTypeLeftMouseDragged)
    {
        NSPoint point = [self.openGLView convertPoint:[event locationInWindow] fromView:nil];
        
        if ([self.openGLView hitTest:point])
        {
            _camera->ProcessMouseMovement(event.deltaX, event.deltaY);
            processEvent = NO;
        }
    }
    
    return processEvent;
}

- (NSURL *)findResourceWithName:(NSString *)aName
{
    NSURL *result = [[NSBundle mainBundle]
        URLForResource:[aName stringByDeletingPathExtension]
        withExtension:[aName pathExtension]];
    
    return result;
}

- (GLuint)loadTexture:(char const *)path
{
    GLuint textureID;
    glGenTextures(1, &textureID);
    
    int width = -1, height = -1, nrComponents = -1;
    unsigned char *data = stbi_load(path, &width, &height, &nrComponents, 0);
    if (data)
    {
        GLenum format = 0;
        if (nrComponents == 1)
        {
            format = GL_RED;
        }
        else if (nrComponents == 3)
        {
            format = GL_RGB;
        }
        else if (nrComponents == 4)
        {
            format = GL_RGBA;
        }
        
        glBindTexture(GL_TEXTURE_2D, textureID);
        
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        
        glTexImage2D(GL_TEXTURE_2D, 0, format, width, height, 0, format, GL_UNSIGNED_BYTE, data);
        glGenerateMipmap(GL_TEXTURE_2D);
        
        stbi_image_free(data);
        glBindTexture(GL_TEXTURE_2D, 0);
    }
    else
    {
        NSLog(@"Texture failed to load at path: %s", path);
    }
    
    return textureID;
}

- (GLuint)loadCubemap:(vector<std::string>)faces
{
    GLuint textureID;
    glGenTextures(1, &textureID);
    glBindTexture(GL_TEXTURE_CUBE_MAP, textureID);
    
    int width, height, nrChannels;
    for (unsigned int i = 0; i < faces.size(); i++)
    {
        unsigned char *data = stbi_load(faces[i].c_str(), &width, &height, &nrChannels, 0);
        if (data)
        {
            glTexImage2D(GL_TEXTURE_CUBE_MAP_POSITIVE_X + i, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, data);
            stbi_image_free(data);
        }
        else
        {
            NSLog(@"Cubemap texture failed to load at path: %s", faces[i].data());
            stbi_image_free(data);
        }
    }
    
    glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_R, GL_CLAMP_TO_EDGE);
    
    glGenerateMipmap(GL_TEXTURE_CUBE_MAP);
    
    return textureID;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configOpenGLView];
    
    [self configOpenGLEnvironment];
    
    [self configEventMonitor];
    
    [self configDisplayLink];
}

- (void)viewDidLayout
{
    [super viewDidLayout];
    
    [self.openGLView.openGLContext makeCurrentContext];
    
    glViewport(0, 0, self.openGLView.frame.size.width, self.openGLView.frame.size.height);
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
    
    // make sure we clear the framebuffer's content
    
    if (_shader)
    {
        glClearColor(0.1f, 0.1f, 0.1f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        
        // draw scene as normal
        
        _shader->use();
        glm::mat4 model;
        glm::mat4 view = _camera->GetViewMatrix();
        glm::mat4 projection = glm::perspective(glm::radians(_camera->Zoom),
            (float)self.view.frame.size.width / (float)self.view.frame.size.height, 0.1f, 100.0f);
        _shader->setMat4("model", model);
        _shader->setMat4("view", view);
        _shader->setMat4("projection", projection);
        
        // cubes
        glBindVertexArray(_cubeVAO);
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, _cubeTexture);
        glDrawArrays(GL_TRIANGLES, 0, 36);
        glBindVertexArray(0);
        
        // draw skybox as last
        glDepthFunc(GL_LEQUAL); // change depth function so depth test passes when values are equal to depth buffer's content
        _skyboxShader->use();
        view = glm::mat4(glm::mat3(_camera->GetViewMatrix())); // remove translation from the view matrix
        _skyboxShader->setMat4("view", view);
        _skyboxShader->setMat4("projection", projection);
        
        // skybox cube
        glBindVertexArray(_skyboxVAO);
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_CUBE_MAP, _cubemapTexture);
        glDrawArrays(GL_TRIANGLES, 0, 36);
        glBindVertexArray(0);
        glDepthFunc(GL_LESS); // set depth function back to default
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
