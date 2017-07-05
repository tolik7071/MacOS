//
//  ViewController.h
//  OpenGL Template
//
//  Created by tolik7071 on 5/29/17.
//  Copyright © 2017 tolik7071. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController

@property (readonly, nonatomic) NSOpenGLView *openGLView;
@property (nonatomic) CVDisplayLinkRef displayLink;
@property (nonatomic) GLuint shaderProgram;

@end
