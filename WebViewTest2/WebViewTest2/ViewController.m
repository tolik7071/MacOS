//
//  ViewController.m
//  WebViewTest2
//
//  Created by Anatoliy Goodz on 6/28/18.
//  Copyright © 2018 Anatoliy Goodz. All rights reserved.
//

#import "ViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSURL *htmlUrl = [[NSBundle mainBundle] URLForResource:@"test" withExtension:@"html"];
    NSAssert(htmlUrl, @"file not found.");

    NSURLRequest *request = [NSURLRequest requestWithURL:htmlUrl];

    [self.webView loadRequest:request];
}


- (IBAction)replace:(id)sender
{
    static BOOL isAdded = NO;
    
    if (!isAdded)
    {
#if 0
        WKUserScript *script = [[WKUserScript alloc] initWithSource:
            @"window.getColorFor = function(element) { window.webkit.messageHandlers.getColorFor.postMessage(element.id); /*return 'purple';*/ }"
            injectionTime:WKUserScriptInjectionTimeAtDocumentEnd
            forMainFrameOnly:NO];
        [self.webView.configuration.userContentController addUserScript:script];
        [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"getColorFor"];
        
        [self.webView reload];
#else
        WKUserScript *script = [[WKUserScript alloc] initWithSource:
            @"window.getColorFor = function(element)"
            "{"
            "   FTMReturnValue = undefined;"
            "   window.webkit.messageHandlers.getColorFor.postMessage(element.id);"
            "   while (!FTMReturnValue) {"
            "       window.webkit.messageHandlers.trackEvent.postMessage('');"
                "}"
            "   return FTMReturnValue;"
            "}"
            injectionTime:WKUserScriptInjectionTimeAtDocumentEnd
            forMainFrameOnly:NO];
        [self.webView.configuration.userContentController addUserScript:script];
        [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"getColorFor"];
        [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"trackEvent"];
#endif
        
        isAdded = YES;
    }
}

#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message
{
    NSLog(@"%@ : %@", message.name, message.body);
    
#if 0
    NSString *script = [NSString stringWithFormat:@"document.getElementById('%@').style.backgroundColor = '%@';", message.body, @"cyan"];
    [self.webView evaluateJavaScript:script completionHandler:nil];
#else
    NSString *script = [NSString stringWithFormat:@"FTMReturnValue = 'cyan'"];
    [self.webView evaluateJavaScript:script completionHandler:nil];
#endif
}

@end
