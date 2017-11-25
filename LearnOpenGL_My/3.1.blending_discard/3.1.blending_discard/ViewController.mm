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
//#include <learnopengl/model.h>
#include <vector>

CVReturn DisplayCallback(CVDisplayLinkRef, const CVTimeStamp*, const CVTimeStamp*, CVOptionFlags, CVOptionFlags*, void*);

@implementation ViewController
{
    id                  _monitor;
    CVDisplayLinkRef    _displayLink;
    GLuint              _cubeVAO, _cubeVBO;
    GLuint              _planeVAO, _planeVBO;
    GLuint              _transparentVAO, _transparentVBO;
    Camera*             _camera;
    Shader*             _shader;
    float               _deltaTime, _lastFrame;
    //GLuint              _diffuseMap;
    GLuint              _cubeTexture;
    GLuint              _floorTexture;
    GLuint              _transparentTexture;
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
    glDeleteBuffers(1, &_cubeVBO);
    
    glDeleteVertexArrays(1, &_planeVAO);
    glDeleteBuffers(1, &_planeVBO);
    
    glDeleteVertexArrays(1, &_transparentVAO);
    glDeleteBuffers(1, &_transparentVBO);
    
    delete _shader;
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
    (NSEventMaskKeyDown | NSEventMaskScrollWheel | NSEventMaskLeftMouseDragged)handler:^NSEvent* (NSEvent* event)
    {
        [self processEvent:event];
        return event;
    }];
}

- (void)configOpenGLEnvironment
{
    NSAssert(self.openGLView != nil, @"ERROR: openGLView is NULL");
    
    [self.openGLView.openGLContext makeCurrentContext];
    
    glEnable(GL_DEPTH_TEST);
    
    NSURL *shader_vs = [self findResourceWithName:@"3.1.blending.vs"];
    NSAssert(shader_vs, @"Cannot to find out a shader");
    
    NSURL *shader_fs = [self findResourceWithName:@"3.1.blending.fs"];
    NSAssert(shader_fs, @"Cannot to find out a shader");
    
    _shader = new Shader([shader_vs fileSystemRepresentation], [shader_fs fileSystemRepresentation]);
    
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
    
    float planeVertices[] =
    {
        // positions          // texture Coords
         5.0f, -0.5f,  5.0f,  2.0f, 0.0f,
        -5.0f, -0.5f,  5.0f,  0.0f, 0.0f,
        -5.0f, -0.5f, -5.0f,  0.0f, 2.0f,
        
         5.0f, -0.5f,  5.0f,  2.0f, 0.0f,
        -5.0f, -0.5f, -5.0f,  0.0f, 2.0f,
         5.0f, -0.5f, -5.0f,  2.0f, 2.0f
    };
    
    float transparentVertices[] =
    {
        // positions         // texture Coords (swapped y coordinates because texture is flipped upside down)
        0.0f,  0.5f,  0.0f,  0.0f,  0.0f,
        0.0f, -0.5f,  0.0f,  0.0f,  1.0f,
        1.0f, -0.5f,  0.0f,  1.0f,  1.0f,
        
        0.0f,  0.5f,  0.0f,  0.0f,  0.0f,
        1.0f, -0.5f,  0.0f,  1.0f,  1.0f,
        1.0f,  0.5f,  0.0f,  1.0f,  0.0f
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
    
    // plane VAO
    
    glGenVertexArrays(1, &_planeVAO);
    glGenBuffers(1, &_planeVBO);
    glBindVertexArray(_planeVAO);
    glBindBuffer(GL_ARRAY_BUFFER, _planeVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(planeVertices), &planeVertices, GL_STATIC_DRAW);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void*)0);
    glEnableVertexAttribArray(1);
    glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void*)(3 * sizeof(float)));
    
    // transparent VAO
    
    glGenVertexArrays(1, &_transparentVAO);
    glGenBuffers(1, &_transparentVBO);
    glBindVertexArray(_transparentVAO);
    glBindBuffer(GL_ARRAY_BUFFER, _transparentVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(transparentVertices), transparentVertices, GL_STATIC_DRAW);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void*)0);
    glEnableVertexAttribArray(1);
    glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void*)(3 * sizeof(float)));
    glBindVertexArray(0);
    
    _cubeTexture = [self loadTexture:[[self findResourceWithName:@"textures/marble.jpg"] fileSystemRepresentation]];
    _floorTexture = [self loadTexture:[[self findResourceWithName:@"textures/metal.png"] fileSystemRepresentation]];
    _transparentTexture = [self loadTexture:[[self findResourceWithName:@"textures/grass.png"] fileSystemRepresentation]];
    
    // shader configuration
    _shader->use();
    _shader->setInt("texture1", 0);
    
    _camera = new Camera(glm::vec3(0.0f, 0.0f, 3.0f));
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
    else if (event.type == NSEventTypeLeftMouseDragged)
    {
        NSPoint point = [self.openGLView convertPoint:[event locationInWindow] fromView:nil];
        
        if ([self.openGLView hitTest:point])
        {
            _camera->ProcessMouseMovement(event.deltaX, event.deltaY);
        }
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
    
    // transparent vegetation locations
    std::vector<glm::vec3> vegetation
    {
        glm::vec3(-1.5f, 0.0f, -0.48f),
        glm::vec3( 1.5f, 0.0f,  0.51f),
        glm::vec3( 0.0f, 0.0f,  0.70f),
        glm::vec3(-0.3f, 0.0f, -2.30f),
        glm::vec3( 0.5f, 0.0f, -0.60f)
    };
    
    if (_shader)
    {
        // draw objects
        
        _shader->use();
        glm::mat4 projection = glm::perspective(glm::radians(_camera->Zoom),
            (float)self.view.frame.size.width / (float)self.view.frame.size.height, 0.1f, 100.0f);
        glm::mat4 view = _camera->GetViewMatrix();
        glm::mat4 model;
        _shader->setMat4("projection", projection);
        _shader->setMat4("view", view);
        
        // cubes
        
        glBindVertexArray(_cubeVAO);
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, _cubeTexture);
        model = glm::translate(model, glm::vec3(-1.0f, 0.0f, -1.0f));
        _shader->setMat4("model", model);
        glDrawArrays(GL_TRIANGLES, 0, 36);
        model = glm::mat4();
        model = glm::translate(model, glm::vec3(2.0f, 0.0f, 0.0f));
        _shader->setMat4("model", model);
        glDrawArrays(GL_TRIANGLES, 0, 36);
        
        // floor
        
        glBindVertexArray(_planeVAO);
        glBindTexture(GL_TEXTURE_2D, _floorTexture);
        model = glm::mat4();
        _shader->setMat4("model", model);
        glDrawArrays(GL_TRIANGLES, 0, 6);
        
        // vegetation
        
        glBindVertexArray(_transparentVAO);
        glBindTexture(GL_TEXTURE_2D, _transparentTexture);
        for (GLuint i = 0; i < vegetation.size(); i++)
        {
            model = glm::mat4();
            model = glm::translate(model, vegetation[i]);
            _shader->setMat4("model", model);
            glDrawArrays(GL_TRIANGLES, 0, 6);
        }
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
