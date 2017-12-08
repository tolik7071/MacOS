//
//  ViewController.m
//  pipe_test
//
//  Created by Anatoliy Goodz on 12/7/17.
//  Copyright © 2017 Anatoliy Goodz. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController
{
    NSTask  *_logger;
    NSPipe  *_outputPipe;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Logger" ofType:nil];
    NSAssert(path != nil, @"Logger not found.");
    
    _logger = [[NSTask alloc] init];
    [_logger setLaunchPath:path];
    
    _outputPipe = [NSPipe new];
    [_logger setStandardInput:_outputPipe];
    
    [_logger launch];
    
    [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(windowWillClose:)
         name:NSWindowWillCloseNotification
         object:[self.view window]];
}

- (void)windowWillClose:(NSNotification*)notification
{
    [[_outputPipe fileHandleForWriting] closeFile];
    
    [_logger terminate];
}

- (IBAction)sendMessage:(id)sender
{
//    NSString *text = self.text.stringValue;
//    
//    if (text.length == 0)
//    {
//        return;
//    }
//    
//    if ([text characterAtIndex:(text.length - 1)] != '\n')
//    {
//        text = [NSString stringWithFormat:@"%@\n", text];
//    }
//    
//    [[_outputPipe fileHandleForWriting] writeData:[text dataUsingEncoding:NSUTF8StringEncoding]];
//    
//    self.text.stringValue = @"";
    
    for (int i = 0; i < 100000; i++)
    {
        NSString *message = [NSString stringWithFormat:@"%d\n", i];
        NSLog(@"APP begin: %@", message);
        [[_outputPipe fileHandleForWriting] writeData:[message dataUsingEncoding:NSUTF8StringEncoding]];
        NSLog(@"APP end.");
    }
    
    int *data = NULL;
    *data = 1;
}

@end
