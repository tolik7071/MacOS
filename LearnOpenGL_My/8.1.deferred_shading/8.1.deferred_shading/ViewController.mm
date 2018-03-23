//
//  ViewController.m
//  8.1.deferred_shading
//
//  Created by tolik7071 on 2/7/18.
//  Copyright © 2018 tolik7071. All rights reserved.
//

#import "ViewController.h"
#import <OpenGL/gl3.h>
#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/type_ptr.hpp>
#include <learnopengl/shader.h>
#include <learnopengl/camera.h>
#include <learnopengl/model.h>

CVReturn DisplayCallback(CVDisplayLinkRef, const CVTimeStamp*, const CVTimeStamp*, CVOptionFlags, CVOptionFlags*, void*);

@implementation ViewController
{
    id                  _monitor;
    CVDisplayLinkRef    _displayLink;
    Camera             *_camera;
    GLfloat             _deltaTime;
    GLfloat             _lastFrame;
    Shader             *_shaderGeometryPass;
    Shader             *_shaderLightingPass;
    Shader             *_shaderLightBox;
    Model              *_nanosuit;
    std::vector<glm::vec3>  *_objectPositions;
    GLuint              _gBuffer;
    GLuint              _gPosition;
    GLuint              _gNormal;
    GLuint              _gAlbedoSpec;
    std::vector<glm::vec3>  *_lightPositions;
    std::vector<glm::vec3>  *_lightColors;
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
    
    delete _camera;
    _camera = NULL;
    
    delete _shaderGeometryPass;
    _shaderGeometryPass = NULL;
    
    delete _shaderLightingPass;
    _shaderLightingPass = NULL;
    
    delete _shaderLightBox;
    _shaderLightBox = NULL;
    
    delete _nanosuit;
    _nanosuit = NULL;
    
    delete _objectPositions;
    _objectPositions = NULL;
    
    delete _lightPositions;
    _lightPositions = NULL;
    
    delete _lightColors;
    _lightColors = NULL;
}

- (void)configOpenGLView
{
    NSAssert(self.openGLView != nil, @"ERROR: openGLView is NULL");
    
    NSOpenGLPixelFormatAttribute pixelFormatAttributes[] =
    {
        NSOpenGLPFAOpenGLProfile        , NSOpenGLProfileVersion3_2Core,
        NSOpenGLPFAColorSize            , 32                           ,
        NSOpenGLPFAAlphaSize            , 8                            ,
        NSOpenGLPFADepthSize            , 24                           ,
        NSOpenGLPFADoubleBuffer         ,
        NSOpenGLPFAAccelerated          ,
        NSOpenGLPFANoRecovery           ,
        NSOpenGLPFAAllowOfflineRenderers,
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
        (NSEventMaskKeyDown | NSEventMaskScrollWheel | NSEventMaskLeftMouseDragged)handler:^NSEvent* (NSEvent* event)
        {
            [self processEvent:event];
            return event;
        }
    ];
}

- (void)configOpenGLEnvironment
{
    NSAssert(self.openGLView != nil, @"ERROR: openGLView is NULL");
    
    [self.openGLView.openGLContext makeCurrentContext];
    
    // configure global opengl state
    
    glEnable(GL_DEPTH_TEST);
    
    // build and compile shaders
    
    {
        NSURL *shader_vs = [self findResourceWithName:@"8.1.g_buffer.vs"];
        NSAssert(shader_vs, @"Cannot to find out a shader");
        
        NSURL *shader_fs = [self findResourceWithName:@"8.1.g_buffer.fs"];
        NSAssert(shader_fs, @"Cannot to find out a shader");
        
        _shaderGeometryPass = new Shader([shader_vs fileSystemRepresentation], [shader_fs fileSystemRepresentation]);
    }
    
    {
        NSURL *shader_vs = [self findResourceWithName:@"8.1.deferred_shading.vs"];
        NSAssert(shader_vs, @"Cannot to find out a shader");
        
        NSURL *shader_fs = [self findResourceWithName:@"8.1.deferred_shading.fs"];
        NSAssert(shader_fs, @"Cannot to find out a shader");
        
        _shaderLightingPass = new Shader([shader_vs fileSystemRepresentation], [shader_fs fileSystemRepresentation]);
    }
    
    {
        NSURL *shader_vs = [self findResourceWithName:@"8.1.deferred_shading.vs"];
        NSAssert(shader_vs, @"Cannot to find out a shader");
        
        NSURL *shader_fs = [self findResourceWithName:@"8.1.deferred_shading.fs"];
        NSAssert(shader_fs, @"Cannot to find out a shader");
        
        _shaderLightBox = new Shader([shader_vs fileSystemRepresentation], [shader_fs fileSystemRepresentation]);
    }
    
    // load models
    
    _nanosuit = new Model([[self findResourceWithName:@"objects/nanosuit/nanosuit.obj"] fileSystemRepresentation]);
    
    _objectPositions = new std::vector<glm::vec3>();
    
    _objectPositions->push_back(glm::vec3(-3.0, -3.0, -3.0));
    _objectPositions->push_back(glm::vec3( 0.0, -3.0, -3.0));
    _objectPositions->push_back(glm::vec3( 3.0, -3.0, -3.0));
    _objectPositions->push_back(glm::vec3(-3.0, -3.0,  0.0));
    _objectPositions->push_back(glm::vec3( 0.0, -3.0,  0.0));
    _objectPositions->push_back(glm::vec3( 3.0, -3.0,  0.0));
    _objectPositions->push_back(glm::vec3(-3.0, -3.0,  3.0));
    _objectPositions->push_back(glm::vec3( 0.0, -3.0,  3.0));
    _objectPositions->push_back(glm::vec3( 3.0, -3.0,  3.0));
    
    // configure g-buffer framebuffer
    
    glGenFramebuffers(1, &_gBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _gBuffer);
    
    // position color buffer
    
    glGenTextures(1, &_gPosition);
    glBindTexture(GL_TEXTURE_2D, _gPosition);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB16F, self.openGLView.frame.size.width , self.openGLView.frame.size.height, 0, GL_RGB, GL_FLOAT, NULL);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _gPosition, 0);
    
    // normal color buffer
    
    glGenTextures(1, &_gNormal);
    glBindTexture(GL_TEXTURE_2D, _gNormal);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB16F, self.openGLView.frame.size.width , self.openGLView.frame.size.height, 0, GL_RGB, GL_FLOAT, NULL);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT1, GL_TEXTURE_2D, _gNormal, 0);
    
    // color + specular color buffer
    
    glGenTextures(1, &_gAlbedoSpec);
    glBindTexture(GL_TEXTURE_2D, _gAlbedoSpec);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, self.openGLView.frame.size.width , self.openGLView.frame.size.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT2, GL_TEXTURE_2D, _gAlbedoSpec, 0);
    
    // tell OpenGL which color attachments we'll use (of this framebuffer) for rendering
    
    GLuint attachments[3] = { GL_COLOR_ATTACHMENT0, GL_COLOR_ATTACHMENT1, GL_COLOR_ATTACHMENT2 };
    glDrawBuffers(3, attachments);
    
    // create and attach depth buffer (renderbuffer)
    
    GLuint rboDepth;
    glGenRenderbuffers(1, &rboDepth);
    glBindRenderbuffer(GL_RENDERBUFFER, rboDepth);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT, self.openGLView.frame.size.width , self.openGLView.frame.size.height);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, rboDepth);
    
    // finally check if framebuffer is complete
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
    {
        NSLog(@"Framebuffer not complete!");
    }
    
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    
    // lighting info
    
    const unsigned int NR_LIGHTS = 32;
    
    _lightPositions = new std::vector<glm::vec3>();
    _lightColors = new std::vector<glm::vec3>();
    
    srand(13);
    
    for (unsigned int i = 0; i < NR_LIGHTS; i++)
    {
        // calculate slightly random offsets
        float xPos = ((rand() % 100) / 100.0) * 6.0 - 3.0;
        float yPos = ((rand() % 100) / 100.0) * 6.0 - 4.0;
        float zPos = ((rand() % 100) / 100.0) * 6.0 - 3.0;
        _lightPositions->push_back(glm::vec3(xPos, yPos, zPos));
        
        // also calculate random color
        float rColor = ((rand() % 100) / 200.0f) + 0.5; // between 0.5 and 1.0
        float gColor = ((rand() % 100) / 200.0f) + 0.5; // between 0.5 and 1.0
        float bColor = ((rand() % 100) / 200.0f) + 0.5; // between 0.5 and 1.0
        _lightColors->push_back(glm::vec3(rColor, gColor, bColor));
    }
    
    // shader configuration
    // --------------------
    _shaderLightingPass->use();
    _shaderLightingPass->setInt("gPosition", 0);
    _shaderLightingPass->setInt("gNormal", 1);
    _shaderLightingPass->setInt("gAlbedoSpec", 2);
    
    // camera
    
    _camera = new Camera(glm::vec3(0.0f, 0.0f, 5.0f));
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
    
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    if (NULL != _shaderGeometryPass)
    {
        // > 1. geometry pass: render scene's geometry/color data into gbuffer
        
        glBindFramebuffer(GL_FRAMEBUFFER, _gBuffer);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        
        glm::mat4 projection = glm::perspective(glm::radians(_camera->Zoom), (float)(self.openGLView.frame.size.width / self.openGLView.frame.size.height), 0.1f, 100.0f);
        glm::mat4 view = _camera->GetViewMatrix();
        glm::mat4 model;
        
        _shaderGeometryPass->use();
        _shaderGeometryPass->setMat4("projection", projection);
        _shaderGeometryPass->setMat4("view", view);
        
        for (GLuint i = 0; i < _objectPositions->size(); i++)
        {
            model = glm::mat4();
            model = glm::translate(model, _objectPositions->at(i));
            model = glm::scale(model, glm::vec3(0.25f));
            _shaderGeometryPass->setMat4("model", model);
            _nanosuit->Draw(*_shaderGeometryPass);
        }
        
        glBindFramebuffer(GL_FRAMEBUFFER, 0);
        
        // < 1.
        
        // > 2. lighting pass: calculate lighting by iterating over a screen filled quad pixel-by-pixel using the gbuffer's content.
        
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        _shaderLightingPass->use();
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, _gPosition);
        glActiveTexture(GL_TEXTURE1);
        glBindTexture(GL_TEXTURE_2D, _gNormal);
        glActiveTexture(GL_TEXTURE2);
        glBindTexture(GL_TEXTURE_2D, _gAlbedoSpec);
        
        // send light relevant uniforms
        
        for (GLuint i = 0; i < _lightPositions->size(); i++)
        {
            _shaderLightingPass->setVec3("lights[" + std::to_string(i) + "].Position", _lightPositions->at(i));
            _shaderLightingPass->setVec3("lights[" + std::to_string(i) + "].Color", _lightColors->at(i));
            // update attenuation parameters and calculate radius
            // note that we don't send this to the shader, we assume it is always 1.0 (in our case)
            const float constant = 1.0;
            const float linear = 0.7;
            const float quadratic = 1.8;
            _shaderLightingPass->setFloat("lights[" + std::to_string(i) + "].Linear", linear);
            _shaderLightingPass->setFloat("lights[" + std::to_string(i) + "].Quadratic", quadratic);
        }
        
        _shaderLightingPass->setVec3("viewPos", _camera->Position);
        
        // finally render quad
        
        [self renderQuad];
        
        // < 2.
        
        // > 2.5. copy content of geometry's depth buffer to default framebuffer's depth buffer
        
        glBindFramebuffer(GL_READ_FRAMEBUFFER, _gBuffer);
        // write to default framebuffer
        glBindFramebuffer(GL_DRAW_FRAMEBUFFER, 0);
        
        // blit to default framebuffer. Note that this may or may not work as the internal formats
        // of both the FBO and default framebuffer have to match.
        // The internal formats are implementation defined. This works on all of my systems,
        // but if it doesn't on yours you'll likely have to write to the
        // depth buffer in another shader stage (or somehow see to match the default
        // framebuffer's internal format with the FBO's internal format).
        
        glBlitFramebuffer(0, 0, self.openGLView.frame.size.width, self.openGLView.frame.size.height,
            0, 0, self.openGLView.frame.size.width , self.openGLView.frame.size.height, GL_DEPTH_BUFFER_BIT, GL_NEAREST);
        glBindFramebuffer(GL_FRAMEBUFFER, 0);
        
        // < 2.5.
        
        // > 3. render lights on top of scene
        
        _shaderLightBox->use();
        _shaderLightBox->setMat4("projection", projection);
        _shaderLightBox->setMat4("view", view);
        for (GLuint i = 0; i < _lightPositions->size(); i++)
        {
            model = glm::mat4();
            model = glm::translate(model, _lightPositions->at(i));
            model = glm::scale(model, glm::vec3(0.125f));
            
            _shaderLightBox->setMat4("model", model);
            _shaderLightBox->setVec3("lightColor", _lightColors->at(i));
            [self renderCube];
        }
        
        // < 3.
    }
    
    [self.openGLView.openGLContext flushBuffer];
}

- (void)renderCube
{
    static GLuint cubeVAO = 0;
    static GLuint cubeVBO = 0;
    
    // initialize (if necessary)
    if (cubeVAO == 0)
    {
        float vertices[] =
        {
            // back face
            -1.0f, -1.0f, -1.0f,  0.0f,  0.0f, -1.0f, 0.0f, 0.0f, // bottom-left
             1.0f,  1.0f, -1.0f,  0.0f,  0.0f, -1.0f, 1.0f, 1.0f, // top-right
             1.0f, -1.0f, -1.0f,  0.0f,  0.0f, -1.0f, 1.0f, 0.0f, // bottom-right
             1.0f,  1.0f, -1.0f,  0.0f,  0.0f, -1.0f, 1.0f, 1.0f, // top-right
            -1.0f, -1.0f, -1.0f,  0.0f,  0.0f, -1.0f, 0.0f, 0.0f, // bottom-left
            -1.0f,  1.0f, -1.0f,  0.0f,  0.0f, -1.0f, 0.0f, 1.0f, // top-left
            
            // front face
            -1.0f, -1.0f,  1.0f,  0.0f,  0.0f,  1.0f, 0.0f, 0.0f, // bottom-left
             1.0f, -1.0f,  1.0f,  0.0f,  0.0f,  1.0f, 1.0f, 0.0f, // bottom-right
             1.0f,  1.0f,  1.0f,  0.0f,  0.0f,  1.0f, 1.0f, 1.0f, // top-right
             1.0f,  1.0f,  1.0f,  0.0f,  0.0f,  1.0f, 1.0f, 1.0f, // top-right
            -1.0f,  1.0f,  1.0f,  0.0f,  0.0f,  1.0f, 0.0f, 1.0f, // top-left
            -1.0f, -1.0f,  1.0f,  0.0f,  0.0f,  1.0f, 0.0f, 0.0f, // bottom-left
            
            // left face
            -1.0f,  1.0f,  1.0f, -1.0f,  0.0f,  0.0f, 1.0f, 0.0f, // top-right
            -1.0f,  1.0f, -1.0f, -1.0f,  0.0f,  0.0f, 1.0f, 1.0f, // top-left
            -1.0f, -1.0f, -1.0f, -1.0f,  0.0f,  0.0f, 0.0f, 1.0f, // bottom-left
            -1.0f, -1.0f, -1.0f, -1.0f,  0.0f,  0.0f, 0.0f, 1.0f, // bottom-left
            -1.0f, -1.0f,  1.0f, -1.0f,  0.0f,  0.0f, 0.0f, 0.0f, // bottom-right
            -1.0f,  1.0f,  1.0f, -1.0f,  0.0f,  0.0f, 1.0f, 0.0f, // top-right
            
            // right face
             1.0f,  1.0f,  1.0f,  1.0f,  0.0f,  0.0f, 1.0f, 0.0f, // top-left
             1.0f, -1.0f, -1.0f,  1.0f,  0.0f,  0.0f, 0.0f, 1.0f, // bottom-right
             1.0f,  1.0f, -1.0f,  1.0f,  0.0f,  0.0f, 1.0f, 1.0f, // top-right
             1.0f, -1.0f, -1.0f,  1.0f,  0.0f,  0.0f, 0.0f, 1.0f, // bottom-right
             1.0f,  1.0f,  1.0f,  1.0f,  0.0f,  0.0f, 1.0f, 0.0f, // top-left
             1.0f, -1.0f,  1.0f,  1.0f,  0.0f,  0.0f, 0.0f, 0.0f, // bottom-left
            
            // bottom face
            -1.0f, -1.0f, -1.0f,  0.0f, -1.0f,  0.0f, 0.0f, 1.0f, // top-right
             1.0f, -1.0f, -1.0f,  0.0f, -1.0f,  0.0f, 1.0f, 1.0f, // top-left
             1.0f, -1.0f,  1.0f,  0.0f, -1.0f,  0.0f, 1.0f, 0.0f, // bottom-left
             1.0f, -1.0f,  1.0f,  0.0f, -1.0f,  0.0f, 1.0f, 0.0f, // bottom-left
            -1.0f, -1.0f,  1.0f,  0.0f, -1.0f,  0.0f, 0.0f, 0.0f, // bottom-right
            -1.0f, -1.0f, -1.0f,  0.0f, -1.0f,  0.0f, 0.0f, 1.0f, // top-right
            
            // top face
            -1.0f,  1.0f, -1.0f,  0.0f,  1.0f,  0.0f, 0.0f, 1.0f, // top-left
             1.0f,  1.0f , 1.0f,  0.0f,  1.0f,  0.0f, 1.0f, 0.0f, // bottom-right
             1.0f,  1.0f, -1.0f,  0.0f,  1.0f,  0.0f, 1.0f, 1.0f, // top-right
             1.0f,  1.0f,  1.0f,  0.0f,  1.0f,  0.0f, 1.0f, 0.0f, // bottom-right
            -1.0f,  1.0f, -1.0f,  0.0f,  1.0f,  0.0f, 0.0f, 1.0f, // top-left
            -1.0f,  1.0f,  1.0f,  0.0f,  1.0f,  0.0f, 0.0f, 0.0f  // bottom-left
        };
        
        glGenVertexArrays(1, &cubeVAO);
        glGenBuffers(1, &cubeVBO);
        
        // fill buffer
        
        glBindBuffer(GL_ARRAY_BUFFER, cubeVBO);
        glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
        
        // link vertex attributes
        
        glBindVertexArray(cubeVAO);
        glEnableVertexAttribArray(0);
        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(float), (void*)0);
        
        glEnableVertexAttribArray(1);
        glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(float), (void*)(3 * sizeof(float)));
        
        glEnableVertexAttribArray(2);
        glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, 8 * sizeof(float), (void*)(6 * sizeof(float)));
        
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        
        glBindVertexArray(0);
    }
    
    // render Cube
    
    glBindVertexArray(cubeVAO);
    glDrawArrays(GL_TRIANGLES, 0, 36);
    glBindVertexArray(0);
}

- (void)renderQuad
{
    static GLuint quadVAO = 0;
    static GLuint quadVBO = 0;
    
    if (quadVAO == 0)
    {
        float quadVertices[] =
        {
            // positions        // texture Coords
            -1.0f,  1.0f, 0.0f, 0.0f, 1.0f,
            -1.0f, -1.0f, 0.0f, 0.0f, 0.0f,
             1.0f,  1.0f, 0.0f, 1.0f, 1.0f,
             1.0f, -1.0f, 0.0f, 1.0f, 0.0f,
        };
        
        // setup plane VAO
        
        glGenVertexArrays(1, &quadVAO);
        glGenBuffers(1, &quadVBO);
        glBindVertexArray(quadVAO);
        glBindBuffer(GL_ARRAY_BUFFER, quadVBO);
        glBufferData(GL_ARRAY_BUFFER, sizeof(quadVertices), &quadVertices, GL_STATIC_DRAW);
        
        glEnableVertexAttribArray(0);
        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void*)0);
        
        glEnableVertexAttribArray(1);
        glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void*)(3 * sizeof(float)));
        
        glBindVertexArray(0);
    }
    
    glBindVertexArray(quadVAO);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glBindVertexArray(0);
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

- (NSURL *)findResourceWithName:(NSString *)aName
{
    NSURL *result = [[NSBundle mainBundle]
        URLForResource:[aName stringByDeletingPathExtension]
        withExtension:[aName pathExtension]];
    
    return result;
}

- (BOOL)processEvent:(NSEvent *)event
{
    /*
     file://Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks/Carbon.framework/Versions/A/Frameworks/HIToolbox.framework/Versions/A/Headers/Events.h
     */
    BOOL processEvent = YES;
    
    if (event.type == NSEventTypeKeyDown && 0 == (event.modifierFlags & NSEventModifierFlagCommand))
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
