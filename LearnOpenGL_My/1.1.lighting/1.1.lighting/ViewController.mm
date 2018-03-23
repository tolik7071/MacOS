//
//  ViewController.m
//  1.1.lighting
//
//  Created by tolik7071 on 3/15/18.
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
    GLfloat             _deltaTime;
    GLfloat             _lastFrame;
    Camera             *_camera;
    glm::vec3          *_lightPositions;
    glm::vec3          *_lightColors;
    Shader             *_shader;
    int                 _nrRows;
    int                 _nrColumns;
    float               _spacing;
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
    
    delete _lightPositions;
    _lightPositions = NULL;
    
    delete _lightColors;
    _lightColors = NULL;
    
    delete _camera;
    _camera = NULL;
    
    delete _shader;
    _shader = NULL;
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
    
    NSURL *shader_vs = [self findResourceWithName:@"1.1.pbr.vs"];
    NSAssert(shader_vs, @"Cannot to find out a shader");
    
    NSURL *shader_fs = [self findResourceWithName:@"1.1.pbr.fs"];
    NSAssert(shader_fs, @"Cannot to find out a shader");
    
    _shader = new Shader([shader_vs fileSystemRepresentation], [shader_fs fileSystemRepresentation]);
    
    _shader->use();
    _shader->setVec3("albedo", 0.5f, 0.0f, 0.0f);
    _shader->setFloat("ao", 1.0f);
    
    // lights
    
    _lightPositions = new glm::vec3[4] {
        glm::vec3(-10.0f,  10.0f, 10.0f),
        glm::vec3( 10.0f,  10.0f, 10.0f),
        glm::vec3(-10.0f, -10.0f, 10.0f),
        glm::vec3( 10.0f, -10.0f, 10.0f)
    };
    
    _lightColors = new glm::vec3[4] {
        glm::vec3(300.0f, 300.0f, 300.0f),
        glm::vec3(300.0f, 300.0f, 300.0f),
        glm::vec3(300.0f, 300.0f, 300.0f),
        glm::vec3(300.0f, 300.0f, 300.0f)
    };
    
    _nrRows    = 7;
    _nrColumns = 7;
    _spacing = 2.5;
    
    // camera
    
    _camera = new Camera(glm::vec3(0.0f, 0.0f, 10.0f));
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
    
    glClearColor(0.2f, 0.2f, 0.2f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    if (NULL != _shader)
    {
        // initialize static shader uniforms before rendering
        
        glm::mat4 projection = glm::perspective(_camera->Zoom,
            (float)(self.openGLView.frame.size.width / self.openGLView.frame.size.height), 0.1f, 100.0f);
        _shader->use();
        _shader->setMat4("projection", projection);
        glm::mat4 view = _camera->GetViewMatrix();
        _shader->setMat4("view", view);
        _shader->setVec3("camPos", _camera->Position);
        
        // render rows*column number of spheres with varying metallic/roughness
        // values scaled by rows and columns respectively
        
        glm::mat4 model;
        for (unsigned int row = 0; row < _nrRows; ++row)
        {
            _shader->setFloat("metallic", (float)row / (float)_nrRows);
            for (unsigned int col = 0; col < _nrColumns; ++col)
            {
                // we clamp the roughness to 0.025 - 1.0 as perfectly smooth surfaces
                // (roughness of 0.0) tend to look a bit off on direct lighting.
                _shader->setFloat("roughness", glm::clamp((float)col / (float)_nrColumns, 0.05f, 1.0f));
                
                model = glm::mat4();
                model = glm::translate(model, glm::vec3(
                    (float)(col - (_nrColumns / 2)) * _spacing,
                    (float)(row - (_nrRows / 2)) * _spacing,
                    0.0f)
                );
                _shader->setMat4("model", model);
                [self renderSphere];
            }
        }
        
        // render light source (simply re-render sphere at light positions)
        // this looks a bit off as we use the same shader, but it'll make their positions obvious and
        // keeps the codeprint small.
        const size_t numberOfElements = sizeof(_lightPositions) / sizeof(_lightPositions[0]);
        for (size_t i = 0; i < numberOfElements; ++i)
        {
            glm::vec3 newPos = _lightPositions[i] + glm::vec3(sin(currentTime * 5.0) * 5.0, 0.0, 0.0);
            newPos = _lightPositions[i];
            _shader->setVec3("lightPositions[" + std::to_string(i) + "]", newPos);
            _shader->setVec3("lightColors[" + std::to_string(i) + "]", _lightColors[i]);
            
            model = glm::mat4();
            model = glm::translate(model, newPos);
            model = glm::scale(model, glm::vec3(0.5f));
            _shader->setMat4("model", model);
            [self renderSphere];
        }
    }
    
    [self.openGLView.openGLContext flushBuffer];
}

- (void)renderSphere
{
    static GLuint sphereVAO = 0;
    static GLsizei indexCount = 0;
    
    if (sphereVAO == 0)
    {
        glGenVertexArrays(1, &sphereVAO);
        
        GLuint vbo, ebo;
        glGenBuffers(1, &vbo);
        glGenBuffers(1, &ebo);
        
        std::vector<glm::vec3> positions;
        std::vector<glm::vec2> uv;
        std::vector<glm::vec3> normals;
        std::vector<unsigned int> indices;
        
        const unsigned int X_SEGMENTS = 64;
        const unsigned int Y_SEGMENTS = 64;
        const float PI = 3.14159265359;
        for (GLuint y = 0; y <= Y_SEGMENTS; ++y)
        {
            for (unsigned int x = 0; x <= X_SEGMENTS; ++x)
            {
                float xSegment = (float)x / (float)X_SEGMENTS;
                float ySegment = (float)y / (float)Y_SEGMENTS;
                float xPos = std::cos(xSegment * 2.0f * PI) * std::sin(ySegment * PI);
                float yPos = std::cos(ySegment * PI);
                float zPos = std::sin(xSegment * 2.0f * PI) * std::sin(ySegment * PI);
                
                positions.push_back(glm::vec3(xPos, yPos, zPos));
                uv.push_back(glm::vec2(xSegment, ySegment));
                normals.push_back(glm::vec3(xPos, yPos, zPos));
            }
        }
        
        bool oddRow = false;
        for (int y = 0; y < Y_SEGMENTS; ++y)
        {
            if (!oddRow) // even rows: y == 0, y == 2; and so on
            {
                for (int x = 0; x <= X_SEGMENTS; ++x)
                {
                    indices.push_back(y       * (X_SEGMENTS + 1) + x);
                    indices.push_back((y + 1) * (X_SEGMENTS + 1) + x);
                }
            }
            else
            {
                for (int x = X_SEGMENTS; x >= 0; --x)
                {
                    indices.push_back((y + 1) * (X_SEGMENTS + 1) + x);
                    indices.push_back(y       * (X_SEGMENTS + 1) + x);
                }
            }
            oddRow = !oddRow;
        }
        indexCount = static_cast<GLsizei>(indices.size());
        
        std::vector<float> data;
        for (int i = 0; i < positions.size(); ++i)
        {
            data.push_back(positions[i].x);
            data.push_back(positions[i].y);
            data.push_back(positions[i].z);
            if (uv.size() > 0)
            {
                data.push_back(uv[i].x);
                data.push_back(uv[i].y);
            }
            if (normals.size() > 0)
            {
                data.push_back(normals[i].x);
                data.push_back(normals[i].y);
                data.push_back(normals[i].z);
            }
        }
        glBindVertexArray(sphereVAO);
        glBindBuffer(GL_ARRAY_BUFFER, vbo);
        glBufferData(GL_ARRAY_BUFFER, data.size() * sizeof(float), &data[0], GL_STATIC_DRAW);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices.size() * sizeof(unsigned int), &indices[0], GL_STATIC_DRAW);
        
        float stride = (3 + 2 + 3) * sizeof(float);
        glEnableVertexAttribArray(0);
        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, stride, (void*)0);
        glEnableVertexAttribArray(1);
        glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, stride, (void*)(3 * sizeof(float)));
        glEnableVertexAttribArray(2);
        glVertexAttribPointer(2, 3, GL_FLOAT, GL_FALSE, stride, (void*)(5 * sizeof(float)));
    }
    
    glBindVertexArray(sphereVAO);
    glDrawElements(GL_TRIANGLE_STRIP, indexCount, GL_UNSIGNED_INT, 0);
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
