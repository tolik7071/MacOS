//
//  ViewController.m
//  WebView3Old
//
//  Created by Anatoliy Goodz on 7/4/18.
//  Copyright © 2018 Anatoliy Goodz. All rights reserved.
//

#import "ViewController.h"

#define LOG(s) NSLog(@"%s : %s", s, __PRETTY_FUNCTION__)

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.webView setFrameLoadDelegate:self];
    [self.webView setUIDelegate:self];
    [self.webView setPolicyDelegate:self];
    [self.webView setResourceLoadDelegate:self];
    [self.webView setDownloadDelegate:self];
    
    NSURL *urlHtml = [[NSBundle mainBundle] URLForResource:@"test" withExtension:@"html"];
    assert(urlHtml);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:urlHtml];
    
    [[self.webView mainFrame] loadRequest:request];
}

#pragma mark - WebResourceLoadDelegate

- (id)webView:(WebView *)sender
    identifierForInitialRequest:(NSURLRequest *)request
    fromDataSource:(WebDataSource *)dataSource
{
    //NSString * content = [[NSString alloc] initWithData:[dataSource data] encoding:NSUTF8StringEncoding];
    LOG("WebFrameLoadDelegate");
    
    return nil;
}

- (NSURLRequest *)webView:(WebView *)sender
    resource:(id)identifier
    willSendRequest:(NSURLRequest *)request
    redirectResponse:(NSURLResponse *)redirectResponse
    fromDataSource:(WebDataSource *)dataSource
{
    LOG("WebFrameLoadDelegate");
    
    return request;
}

- (void)webView:(WebView *)sender
    resource:(id)identifier
    didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
    fromDataSource:(WebDataSource *)dataSource
{
    LOG("WebFrameLoadDelegate");
    
/*
    [[challenge sender] useCredential:<#(nonnull NSURLCredential *)#>
           forAuthenticationChallenge:<#(nonnull NSURLAuthenticationChallenge *)#>];
    [[challenge sender] continueWithoutCredentialForAuthenticationChallenge:<#(nonnull NSURLAuthenticationChallenge *)#>];
    [[challenge sender] cancelAuthenticationChallenge:<#(nonnull NSURLAuthenticationChallenge *)#>];
    [[challenge sender] performDefaultHandlingForAuthenticationChallenge:<#(nonnull NSURLAuthenticationChallenge *)#>];
    [[challenge sender] rejectProtectionSpaceAndContinueWithChallenge:<#(nonnull NSURLAuthenticationChallenge *)#>];
 */
}

- (void)webView:(WebView *)sender
    resource:(id)identifier
    didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
    fromDataSource:(WebDataSource *)dataSource
{
    LOG("WebFrameLoadDelegate");
}

- (void)webView:(WebView *)sender
    resource:(id)identifier
    didReceiveResponse:(NSURLResponse *)response
    fromDataSource:(WebDataSource *)dataSource
{
    LOG("WebFrameLoadDelegate");
}

- (void)webView:(WebView *)sender
    resource:(id)identifier
    didReceiveContentLength:(NSInteger)length
    fromDataSource:(WebDataSource *)dataSource
{
    LOG("WebFrameLoadDelegate");
}

- (void)webView:(WebView *)sender
    resource:(id)identifier
    didFinishLoadingFromDataSource:(WebDataSource *)dataSource
{
    LOG("WebFrameLoadDelegate");
}

- (void)webView:(WebView *)sender
    resource:(id)identifier
    didFailLoadingWithError:(NSError *)error
    fromDataSource:(WebDataSource *)dataSource
{
    LOG("WebFrameLoadDelegate");
}

- (void)webView:(WebView *)sender
    plugInFailedWithError:(NSError *)error
    dataSource:(WebDataSource *)dataSource
{
    LOG("WebFrameLoadDelegate");
}

#pragma mark - WebFrameLoadDelegate

- (void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame
{
    LOG("WebFrameLoadDelegate");
}

- (void)webView:(WebView *)sender didReceiveServerRedirectForProvisionalLoadForFrame:(WebFrame *)frame
{
    LOG("WebFrameLoadDelegate");
}

- (void)webView:(WebView *)sender didFailProvisionalLoadWithError:(NSError *)error forFrame:(WebFrame *)frame
{
    LOG("WebFrameLoadDelegate");
}

- (void)webView:(WebView *)sender didCommitLoadForFrame:(WebFrame *)frame
{
    LOG("WebFrameLoadDelegate");
}

- (void)webView:(WebView *)sender didReceiveTitle:(NSString *)title forFrame:(WebFrame *)frame
{
    LOG("WebFrameLoadDelegate");
}

- (void)webView:(WebView *)sender didReceiveIcon:(NSImage *)image forFrame:(WebFrame *)frame
{
    LOG("WebFrameLoadDelegate");
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
    LOG("WebFrameLoadDelegate");
}

- (void)webView:(WebView *)sender didFailLoadWithError:(NSError *)error forFrame:(WebFrame *)frame
{
    LOG("WebFrameLoadDelegate");
}

- (void)webView:(WebView *)sender didChangeLocationWithinPageForFrame:(WebFrame *)frame
{
    LOG("WebFrameLoadDelegate");
}

- (void)webView:(WebView *)sender willPerformClientRedirectToURL:(NSURL *)URL delay:(NSTimeInterval)seconds fireDate:(NSDate *)date forFrame:(WebFrame *)frame
{
    LOG("WebFrameLoadDelegate");
}

- (void)webView:(WebView *)sender didCancelClientRedirectForFrame:(WebFrame *)frame
{
    LOG("WebFrameLoadDelegate");
}

- (void)webView:(WebView *)sender willCloseFrame:(WebFrame *)frame
{
    LOG("WebFrameLoadDelegate");
}

- (void)webView:(WebView *)webView didClearWindowObject:(WebScriptObject *)windowObject forFrame:(WebFrame *)frame
{
    LOG("WebFrameLoadDelegate");
}

//- (void)webView:(WebView *)webView windowScriptObjectAvailable:(WebScriptObject *)windowScriptObject
//{
//    LOG();
//}

- (void)webView:(WebView *)webView didCreateJavaScriptContext:(JSContext *)context forFrame:(WebFrame *)frame
{
    LOG("WebFrameLoadDelegate");
}

#pragma mark - WebPolicyDelegate

- (void)webView:(WebView *)webView
    decidePolicyForNavigationAction:(NSDictionary *)actionInformation
    request:(NSURLRequest *)request
    frame:(WebFrame *)frame
    decisionListener:(id<WebPolicyDecisionListener>)listener
{
    [listener use];
    LOG("WebPolicyDelegate");
}

- (void)webView:(WebView *)webView
    decidePolicyForNewWindowAction:(NSDictionary *)actionInformation
    request:(NSURLRequest *)request
    newFrameName:(NSString *)frameName
    decisionListener:(id<WebPolicyDecisionListener>)listener
{
    [listener use];
    LOG("WebPolicyDelegate");
}

- (void)webView:(WebView *)webView
    decidePolicyForMIMEType:(NSString *)type
    request:(NSURLRequest *)request
    frame:(WebFrame *)frame
    decisionListener:(id<WebPolicyDecisionListener>)listener
{
    [listener use];
    LOG("WebPolicyDelegate");
}

- (void)webView:(WebView *)webView unableToImplementPolicyWithError:(NSError *)error frame:(WebFrame *)frame
{
    LOG("WebPolicyDelegate");
}

#pragma mark - WebUIDelegate

- (WebView *)webView:(WebView *)sender createWebViewWithRequest:(NSURLRequest *)request
{
    LOG("WebUIDelegate");
    
    return nil;
}

- (void)webViewShow:(WebView *)sender
{
    LOG("WebUIDelegate");
}

- (WebView *)webView:(WebView *)sender createWebViewModalDialogWithRequest:(NSURLRequest *)request;
{
    LOG("WebUIDelegate");
    
    return nil;
}

- (void)webViewRunModal:(WebView *)sender
{
    LOG("WebUIDelegate");
}

- (void)webViewClose:(WebView *)sender
{
    LOG("WebUIDelegate");
}

- (void)webViewFocus:(WebView *)sender
{
    LOG("WebUIDelegate");
}

- (void)webViewUnfocus:(WebView *)sender
{
    LOG("WebUIDelegate");
}

- (NSResponder *)webViewFirstResponder:(WebView *)sender
{
    LOG("WebUIDelegate");
    
    return sender;
}

- (void)webView:(WebView *)sender makeFirstResponder:(NSResponder *)responder
{
    LOG("WebUIDelegate");
}

- (void)webView:(WebView *)sender setStatusText:(NSString *)text
{
    LOG("WebUIDelegate");
}

- (NSString *)webViewStatusText:(WebView *)sender
{
    LOG("WebUIDelegate");
    
    return @"!-- ... --!";
}

- (BOOL)webViewAreToolbarsVisible:(WebView *)sender
{
    LOG("WebUIDelegate");
    
    return NO;
}

- (void)webView:(WebView *)sender setToolbarsVisible:(BOOL)visible
{
    LOG("WebUIDelegate");
}

- (BOOL)webViewIsStatusBarVisible:(WebView *)sender
{
    LOG("WebUIDelegate");
    
    return NO;
}

- (void)webView:(WebView *)sender setStatusBarVisible:(BOOL)visible
{
    LOG("WebUIDelegate");
}

- (BOOL)webViewIsResizable:(WebView *)sender
{
    LOG("WebUIDelegate");
    
    return YES;
}

- (void)webView:(WebView *)sender setResizable:(BOOL)resizable
{
    LOG("WebUIDelegate");
}

- (void)webView:(WebView *)sender setFrame:(NSRect)frame
{
    LOG("WebUIDelegate");
}

- (NSRect)webViewFrame:(WebView *)sender
{
    LOG("WebUIDelegate");
    
    return self.view.frame;
}

- (void)webView:(WebView *)sender
    runJavaScriptAlertPanelWithMessage:(NSString *)message
    initiatedByFrame:(WebFrame *)frame
{
    LOG("WebUIDelegate");
}

- (BOOL)webView:(WebView *)sender
    runJavaScriptConfirmPanelWithMessage:(NSString *)message
    initiatedByFrame:(WebFrame *)frame
{
    LOG("WebUIDelegate");
    
    return YES;
}

- (NSString *)webView:(WebView *)sender
    runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt
    defaultText:(NSString *)defaultText
    initiatedByFrame:(WebFrame *)frame
{
    LOG("WebUIDelegate");
    
    return @"";
}

- (BOOL)webView:(WebView *)sender
    runBeforeUnloadConfirmPanelWithMessage:(NSString *)message
    initiatedByFrame:(WebFrame *)frame
{
    LOG("WebUIDelegate");
    
    return YES;
}

- (void)webView:(WebView *)sender
    runOpenPanelForFileButtonWithResultListener:(id<WebOpenPanelResultListener>)resultListener
{
    LOG("WebUIDelegate");
}

- (void)webView:(WebView *)sender
    runOpenPanelForFileButtonWithResultListener:(id<WebOpenPanelResultListener>)resultListener
    allowMultipleFiles:(BOOL)allowMultipleFiles
{
    LOG("WebUIDelegate");
}

- (void)webView:(WebView *)sender
    mouseDidMoveOverElement:(NSDictionary *)elementInformation
    modifierFlags:(NSUInteger)modifierFlags
{
    //LOG("WebUIDelegate");
}

- (NSArray *)webView:(WebView *)sender
    contextMenuItemsForElement:(NSDictionary *)element
    defaultMenuItems:(NSArray *)defaultMenuItems
{
    LOG("WebUIDelegate");
    
    return nil;
}

- (BOOL)webView:(WebView *)webView
    validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)item
    defaultValidation:(BOOL)defaultValidation
{
    LOG("WebUIDelegate");
    
    return YES;
}

- (BOOL)webView:(WebView *)webView shouldPerformAction:(SEL)action fromSender:(id)sender
{
    LOG("WebUIDelegate");
    
    return YES;
}

- (NSUInteger)webView:(WebView *)webView dragDestinationActionMaskForDraggingInfo:(id <NSDraggingInfo>)draggingInfo
{
    LOG("WebUIDelegate");
    
    return 0;
}

- (void)webView:(WebView *)webView
    willPerformDragDestinationAction:(WebDragDestinationAction)action
    forDraggingInfo:(id <NSDraggingInfo>)draggingInfo
{
    LOG("WebUIDelegate");
}

- (NSUInteger)webView:(WebView *)webView dragSourceActionMaskForPoint:(NSPoint)point
{
    LOG("WebUIDelegate");
    
    return 0;
}

- (void)webView:(WebView *)webView
    willPerformDragSourceAction:(WebDragSourceAction)action
    fromPoint:(NSPoint)point
    withPasteboard:(NSPasteboard *)pasteboard
{
    LOG("WebUIDelegate");
}

- (void)webView:(WebView *)sender
    printFrameView:(WebFrameView *)frameView
{
    LOG("WebUIDelegate");
}

- (float)webViewHeaderHeight:(WebView *)sender
{
    LOG("WebUIDelegate");
    
    return INFINITY;
}

- (float)webViewFooterHeight:(WebView *)sender
{
    LOG("WebUIDelegate");
    
    return INFINITY;
}

- (void)webView:(WebView *)sender drawHeaderInRect:(NSRect)rect
{
    LOG("WebUIDelegate");
}

- (void)webView:(WebView *)sender drawFooterInRect:(NSRect)rect
{
    LOG("WebUIDelegate");
}

@end
