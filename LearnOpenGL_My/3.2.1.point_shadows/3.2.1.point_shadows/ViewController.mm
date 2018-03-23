//
//  ViewController.m
//  3.2.1.point_shadows
//
//  Created by tolik7071 on 12/27/17.
//  Copyright © 2017 tolik7071. All rights reserved.
//

#import "ViewController.h"
#import <OpenGL/gl3.h>
#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/type_ptr.hpp>
#include <learnopengl/shader.h>
#include <learnopengl/camera.h>
#include <learnopengl/model.h>

const GLuint SHADOW_WIDTH = 1024, SHADOW_HEIGHT = 1024;

CVReturn DisplayCallback(CVDisplayLinkRef, const CVTimeStamp*, const CVTimeStamp*, CVOptionFlags, CVOptionFlags*, void*);

@implementation ViewController
{
    id                  _monitor;
    CVDisplayLinkRef    _displayLink;
    Shader             *_shader;
    Shader             *_simpleDepthShader;
    Camera             *_camera;
    glm::vec3          *_lightPos;
    GLfloat             _deltaTime;
    GLfloat             _lastFrame;
    GLuint              _woodTexture;
    GLuint              _depthMapFBO;
    GLuint              _depthCubemap;
    BOOL                _shadows;
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
    
    delete _shader;
    _shader = NULL;
    
    delete _simpleDepthShader;
    _simpleDepthShader = NULL;
    
    delete _camera;
    _camera = NULL;
    
    delete _lightPos;
    _lightPos = NULL;
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
    _monitor = [NSEvent addLocalMonitorForEventsMatchingMask:
        (NSEventMaskKeyDown | NSEventMaskScrollWheel | NSEventMaskLeftMouseDragged)
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
    
    // configure global opengl state
    
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
    
    // build and compile shaders
    
    {
        NSURL *shader_vs = [self findResourceWithName:@"3.2.1.point_shadows.vs"];
        NSAssert(shader_vs, @"Cannot to find out a shader");
        
        NSURL *shader_fs = [self findResourceWithName:@"3.2.1.point_shadows.fs"];
        NSAssert(shader_fs, @"Cannot to find out a shader");
        
        _shader = new Shader([shader_vs fileSystemRepresentation], [shader_fs fileSystemRepresentation]);
    }
    
    {
        NSURL *shader_vs = [self findResourceWithName:@"3.2.1.point_shadows_depth.vs"];
        NSAssert(shader_vs, @"Cannot to find out a shader");
        
        NSURL *shader_fs = [self findResourceWithName:@"3.2.1.point_shadows_depth.fs"];
        NSAssert(shader_fs, @"Cannot to find out a shader");
        
        NSURL *shader_gs = [self findResourceWithName:@"3.2.1.point_shadows_depth.gs"];
        NSAssert(shader_fs, @"Cannot to find out a shader");
        
        _simpleDepthShader = new Shader(
            [shader_vs fileSystemRepresentation],
            [shader_fs fileSystemRepresentation],
            [shader_gs fileSystemRepresentation]);
    }
    
    // load textures
    
    _woodTexture = [self loadTexture:[[self findResourceWithName:@"textures/wood.png"] fileSystemRepresentation]];
    
    // configure depth map FBO
    
    glGenFramebuffers(1, &_depthMapFBO);
    
    // create depth cubemap texture
    
    glGenTextures(1, &_depthCubemap);
    glBindTexture(GL_TEXTURE_CUBE_MAP, _depthCubemap);
    for (unsigned int i = 0; i < 6; ++i)
    {
        glTexImage2D(GL_TEXTURE_CUBE_MAP_POSITIVE_X + i,
                     0,
                     GL_DEPTH_COMPONENT,
                     SHADOW_WIDTH,
                     SHADOW_HEIGHT,
                     0,
                     GL_DEPTH_COMPONENT,
                     GL_FLOAT,
                     NULL);
    }
    
    glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_R, GL_CLAMP_TO_EDGE);
    
    // attach depth texture as FBO's depth buffer
    
    glBindFramebuffer(GL_FRAMEBUFFER, _depthMapFBO);
    glFramebufferTexture(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, _depthCubemap, 0);
    glDrawBuffer(GL_NONE);
    glReadBuffer(GL_NONE);
    
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    
    // shader configuration
    
    _shader->use();
    _shader->setInt("diffuseTexture", 0);
    _shader->setInt("depthMap", 1);
    
    // camera
    
    _camera = new Camera(glm::vec3(0.0f, 0.0f, 3.0f));
    
    // lighting info
    
    _lightPos = new glm::vec3(0.0f, 0.0f, 0.0f);
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
    
    if (_shader != NULL)
    {
        // 0. create depth cubemap transformation matrices
        
        float near_plane = 1.0f;
        float far_plane  = 25.0f;
        glm::mat4 shadowProj = glm::perspective(glm::radians(90.0f), (float)SHADOW_WIDTH / (float)SHADOW_HEIGHT, near_plane, far_plane);
        std::vector<glm::mat4> shadowTransforms;
        shadowTransforms.push_back(shadowProj * glm::lookAt(*_lightPos, *_lightPos + glm::vec3( 1.0f,  0.0f,  0.0f), glm::vec3(0.0f, -1.0f,  0.0f)));
        shadowTransforms.push_back(shadowProj * glm::lookAt(*_lightPos, *_lightPos + glm::vec3(-1.0f,  0.0f,  0.0f), glm::vec3(0.0f, -1.0f,  0.0f)));
        shadowTransforms.push_back(shadowProj * glm::lookAt(*_lightPos, *_lightPos + glm::vec3( 0.0f,  1.0f,  0.0f), glm::vec3(0.0f,  0.0f,  1.0f)));
        shadowTransforms.push_back(shadowProj * glm::lookAt(*_lightPos, *_lightPos + glm::vec3( 0.0f, -1.0f,  0.0f), glm::vec3(0.0f,  0.0f, -1.0f)));
        shadowTransforms.push_back(shadowProj * glm::lookAt(*_lightPos, *_lightPos + glm::vec3( 0.0f,  0.0f,  1.0f), glm::vec3(0.0f, -1.0f,  0.0f)));
        shadowTransforms.push_back(shadowProj * glm::lookAt(*_lightPos, *_lightPos + glm::vec3( 0.0f,  0.0f, -1.0f), glm::vec3(0.0f, -1.0f,  0.0f)));
        
        // 1. render scene to depth cubemap
        
        glViewport(0, 0, SHADOW_WIDTH, SHADOW_HEIGHT);
        glBindFramebuffer(GL_FRAMEBUFFER, _depthMapFBO);
        glClear(GL_DEPTH_BUFFER_BIT);
        _simpleDepthShader->use();
        for (unsigned int i = 0; i < 6; ++i)
        {
            _simpleDepthShader->setMat4("shadowMatrices[" + std::to_string(i) + "]", shadowTransforms[i]);
        }
        _simpleDepthShader->setFloat("far_plane", far_plane);
        _simpleDepthShader->setVec3("lightPos", *_lightPos);
        [self renderScene:_simpleDepthShader];
        
        glBindFramebuffer(GL_FRAMEBUFFER, 0);
        
        // 2. render scene as normal
        
        glViewport(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        _shader->use();
        glm::mat4 projection = glm::perspective(_camera->Zoom, (float)(self.view.frame.size.width / self.view.frame.size.height), 0.1f, 100.0f);
        glm::mat4 view = _camera->GetViewMatrix();
        _shader->setMat4("projection", projection);
        _shader->setMat4("view", view);
        
        // set lighting uniforms
        
        _shader->setVec3("lightPos", *_lightPos);
        _shader->setVec3("viewPos", _camera->Position);
        _shader->setInt("shadows", _shadows); // enable/disable shadows by pressing 'SPACE'
        _shader->setFloat("far_plane", far_plane);
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, _woodTexture);
        glActiveTexture(GL_TEXTURE1);
        glBindTexture(GL_TEXTURE_CUBE_MAP, _depthCubemap);
        [self renderScene:_shader];
    }
    
    [self.openGLView.openGLContext flushBuffer];
}

- (void)renderScene:(const Shader*)shader
{
    // room cube
    
    glm::mat4 model;
    model = glm::scale(model, glm::vec3(5.0f));
    _shader->setMat4("model", model);
    // note that we disable culling here since we render 'inside' the cube instead of
    // the usual 'outside' which throws off the normal culling methods.
    glDisable(GL_CULL_FACE);
    // A small little hack to invert normals when drawing cube from the inside so lighting still works.
    _shader->setInt("reverse_normals", 1);
    [self renderCube];
    _shader->setInt("reverse_normals", 0); // and of course disable it
    glEnable(GL_CULL_FACE);
    
    // cubes
    model = glm::mat4();
    model = glm::translate(model, glm::vec3(4.0f, -3.5f, 0.0));
    model = glm::scale(model, glm::vec3(0.5f));
    _shader->setMat4("model", model);
    [self renderCube];
    
    model = glm::mat4();
    model = glm::translate(model, glm::vec3(2.0f, 3.0f, 1.0));
    model = glm::scale(model, glm::vec3(0.75f));
    _shader->setMat4("model", model);
    [self renderCube];
    
    model = glm::mat4();
    model = glm::translate(model, glm::vec3(-3.0f, -1.0f, 0.0));
    model = glm::scale(model, glm::vec3(0.5f));
    _shader->setMat4("model", model);
    [self renderCube];
    
    model = glm::mat4();
    model = glm::translate(model, glm::vec3(-1.5f, 1.0f, 1.5));
    model = glm::scale(model, glm::vec3(0.5f));
    _shader->setMat4("model", model);
    [self renderCube];
    
    model = glm::mat4();
    model = glm::translate(model, glm::vec3(-1.5f, 2.0f, -3.0));
    model = glm::rotate(model, glm::radians(60.0f), glm::normalize(glm::vec3(1.0, 0.0, 1.0)));
    model = glm::scale(model, glm::vec3(0.75f));
    _shader->setMat4("model", model);
    [self renderCube];
}

- (void)renderCube
{
    static GLuint cubeVAO = 0;
    static GLuint cubeVBO = 0;
    
    if (0 == cubeVAO)
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
        glTexImage2D(GL_TEXTURE_2D, 0, format, width, height, 0, format, GL_UNSIGNED_BYTE, data);
        glGenerateMipmap(GL_TEXTURE_2D);
        
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, format == GL_RGBA ? GL_CLAMP_TO_EDGE : GL_REPEAT);
        // for this tutorial: use GL_CLAMP_TO_EDGE to prevent semi-transparent borders.
        // Due to interpolation it takes texels from next repeat
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, format == GL_RGBA ? GL_CLAMP_TO_EDGE : GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        
        stbi_image_free(data);
    }
    else
    {
        NSLog(@"Texture failed to load at path: %s", path);
    }
    
    return textureID;
}

- (BOOL)processEvent:(NSEvent *)event
{
    /*
     file://Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks/Carbon.framework/Versions/A/Frameworks/HIToolbox.framework/Versions/A/Headers/Events.h
     */
    BOOL processEvent = YES;
    
    if (event.type == NSEventTypeKeyDown)
    {
        switch(event.keyCode)
        {
            case /*kVK_Space*/0x31:
            {
                _shadows = !_shadows;
                processEvent = NO;
                break;
            }
            
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
