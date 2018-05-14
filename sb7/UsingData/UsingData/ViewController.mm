//
//  ViewController.m
//  UsingData
//
//  Created by tolik7071 on 5/3/18.
//  Copyright © 2018 tolik7071. All rights reserved.
//

#import "ViewController.h"
#import <OpenGL/gl3.h>
#import "GLUtilities.h"
#include <map>

const char * MapUniformType(GLuint aType);

@implementation ViewController
{
    GLuint  _programID;
    GLuint  _VAO;
    GLuint  _VBO;
}

- (void)cleanup
{
    [super cleanup];
    
    if (0 != _programID)
    {
        glDeleteProgram(_programID);
    }
    
    if (0 != _VAO)
    {
        glDeleteVertexArrays(1, &_VAO);
    }
    
    if (0 != _VBO)
    {
        glDeleteBuffers(1, &_VBO);
    }
}

- (void)configOpenGLEnvironment
{
    NSAssert(self.openGLView != nil, @"ERROR: openGLView is NULL");
    
    [self.openGLView.openGLContext makeCurrentContext];
    
    glEnable(GL_DEPTH_TEST);
    
    NSURL *vertexShader = FindResourceWithName(@"triangle.vert");
    NSAssert(vertexShader, @"Cannot find shader.");
    NSData *vertexShaderContent = ReadFile(vertexShader);
    NSAssert([vertexShaderContent length] > 0, @"Empty shader.");
    
    NSURL *fragmentShader = FindResourceWithName(@"triangle.frag");
    NSAssert(fragmentShader, @"Cannot find shader.");
    NSData *fragmentShaderContent = ReadFile(fragmentShader);
    NSAssert([fragmentShaderContent length] > 0, @"Empty shader.");
    
    _programID = CreateProgram(vertexShaderContent, fragmentShaderContent);
    NSAssert(_programID != 0, @"Cannot compile program.");
    
    glUseProgram(_programID);
    
    GLfloat vertices[] =
    {
        // verteces           // colors
        -0.5f, -0.5f, -0.5f,  0.0f, 0.0f, 1.0f,
         0.5f, -0.5f, -0.5f,  1.0f, 0.0f, 0.0f,
         0.5f,  0.5f, -0.5f,  1.0f, 1.0f, 0.0f
    };
    
    glGenVertexArrays(1, &_VAO);
    glBindVertexArray(_VAO);
    
    glGenBuffers(1, &_VBO);
    glBindBuffer(GL_ARRAY_BUFFER, _VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    assert(0 == glGetAttribLocation(_programID, "position"));
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(GLfloat), (void*)0);
    glEnableVertexAttribArray(0);
    
    assert(1 == glGetAttribLocation(_programID, "color"));
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(GLfloat), (void*)(3 * sizeof(GLfloat)));
    glEnableVertexAttribArray(1);
    
    // LAYPUT TEST
    static const GLchar * uniformNames[] =
    {
        "TransformBlock.scale",
        "TransformBlock.translation",
        "TransformBlock.rotation",
        "TransformBlock.projection_matrix"
    };
    
    GLuint uniformIndices[4];
    memset(uniformIndices, 0, sizeof(uniformIndices));
    glGetUniformIndices(_programID, 4, uniformNames, uniformIndices);
    
    GLint uniformTypes[4];
    memset(uniformTypes, 0, sizeof(uniformTypes));
    GLint uniformSizes[4];
    memset(uniformSizes, 0, sizeof(uniformSizes));
    GLint uniformOffsets[4];
    memset(uniformOffsets, 0, sizeof(uniformOffsets));
    GLint arrayStrides[4];
    memset(arrayStrides, 0, sizeof(arrayStrides));
    GLint matrixStrides[4];
    memset(matrixStrides, 0, sizeof(matrixStrides));
    
    glGetActiveUniformsiv(_programID, 4, uniformIndices, GL_UNIFORM_TYPE, uniformTypes);
    glGetActiveUniformsiv(_programID, 4, uniformIndices, GL_UNIFORM_SIZE, uniformSizes);
    glGetActiveUniformsiv(_programID, 4, uniformIndices, GL_UNIFORM_OFFSET, uniformOffsets);
    glGetActiveUniformsiv(_programID, 4, uniformIndices, GL_UNIFORM_ARRAY_STRIDE, arrayStrides);
    glGetActiveUniformsiv(_programID, 4, uniformIndices, GL_UNIFORM_MATRIX_STRIDE, matrixStrides);
    
    for (int i = 0; i < sizeof(uniformNames) / sizeof(*uniformNames); ++i)
    {
        printf("%s: (%s %d)\n", uniformNames[i], MapUniformType(uniformTypes[i]), uniformSizes[i]);
        printf("\toffset %d, array stride %d, matrix stride %d\n\n", uniformOffsets[i], arrayStrides[i], matrixStrides[i]);
    }
}

- (void)renderForTime:(MyTimeStamp *)time
{
    if ([self.view inLiveResize])
    {
        return;
    }
    
    [self.openGLView.openGLContext makeCurrentContext];
    
    GLfloat currentTime = (GLfloat)(time->_timeStamp.videoTime) / (GLfloat)(time->_timeStamp.videoTimeScale);
    _deltaTime = currentTime - _lastFrame;
    _lastFrame = currentTime;
    
    if (0 != _programID)
    {
        glUseProgram(_programID);
        
        glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        
        glBindVertexArray(_VAO);
        
        glDrawArrays(GL_TRIANGLES, 0, 3);
    }
    
    [self.openGLView.openGLContext flushBuffer];
}

@end

// LAYPUT TEST

#define INSERT_UNIFORM_TYPE(type, map) \
{ \
std::pair<GLuint, std::string> pair = std::make_pair(type, #type); \
map.insert(pair); \
}

const char * MapUniformType(GLuint aType)
{
    typedef std::map<GLuint, std::string> TTypeMap;
    static TTypeMap sMap;
    
    if (sMap.empty())
    {
        INSERT_UNIFORM_TYPE(GL_FLOAT, sMap);
        INSERT_UNIFORM_TYPE(GL_FLOAT_VEC2, sMap);
        INSERT_UNIFORM_TYPE(GL_FLOAT_VEC3, sMap);
        INSERT_UNIFORM_TYPE(GL_FLOAT_VEC4, sMap);
        INSERT_UNIFORM_TYPE(GL_DOUBLE, sMap);
        INSERT_UNIFORM_TYPE(GL_DOUBLE_VEC2, sMap);
        INSERT_UNIFORM_TYPE(GL_DOUBLE_VEC3, sMap);
        INSERT_UNIFORM_TYPE(GL_DOUBLE_VEC4, sMap);
        INSERT_UNIFORM_TYPE(GL_INT, sMap);
        INSERT_UNIFORM_TYPE(GL_INT_VEC2, sMap);
        INSERT_UNIFORM_TYPE(GL_INT_VEC3, sMap);
        INSERT_UNIFORM_TYPE(GL_INT_VEC4, sMap);
        INSERT_UNIFORM_TYPE(GL_UNSIGNED_INT, sMap);
        INSERT_UNIFORM_TYPE(GL_UNSIGNED_INT_VEC2, sMap);
        INSERT_UNIFORM_TYPE(GL_UNSIGNED_INT_VEC3, sMap);
        INSERT_UNIFORM_TYPE(GL_UNSIGNED_INT_VEC4, sMap);
        INSERT_UNIFORM_TYPE(GL_BOOL, sMap);
        INSERT_UNIFORM_TYPE(GL_BOOL_VEC2, sMap);
        INSERT_UNIFORM_TYPE(GL_BOOL_VEC3, sMap);
        INSERT_UNIFORM_TYPE(GL_FLOAT_MAT2, sMap);
        INSERT_UNIFORM_TYPE(GL_FLOAT_MAT3, sMap);
        INSERT_UNIFORM_TYPE(GL_FLOAT_MAT4, sMap);
        INSERT_UNIFORM_TYPE(GL_FLOAT_MAT2x3, sMap);
        INSERT_UNIFORM_TYPE(GL_FLOAT_MAT2x4, sMap);
        INSERT_UNIFORM_TYPE(GL_FLOAT_MAT3x2, sMap);
        INSERT_UNIFORM_TYPE(GL_FLOAT_MAT3x4, sMap);
        INSERT_UNIFORM_TYPE(GL_FLOAT_MAT4x2, sMap);
        INSERT_UNIFORM_TYPE(GL_FLOAT_MAT4x3, sMap);
        INSERT_UNIFORM_TYPE(GL_DOUBLE_MAT2, sMap);
        INSERT_UNIFORM_TYPE(GL_DOUBLE_MAT3, sMap);
        INSERT_UNIFORM_TYPE(GL_DOUBLE_MAT4, sMap);
        INSERT_UNIFORM_TYPE(GL_DOUBLE_MAT2x3, sMap);
        INSERT_UNIFORM_TYPE(GL_DOUBLE_MAT2x4, sMap);
        INSERT_UNIFORM_TYPE(GL_DOUBLE_MAT3x2, sMap);
        INSERT_UNIFORM_TYPE(GL_DOUBLE_MAT3x4, sMap);
        INSERT_UNIFORM_TYPE(GL_DOUBLE_MAT4x2, sMap);
        INSERT_UNIFORM_TYPE(GL_DOUBLE_MAT4x3, sMap);
        INSERT_UNIFORM_TYPE(GL_SAMPLER_1D, sMap);
        INSERT_UNIFORM_TYPE(GL_SAMPLER_2D, sMap);
        INSERT_UNIFORM_TYPE(GL_SAMPLER_3D, sMap);
        INSERT_UNIFORM_TYPE(GL_SAMPLER_1D_SHADOW, sMap);
        INSERT_UNIFORM_TYPE(GL_SAMPLER_2D_SHADOW, sMap);
        INSERT_UNIFORM_TYPE(GL_SAMPLER_1D_ARRAY, sMap);
        INSERT_UNIFORM_TYPE(GL_SAMPLER_2D_ARRAY, sMap);
        INSERT_UNIFORM_TYPE(GL_SAMPLER_1D_ARRAY_SHADOW, sMap);
        INSERT_UNIFORM_TYPE(GL_SAMPLER_2D_ARRAY_SHADOW, sMap);
        INSERT_UNIFORM_TYPE(GL_SAMPLER_2D_MULTISAMPLE, sMap);
        INSERT_UNIFORM_TYPE(GL_SAMPLER_2D_MULTISAMPLE_ARRAY, sMap);
        INSERT_UNIFORM_TYPE(GL_SAMPLER_CUBE_SHADOW, sMap);
        INSERT_UNIFORM_TYPE(GL_SAMPLER_BUFFER, sMap);
        INSERT_UNIFORM_TYPE(GL_SAMPLER_2D_RECT, sMap);
        INSERT_UNIFORM_TYPE(GL_SAMPLER_2D_RECT_SHADOW, sMap);
        INSERT_UNIFORM_TYPE(GL_INT_SAMPLER_1D, sMap);
        INSERT_UNIFORM_TYPE(GL_INT_SAMPLER_2D, sMap);
        INSERT_UNIFORM_TYPE(GL_INT_SAMPLER_3D, sMap);
        INSERT_UNIFORM_TYPE(GL_INT_SAMPLER_CUBE, sMap);
        INSERT_UNIFORM_TYPE(GL_INT_SAMPLER_1D_ARRAY, sMap);
        INSERT_UNIFORM_TYPE(GL_INT_SAMPLER_2D_ARRAY, sMap);
        INSERT_UNIFORM_TYPE(GL_INT_SAMPLER_2D_MULTISAMPLE, sMap);
        INSERT_UNIFORM_TYPE(GL_INT_SAMPLER_2D_MULTISAMPLE_ARRAY, sMap);
        INSERT_UNIFORM_TYPE(GL_INT_SAMPLER_BUFFER, sMap);
        INSERT_UNIFORM_TYPE(GL_INT_SAMPLER_2D_RECT, sMap);
        INSERT_UNIFORM_TYPE(GL_UNSIGNED_INT_SAMPLER_1D, sMap);
        INSERT_UNIFORM_TYPE(GL_UNSIGNED_INT_SAMPLER_2D, sMap);
        INSERT_UNIFORM_TYPE(GL_UNSIGNED_INT_SAMPLER_3D, sMap);
        INSERT_UNIFORM_TYPE(GL_UNSIGNED_INT_SAMPLER_CUBE, sMap);
        INSERT_UNIFORM_TYPE(GL_UNSIGNED_INT_SAMPLER_1D_ARRAY, sMap);
        INSERT_UNIFORM_TYPE(GL_UNSIGNED_INT_SAMPLER_2D_ARRAY, sMap);
        INSERT_UNIFORM_TYPE(GL_UNSIGNED_INT_SAMPLER_2D_MULTISAMPLE, sMap);
        INSERT_UNIFORM_TYPE(GL_UNSIGNED_INT_SAMPLER_2D_MULTISAMPLE_ARRAY, sMap);
        INSERT_UNIFORM_TYPE(GL_UNSIGNED_INT_SAMPLER_BUFFER, sMap);
        INSERT_UNIFORM_TYPE(GL_UNSIGNED_INT_SAMPLER_2D_RECT, sMap);
    }
    
    return sMap[aType].c_str();
}
