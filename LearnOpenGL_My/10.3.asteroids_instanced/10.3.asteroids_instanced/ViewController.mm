//
//  ViewController.m
//  10.2.asteroids
//
//  Created by tolik7071 on 12/6/17.
//  Copyright © 2017 tolik7071. All rights reserved.
//

#import "ViewController.h"
#import <OpenGL/gl3.h>
#include <learnopengl/shader.h>
#include <learnopengl/camera.h>
#include <learnopengl/model.h>
#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/type_ptr.hpp>

CVReturn DisplayCallback(CVDisplayLinkRef, const CVTimeStamp*, const CVTimeStamp*, CVOptionFlags, CVOptionFlags*, void*);

const unsigned int amount = 10000;

@implementation ViewController
{
    id                   _monitor;
    CVDisplayLinkRef     _displayLink;
    Shader              *_asteroidShader;
    Shader              *_planetShader;
    Camera              *_camera;
    GLfloat              _deltaTime;
    GLfloat              _lastFrame;
    Model               *_rock;
    Model               *_planet;
    glm::mat4           *_modelMatrices;
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
    
    delete _asteroidShader;
    _asteroidShader = NULL;
    
    delete _planetShader;
    _planetShader = NULL;
    
    delete _camera;
    _camera = NULL;
    
    delete _rock;
    _rock = NULL;
    
    delete _planet;
    _planet = NULL;
    
    delete _modelMatrices;
    _modelMatrices = NULL;
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
    
    glViewport(0, 0, self.view.frame.size.width, self.view.frame.size.height);
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
    
    {
        NSURL *shader_vs = [self findResourceWithName:@"10.3.asteroids.vs"];
        NSAssert(shader_vs, @"Cannot to find out a shader");
        
        NSURL *shader_fs = [self findResourceWithName:@"10.3.asteroids.fs"];
        NSAssert(shader_fs, @"Cannot to find out a shader");
        
        _asteroidShader = new Shader(
            [shader_vs fileSystemRepresentation],
            [shader_fs fileSystemRepresentation]);
    }
    
    {
        NSURL *shader_vs = [self findResourceWithName:@"10.3.planet.vs"];
        NSAssert(shader_vs, @"Cannot to find out a shader");
        
        NSURL *shader_fs = [self findResourceWithName:@"10.3.planet.fs"];
        NSAssert(shader_fs, @"Cannot to find out a shader");
        
        _planetShader = new Shader(
            [shader_vs fileSystemRepresentation],
            [shader_fs fileSystemRepresentation]);
    }
    
    NSURL *rock = [self findResourceWithName:@"objects/rock/rock.obj"];
    NSAssert(rock, @"Cannot to find out an object");
    
    _rock = new Model([rock fileSystemRepresentation]);
    
    NSURL *planet = [self findResourceWithName:@"objects/planet/planet.obj"];
    NSAssert(planet, @"Cannot to find out an object");
    
    _planet = new Model([planet fileSystemRepresentation]);
    
    _camera = new Camera(glm::vec3(0.0f, 5.0f, 100.0f));
    
    // generate a large list of semi-random model transformation matrices
    
    _modelMatrices = new glm::mat4[amount];
    
    // TODO: arc4random
    srand(1000);
    
    float radius = 150.0;
    float offset = 25.0;
    
    for (unsigned int i = 0; i < amount; i++)
    {
        glm::mat4 model;
        
        // 1. translation: displace along circle with 'radius' in range [-offset, offset]
        float angle = (float)i / (float)amount * 360.0f;
        float displacement = (rand() % (int)(2 * offset * 100)) / 100.0f - offset;
        float x = sin(angle) * radius + displacement;
        displacement = (rand() % (int)(2 * offset * 100)) / 100.0f - offset;
        float y = displacement * 0.4f; // keep height of asteroid field smaller compared to width of x and z
        displacement = (rand() % (int)(2 * offset * 100)) / 100.0f - offset;
        float z = cos(angle) * radius + displacement;
        model = glm::translate(model, glm::vec3(x, y, z));
        
        // 2. scale: Scale between 0.05 and 0.25f
        float scale = (rand() % 20) / 100.0f + 0.05;
        model = glm::scale(model, glm::vec3(scale));
        
        // 3. rotation: add random rotation around a (semi)randomly picked rotation axis vector
        float rotAngle = (rand() % 360);
        model = glm::rotate(model, rotAngle, glm::vec3(0.4f, 0.6f, 0.8f));
        
        // 4. now add to list of matrices
        _modelMatrices[i] = model;
    }
    
    // configure instanced array
    
    GLuint buffer;
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, amount * sizeof(glm::mat4), &(_modelMatrices[0]), GL_STATIC_DRAW);
    
    // set transformation matrices as an instance vertex attribute (with divisor 1)
    // note: we're cheating a little by taking the, now publicly declared,
    // VAO of the model's mesh(es) and adding new vertexAttribPointers
    // normally you'd want to do this in a more organized fashion,
    // but for learning purposes this will do.
    
    for (size_t i = 0; i < _rock->meshes.size(); i++)
    {
        GLuint VAO = _rock->meshes[i].VAO;
        glBindVertexArray(VAO);
        
        // set attribute pointers for matrix (4 times vec4)
        glEnableVertexAttribArray(3);
        glVertexAttribPointer(3, 4, GL_FLOAT, GL_FALSE, sizeof(glm::mat4), (void*)0);
        glEnableVertexAttribArray(4);
        glVertexAttribPointer(4, 4, GL_FLOAT, GL_FALSE, sizeof(glm::mat4), (void*)(sizeof(glm::vec4)));
        glEnableVertexAttribArray(5);
        glVertexAttribPointer(5, 4, GL_FLOAT, GL_FALSE, sizeof(glm::mat4), (void*)(2 * sizeof(glm::vec4)));
        glEnableVertexAttribArray(6);
        glVertexAttribPointer(6, 4, GL_FLOAT, GL_FALSE, sizeof(glm::mat4), (void*)(3 * sizeof(glm::vec4)));
        
        glVertexAttribDivisor(3, 1);
        glVertexAttribDivisor(4, 1);
        glVertexAttribDivisor(5, 1);
        glVertexAttribDivisor(6, 1);
        
        glBindVertexArray(0);
    }
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
    
    if (NULL != _planetShader && NULL != _asteroidShader)
    {
        // configure transformation matrices
        
        glm::mat4 projection = glm::perspective(glm::radians(_camera->Zoom),
            (float)self.view.frame.size.width / (float)self.view.frame.size.height, 0.1f, 200.0f);
        glm::mat4 view = _camera->GetViewMatrix();
        
        _asteroidShader->use();
        _asteroidShader->setMat4("projection", projection);
        _asteroidShader->setMat4("view", view);
        
        _planetShader->use();
        _planetShader->setMat4("projection", projection);
        _planetShader->setMat4("view", view);
        
        // draw planet
        
        glm::mat4 model;
        model = glm::translate(model, glm::vec3(0.0f, -3.0f, 0.0f));
        model = glm::scale(model, glm::vec3(4.0f, 4.0f, 4.0f));
        _planetShader->setMat4("model", model);
        _planet->Draw(*_planetShader);
        
        // draw meteorites
        
        _asteroidShader->use();
        _asteroidShader->setInt("texture_diffuse1", 0);
        
        glActiveTexture(GL_TEXTURE0);
        // note: we also made the textures_loaded vector public (instead of private) from the model class.
        glBindTexture(GL_TEXTURE_2D, _rock->textures_loaded[0].id);
        
        for (unsigned int i = 0; i < _rock->meshes.size(); i++)
        {
            glBindVertexArray(_rock->meshes[i].VAO);
            glDrawElementsInstanced(GL_TRIANGLES, (GLsizei)_rock->meshes[i].indices.size(), GL_UNSIGNED_INT, 0, amount);
            glBindVertexArray(0);
        }
    }
    
    [self.openGLView.openGLContext flushBuffer];
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
