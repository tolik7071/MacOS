//
//  ViewController.m
//  4.2.lighting_maps_specular_map
//
//  Created by tolik7071 on 9/25/17.
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
    unsigned int        _diffuseMap, _specularMap;
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
    
    glEnable(GL_DEPTH_TEST);
    
    NSURL *lamp_vs = [self findResourceWithName:@"4.2.lamp.vs"];
    NSAssert(lamp_vs, @"Cannot to find out a shader");
    
    NSURL *lamp_fs = [self findResourceWithName:@"4.2.lamp.fs"];
    NSAssert(lamp_fs, @"Cannot to find out a shader");
    
    _lampShader = new Shader([lamp_vs fileSystemRepresentation], [lamp_fs fileSystemRepresentation]);
    
    NSURL *lighting_vs = [self findResourceWithName:@"4.2.lighting_maps.vs"];
    NSAssert(lighting_vs, @"Cannot to find out a shader");
    
    NSURL *lighting_fs = [self findResourceWithName:@"4.2.lighting_maps.fs"];
    NSAssert(lighting_fs, @"Cannot to find out a shader");
    
    _lightingShader = new Shader([lighting_vs fileSystemRepresentation], [lighting_fs fileSystemRepresentation]);
    
    // set up vertex data (and buffer(s)) and configure vertex attributes
    // ------------------------------------------------------------------
    float vertices[] =
    {
        // positions          // normals           // texture coords
        -0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f,  0.0f,  0.0f,
         0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f,  1.0f,  0.0f,
         0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f,  1.0f,  1.0f,
         0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f,  1.0f,  1.0f,
        -0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f,  0.0f,  1.0f,
        -0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f,  0.0f,  0.0f,
        
        -0.5f, -0.5f,  0.5f,  0.0f,  0.0f,  1.0f,  0.0f,  0.0f,
         0.5f, -0.5f,  0.5f,  0.0f,  0.0f,  1.0f,  1.0f,  0.0f,
         0.5f,  0.5f,  0.5f,  0.0f,  0.0f,  1.0f,  1.0f,  1.0f,
         0.5f,  0.5f,  0.5f,  0.0f,  0.0f,  1.0f,  1.0f,  1.0f,
        -0.5f,  0.5f,  0.5f,  0.0f,  0.0f,  1.0f,  0.0f,  1.0f,
        -0.5f, -0.5f,  0.5f,  0.0f,  0.0f,  1.0f,  0.0f,  0.0f,
        
        -0.5f,  0.5f,  0.5f, -1.0f,  0.0f,  0.0f,  1.0f,  0.0f,
        -0.5f,  0.5f, -0.5f, -1.0f,  0.0f,  0.0f,  1.0f,  1.0f,
        -0.5f, -0.5f, -0.5f, -1.0f,  0.0f,  0.0f,  0.0f,  1.0f,
        -0.5f, -0.5f, -0.5f, -1.0f,  0.0f,  0.0f,  0.0f,  1.0f,
        -0.5f, -0.5f,  0.5f, -1.0f,  0.0f,  0.0f,  0.0f,  0.0f,
        -0.5f,  0.5f,  0.5f, -1.0f,  0.0f,  0.0f,  1.0f,  0.0f,
        
         0.5f,  0.5f,  0.5f,  1.0f,  0.0f,  0.0f,  1.0f,  0.0f,
         0.5f,  0.5f, -0.5f,  1.0f,  0.0f,  0.0f,  1.0f,  1.0f,
         0.5f, -0.5f, -0.5f,  1.0f,  0.0f,  0.0f,  0.0f,  1.0f,
         0.5f, -0.5f, -0.5f,  1.0f,  0.0f,  0.0f,  0.0f,  1.0f,
         0.5f, -0.5f,  0.5f,  1.0f,  0.0f,  0.0f,  0.0f,  0.0f,
         0.5f,  0.5f,  0.5f,  1.0f,  0.0f,  0.0f,  1.0f,  0.0f,
        
        -0.5f, -0.5f, -0.5f,  0.0f, -1.0f,  0.0f,  0.0f,  1.0f,
         0.5f, -0.5f, -0.5f,  0.0f, -1.0f,  0.0f,  1.0f,  1.0f,
         0.5f, -0.5f,  0.5f,  0.0f, -1.0f,  0.0f,  1.0f,  0.0f,
         0.5f, -0.5f,  0.5f,  0.0f, -1.0f,  0.0f,  1.0f,  0.0f,
        -0.5f, -0.5f,  0.5f,  0.0f, -1.0f,  0.0f,  0.0f,  0.0f,
        -0.5f, -0.5f, -0.5f,  0.0f, -1.0f,  0.0f,  0.0f,  1.0f,
        
        -0.5f,  0.5f, -0.5f,  0.0f,  1.0f,  0.0f,  0.0f,  1.0f,
         0.5f,  0.5f, -0.5f,  0.0f,  1.0f,  0.0f,  1.0f,  1.0f,
         0.5f,  0.5f,  0.5f,  0.0f,  1.0f,  0.0f,  1.0f,  0.0f,
         0.5f,  0.5f,  0.5f,  0.0f,  1.0f,  0.0f,  1.0f,  0.0f,
        -0.5f,  0.5f,  0.5f,  0.0f,  1.0f,  0.0f,  0.0f,  0.0f,
        -0.5f,  0.5f, -0.5f,  0.0f,  1.0f,  0.0f,  0.0f,  1.0f
    };
    
    // first, configure the cube's VAO (and VBO)
    
    glGenBuffers(1, &_VBO);
    glBindBuffer(GL_ARRAY_BUFFER, _VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    glGenVertexArrays(1, &_cubeVAO);
    glBindVertexArray(_cubeVAO);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(float), (void*)0);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(float), (void*)(3 * sizeof(float)));
    glEnableVertexAttribArray(1);
    glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, 8 * sizeof(float), (void*)(6 * sizeof(float)));
    glEnableVertexAttribArray(2);
    
    // second, configure the light's VAO (VBO stays the same;
    // the vertices are the same for the light object which is also a 3D cube)
    
    glGenVertexArrays(1, &_lightVAO);
    glBindVertexArray(_lightVAO);
    
    glBindBuffer(GL_ARRAY_BUFFER, _VBO);
    // note that we update the lamp's position attribute's stride to reflect the updated buffer data
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(float), (void*)0);
    glEnableVertexAttribArray(0);
    
    _diffuseMap = [self loadTexture:[[self findResourceWithName:@"textures/container2.png"] fileSystemRepresentation]];
    //_specularMap = [self loadTexture:[[self findResourceWithName:@"textures/container2_specular.png"] fileSystemRepresentation]];
    _specularMap = [self loadTexture:[[self findResourceWithName:@"textures/awesomeface.png"] fileSystemRepresentation]];
    
    // shader configuration
    // --------------------
    _lightingShader->use();
    _lightingShader->setInt("material.diffuse", 0);
    _lightingShader->setInt("material.specular", 1);
    
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
    
    return YES;
}

- (NSURL *)findResourceWithName:(NSString *)aName
{
    NSURL *result = [[NSBundle mainBundle]
                     URLForResource:[aName stringByDeletingPathExtension]
                     withExtension:[aName pathExtension]];
    
    return result;
}

- (unsigned int)loadTexture:(char const *)path
{
    unsigned int textureID;
    glGenTextures(1, &textureID);
    
    int width, height, nrComponents;
    unsigned char *data = stbi_load(path, &width, &height, &nrComponents, 0);
    if (data)
    {
        GLenum format = 0;
        if (nrComponents == 1)
            format = GL_RED;
        else if (nrComponents == 3)
            format = GL_RGB;
        else if (nrComponents == 4)
            format = GL_RGBA;
        
        glBindTexture(GL_TEXTURE_2D, textureID);
        
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        
        glTexImage2D(GL_TEXTURE_2D, 0, format, width, height, 0, format, GL_UNSIGNED_BYTE, data);
        glGenerateMipmap(GL_TEXTURE_2D);
        
        stbi_image_free(data);
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
    
    if (_lightingShader && _lampShader)
    {
        // be sure to activate shader when setting uniforms/drawing objects
        _lightingShader->use();
        _lightingShader->setVec3("light.position", [self lightPos]);
        _lightingShader->setVec3("viewPos", _camera->Position);
        
        // light properties
        _lightingShader->setVec3("light.ambient", 0.2f, 0.2f, 0.2f);
        _lightingShader->setVec3("light.diffuse", 0.5f, 0.5f, 0.5f);
        _lightingShader->setVec3("light.specular", 1.0f, 1.0f, 1.0f);
        
        // material properties
        _lightingShader->setFloat("material.shininess", 64.0f);
        
        // view/projection transformations
        glm::mat4 projection = glm::perspective(glm::radians(_camera->Zoom),
            (float)self.view.frame.size.width / (float)self.view.frame.size.height, 0.1f, 100.0f);
        glm::mat4 view = _camera->GetViewMatrix();
        _lightingShader->setMat4("projection", projection);
        _lightingShader->setMat4("view", view);
        
        // world transformation
        glm::mat4 model;
        _lightingShader->setMat4("model", model);
        
        // bind diffuse map
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, _diffuseMap);
        // bind specular map
        glActiveTexture(GL_TEXTURE1);
        glBindTexture(GL_TEXTURE_2D, _specularMap);
        
        // render the cube
        glBindVertexArray(_cubeVAO);
        glDrawArrays(GL_TRIANGLES, 0, 36);
        
        // also draw the lamp object
        _lampShader->use();
        _lampShader->setMat4("projection", projection);
        _lampShader->setMat4("view", view);
        model = glm::mat4();
        model = glm::translate(model, [self lightPos]);
        model = glm::scale(model, glm::vec3(0.2f)); // a smaller cube
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
