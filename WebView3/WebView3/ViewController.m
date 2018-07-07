//
//  ViewController.m
//  WebView3
//
//  Created by Anatoliy Goodz on 7/4/18.
//  Copyright © 2018 Anatoliy Goodz. All rights reserved.
//

#import "ViewController.h"
#import <objc/objc-runtime.h>

#define LOG(s) NSLog(@"%s : %s", s, __PRETTY_FUNCTION__)

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSURL *urlHtml = [[NSBundle mainBundle] URLForResource:@"test" withExtension:@"html"];
    assert(urlHtml);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:urlHtml];
    
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"get_array"];
    
    [self.webView loadRequest:request];
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView
    decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
    decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    LOG("WKNavigationDelegate");
    
//    if (navigationAction.request.URL.isFileURL)
//    {
//        decisionHandler(WKNavigationActionPolicyCancel);
//
//        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.apple.com"]];
//        [self.webView loadRequest:request];
//        return;
//    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView
    decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse
    decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
    LOG("WKNavigationDelegate");
    
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
    LOG("WKNavigationDelegate");
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
    LOG("WKNavigationDelegate");
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    LOG("WKNavigationDelegate");
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation
{
    LOG("WKNavigationDelegate");
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
{
    LOG("WKNavigationDelegate");
    
//    unsigned int methodsCount = 0;
//    Method *methods = class_copyMethodList([webView class], &methodsCount);
//    for (unsigned int i = 0; i < methodsCount; ++i)
//    {
//        SEL selector = method_getName(methods[i]);
//        printf("%s\n", [NSStringFromSelector(selector) UTF8String]);
//    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    LOG("WKNavigationDelegate");
}

- (void)webView:(WKWebView *)webView
    didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
    completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler
{
    LOG("WKNavigationDelegate");
    
    completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView
{
    LOG("WKNavigationDelegate");
}

#pragma mark - WKUIDelegate

- (nullable WKWebView *)webView:(WKWebView *)webView
    createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration
            forNavigationAction:(WKNavigationAction *)navigationAction
                 windowFeatures:(WKWindowFeatures *)windowFeatures
{
    LOG("WKUIDelegate");
    
    return [[WKWebView alloc] initWithFrame:NSMakeRect(
            [windowFeatures.x doubleValue],
            [windowFeatures.y doubleValue],
            [windowFeatures.width doubleValue],
            [windowFeatures.height doubleValue])
        configuration:configuration];
}

- (void)webViewDidClose:(WKWebView *)webView
{
    LOG("WKUIDelegate");
}

- (void)webView:(WKWebView *)webView
    runJavaScriptAlertPanelWithMessage:(NSString *)message
    initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    LOG("WKUIDelegate");
}

- (void)webView:(WKWebView *)webView
    runJavaScriptConfirmPanelWithMessage:(NSString *)message
    initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler
{
    LOG("WKUIDelegate");
}

- (void)webView:(WKWebView *)webView
    runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt
    defaultText:(nullable NSString *)defaultText
    initiatedByFrame:(WKFrameInfo *)frame
    completionHandler:(void (^)(NSString * _Nullable result))completionHandler
{
    LOG("WKUIDelegate");
}

- (void)webView:(WKWebView *)webView
    runOpenPanelWithParameters:(WKOpenPanelParameters *)parameters
    initiatedByFrame:(WKFrameInfo *)frame
    completionHandler:(void (^)(NSArray<NSURL *> * _Nullable URLs))completionHandler
{
    LOG("WKUIDelegate");
}

#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message
{
    LOG("WKUIDelegate");
    
    NSLog(@"name = %@, body = %@ (%@)", message.name, message.body, [message.body className]);
}

@end
