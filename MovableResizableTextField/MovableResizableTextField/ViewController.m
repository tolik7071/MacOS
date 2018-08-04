//
//  ViewController.m
//  MovableResizableTextField
//
//  Created by Anatoliy Goodz on 7/24/18.
//  Copyright © 2018 Anatoliy Goodz. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    NSArrayController *_graphicsController;
}

@property (nonatomic) NSMutableArray * graphics;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _graphicsController = [NSArrayController new];
    _graphics = [NSMutableArray new];
    _graphicView.graphicSelectionSource = self;
    _graphicsController.content = _graphics;
    
    [_graphicView bind:FTFGraphicViewSelectionIndexesBindingName
              toObject:_graphicsController
           withKeyPath:@"selectionIndexes"
               options:nil];
    
    [_graphicView bind:FTFGraphicViewGraphicsBindingName
              toObject:self
           withKeyPath:@"graphics"
               options:nil];
}

- (NSArray *)graphics
{
    return _graphics ? _graphics : [NSArray array];
}

- (void)insertGraphics:(NSArray *)graphics atIndexes:(NSIndexSet *)indexes
{
    if (!_graphics)
    {
        _graphics = [[NSMutableArray alloc] init];
    }
    
    [_graphics insertObjects:graphics atIndexes:indexes];
    
    [self startObservingGraphics:graphics];
}

- (void)removeGraphicsAtIndexes:(NSIndexSet *)indexes
{
    if (!_graphics)
    {
        _graphics = [[NSMutableArray alloc] init];
    }
    
    NSArray *graphics = [_graphics objectsAtIndexes:indexes];
    
    [self stopObservingGraphics:graphics];
    
    [_graphics removeObjectsAtIndexes:indexes];
}

- (void)startObservingGraphics:(NSArray *)graphics
{
    // TODO: undo
}


- (void)stopObservingGraphics:(NSArray *)graphics
{
    // TODO: undo
}

- (FTFGraphicToolIDs)selectedGraphic
{
    FTFGraphicToolIDs result = FTFSelectGraphicToolTag;
    
    switch (self.currentGraphicTool.selectedSegment)
    {
        case 1:
            result = FTFTextGraphicToolTag;
            break;
        
        case 2:
            result = FTFLineGraphicToolTag;
            break;
            
        default:
            break;
    }
    
    return result;
}

@end
