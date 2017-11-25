//
//  ViewController.m
//  OpenGLTemplate
//
//  Created by tolik7071 on 10/2/17.
//  Copyright © 2017 tolik7071. All rights reserved.
//

#import "ViewController.h"
#import <OpenGL/gl3.h>
#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/type_ptr.hpp>
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
    Shader*             _lightingShader;
    Shader*             _lampShader;
    GLuint              _VBO;
    GLuint              _cubeVAO;
    GLuint              _lightVAO;
    GLuint              _diffuseMap;
    GLuint              _specularMap;
    float               _deltaTime;
    float               _lastFrame;
    Camera*             _camera;
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
        _monitor= nil;
    }
    
    delete _lightingShader;
    _lightingShader= NULL;
    
    delete _lampShader;
    _lampShader = NULL;
    
    glDeleteVertexArrays(1, &_cubeVAO);
    glDeleteVertexArrays(1, &_lightVAO);
    glDeleteBuffers(1, &_VBO);
}

- (void)configOpenGLView
{
    NSAssert(self.openGLView != nil, @"ERROR: openGLView is NULL");
    
    NSOpenGLPixelFormatAttribute pixelFormatAttributes[] =
    {
        NSOpenGLPFAOpenGLProfile, NSOpenGLProfileVersion3_2Core,
        NSOpenGLPFAColorSize    , 32                           ,
        NSOpenGLPFAAlphaSize    , 8                            ,
        NSOpenGLPFADepthSize    , 24                           ,
        NSOpenGLPFADoubleBuffer ,
        NSOpenGLPFAAccelerated  ,
        NSOpenGLPFANoRecovery   ,
        0
    };
    
    NSOpenGLPixelFormat *pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:pixelFormatAttributes];
    NSOpenGLContext* context = [[NSOpenGLContext alloc] initWithFormat:pixelFormat shareContext:nil];
    
    self.openGLView.pixelFormat = pixelFormat;
    self.openGLView.openGLContext = context;
    
#if defined(DEBUG)
    CGLEnable([context CGLContextObj], kCGLCECrashOnRemovedFunctions);
#endif
    
    self.openGLView.wantsBestResolutionOpenGLSurface = YES;
}

- (void)configDisplayLink
{
    CVReturn status = CVDisplayLinkCreateWithActiveCGDisplays(&_displayLink);
    
    if (kCVReturnSuccess == status)
    {
        CVDisplayLinkSetOutputCallback(_displayLink, DisplayCallback, (__bridge void * _Nullable)(self));
        
        CGLContextObj cglContext = [self.openGLView.openGLContext CGLContextObj];
        CGLPixelFormatObj cglPixelFormat = [self.openGLView.pixelFormat CGLPixelFormatObj];
        CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(_displayLink, cglContext, cglPixelFormat);
        
        CVDisplayLinkStart(_displayLink);
        
        [[NSNotificationCenter defaultCenter]
            addObserver:self
            selector:@selector(windowWillClose:)
            name:NSWindowWillCloseNotification
            object:[self.view window]];
    }
    else
    {
        NSLog(@"Display Link created with error: %d", status);
    }
}

- (void)windowWillClose:(NSNotification*)notification
{
    [self cleanup];
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
    
    NSURL *lamp_vs = [self findResourceWithName:@"6.lamp.vs"];
    NSAssert(lamp_vs, @"Cannot to find out a shader");
    
    NSURL *lamp_fs = [self findResourceWithName:@"6.lamp.fs"];
    NSAssert(lamp_fs, @"Cannot to find out a shader");
    
    _lampShader = new Shader([lamp_vs fileSystemRepresentation], [lamp_fs fileSystemRepresentation]);
    
    NSURL *lighting_vs = [self findResourceWithName:@"6.multiple_lights.vs"];
    NSAssert(lighting_vs, @"Cannot to find out a shader");
    
    NSURL *lighting_fs = [self findResourceWithName:@"6.multiple_lights.fs"];
    NSAssert(lighting_fs, @"Cannot to find out a shader");
    
    _lightingShader = new Shader([lighting_vs fileSystemRepresentation], [lighting_fs fileSystemRepresentation]);
    
    // vertex data
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
    
    glGenVertexArrays(1, &_lightVAO);
    glBindVertexArray(_lightVAO);
    
    glBindBuffer(GL_ARRAY_BUFFER, _VBO);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(float), (void*)0);
    glEnableVertexAttribArray(0);
    
    _diffuseMap = [self loadTexture:[[self findResourceWithName:@"textures/container2.png"] fileSystemRepresentation]];
    _specularMap = [self loadTexture:[[self findResourceWithName:@"textures/container2_specular.png"] fileSystemRepresentation]];
    
    _lightingShader->use();
    _lightingShader->setInt("material.diffuse", 0);
    _lightingShader->setInt("material.specular", 1);
    
    _camera = new Camera(glm::vec3(0.0f, 0.0f, 3.0f));
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
    GLfloat currentTime = (GLfloat)(time.videoTime) / (GLfloat)(time.videoTimeScale);
    _deltaTime = currentTime - _lastFrame;
    _lastFrame = currentTime;
    
    if ([self.view inLiveResize])
    {
        return;
    }
    
    [self.openGLView.openGLContext makeCurrentContext];
    
    glClearColor(0.1f, 0.1f, 0.1f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    _lightingShader->use();
    _lightingShader->setVec3("viewPos", _camera->Position);
    _lightingShader->setFloat("material.shininess", 32.0f);
    
    // positions of the point lights
    glm::vec3 pointLightPositions[] =
    {
        glm::vec3( 0.7f,  0.2f,  2.0f),
        glm::vec3( 2.3f, -3.3f, -4.0f),
        glm::vec3(-4.0f,  2.0f, -12.0f),
        glm::vec3( 0.0f,  0.0f, -3.0f)
    };
    
    // positions all containers
    glm::vec3 cubePositions[] =
    {
        glm::vec3( 0.0f,  0.0f,  0.0f),
        glm::vec3( 2.0f,  5.0f, -15.0f),
        glm::vec3(-1.5f, -2.2f, -2.5f),
        glm::vec3(-3.8f, -2.0f, -12.3f),
        glm::vec3( 2.4f, -0.4f, -3.5f),
        glm::vec3(-1.7f,  3.0f, -7.5f),
        glm::vec3( 1.3f, -2.0f, -2.5f),
        glm::vec3( 1.5f,  2.0f, -2.5f),
        glm::vec3( 1.5f,  0.2f, -1.5f),
        glm::vec3(-1.3f,  1.0f, -1.5f)
    };
    
    /*
     Here we set all the uniforms for the 5/6 types of lights we have. We have to set them manually and index
     the proper PointLight struct in the array to set each uniform variable. This can be done more code-friendly
     by defining light types as classes and set their values in there, or by using a more efficient uniform approach
     by using 'Uniform buffer objects', but that is something we'll discuss in the 'Advanced GLSL' tutorial.
     */
    // directional light
    _lightingShader->setVec3("dirLight.direction", -0.2f, -1.0f, -0.3f);
    _lightingShader->setVec3("dirLight.ambient", 0.05f, 0.05f, 0.05f);
    _lightingShader->setVec3("dirLight.diffuse", 0.4f, 0.4f, 0.4f);
    _lightingShader->setVec3("dirLight.specular", 0.5f, 0.5f, 0.5f);
    // point light 1
    _lightingShader->setVec3("pointLights[0].position", pointLightPositions[0]);
    _lightingShader->setVec3("pointLights[0].ambient", 0.05f, 0.05f, 0.05f);
    _lightingShader->setVec3("pointLights[0].diffuse", 0.8f, 0.8f, 0.8f);
    _lightingShader->setVec3("pointLights[0].specular", 1.0f, 1.0f, 1.0f);
    _lightingShader->setFloat("pointLights[0].constant", 1.0f);
    _lightingShader->setFloat("pointLights[0].linear", 0.09);
    _lightingShader->setFloat("pointLights[0].quadratic", 0.032);
    // point light 2
    _lightingShader->setVec3("pointLights[1].position", pointLightPositions[1]);
    _lightingShader->setVec3("pointLights[1].ambient", 0.05f, 0.05f, 0.05f);
    _lightingShader->setVec3("pointLights[1].diffuse", 0.8f, 0.8f, 0.8f);
    _lightingShader->setVec3("pointLights[1].specular", 1.0f, 1.0f, 1.0f);
    _lightingShader->setFloat("pointLights[1].constant", 1.0f);
    _lightingShader->setFloat("pointLights[1].linear", 0.09);
    _lightingShader->setFloat("pointLights[1].quadratic", 0.032);
    // point light 3
    _lightingShader->setVec3("pointLights[2].position", pointLightPositions[2]);
    _lightingShader->setVec3("pointLights[2].ambient", 0.05f, 0.05f, 0.05f);
    _lightingShader->setVec3("pointLights[2].diffuse", 0.8f, 0.8f, 0.8f);
    _lightingShader->setVec3("pointLights[2].specular", 1.0f, 1.0f, 1.0f);
    _lightingShader->setFloat("pointLights[2].constant", 1.0f);
    _lightingShader->setFloat("pointLights[2].linear", 0.09);
    _lightingShader->setFloat("pointLights[2].quadratic", 0.032);
    // point light 4
    _lightingShader->setVec3("pointLights[3].position", pointLightPositions[3]);
    _lightingShader->setVec3("pointLights[3].ambient", 0.05f, 0.05f, 0.05f);
    _lightingShader->setVec3("pointLights[3].diffuse", 0.8f, 0.8f, 0.8f);
    _lightingShader->setVec3("pointLights[3].specular", 1.0f, 1.0f, 1.0f);
    _lightingShader->setFloat("pointLights[3].constant", 1.0f);
    _lightingShader->setFloat("pointLights[3].linear", 0.09);
    _lightingShader->setFloat("pointLights[3].quadratic", 0.032);
    // spotLight
    _lightingShader->setVec3("spotLight.position", _camera->Position);
    _lightingShader->setVec3("spotLight.direction", _camera->Front);
    _lightingShader->setVec3("spotLight.ambient", 0.0f, 0.0f, 0.0f);
    _lightingShader->setVec3("spotLight.diffuse", 1.0f, 1.0f, 1.0f);
    _lightingShader->setVec3("spotLight.specular", 1.0f, 1.0f, 1.0f);
    _lightingShader->setFloat("spotLight.constant", 1.0f);
    _lightingShader->setFloat("spotLight.linear", 0.09);
    _lightingShader->setFloat("spotLight.quadratic", 0.032);
    _lightingShader->setFloat("spotLight.cutOff", glm::cos(glm::radians(12.5f)));
    _lightingShader->setFloat("spotLight.outerCutOff", glm::cos(glm::radians(15.0f)));
    
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
    
    // render containers
    glBindVertexArray(_cubeVAO);
    for (unsigned int i = 0; i < 10; i++)
    {
        // calculate the model matrix for each object and pass it to shader before drawing
        glm::mat4 model;
        model = glm::translate(model, cubePositions[i]);
        float angle = 20.0f * i;
        model = glm::rotate(model, glm::radians(angle), glm::vec3(1.0f, 0.3f, 0.5f));
        _lightingShader->setMat4("model", model);
        
        glDrawArrays(GL_TRIANGLES, 0, 36);
    }
    
    // also draw the lamp object(s)
    _lampShader->use();
    _lampShader->setMat4("projection", projection);
    _lampShader->setMat4("view", view);
    
    // we now draw as many light bulbs as we have point lights.
    glBindVertexArray(_lightVAO);
    for (unsigned int i = 0; i < 4; i++)
    {
        model = glm::mat4();
        model = glm::translate(model, pointLightPositions[i]);
        model = glm::scale(model, glm::vec3(0.2f)); // Make it a smaller cube
        _lampShader->setMat4("model", model);
        glDrawArrays(GL_TRIANGLES, 0, 36);
    }
    
    [self.openGLView.openGLContext flushBuffer];
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

- (GLuint)loadTexture:(char const *)path
{
    GLuint result;
    glGenTextures(1, &result);
    
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
        
        glBindTexture(GL_TEXTURE_2D, result);
        
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
    
    return result;
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
