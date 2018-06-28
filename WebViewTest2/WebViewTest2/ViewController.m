//
//  ViewController.m
//  WebViewTest2
//
//  Created by Anatoliy Goodz on 6/28/18.
//  Copyright © 2018 Anatoliy Goodz. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad
{
   [super viewDidLoad];

   NSURL *htmlUrl = [[NSBundle mainBundle] URLForResource:@"test" withExtension:@"html"];
   NSAssert(htmlUrl, @"file not found.");

   NSURLRequest *request = [NSURLRequest requestWithURL:htmlUrl];

   [self.webView loadRequest:request];

   
}

@end
