//
//  ViewController.h
//  WebViewTest2
//
//  Created by Anatoliy Goodz on 6/28/18.
//  Copyright © 2018 Anatoliy Goodz. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface ViewController : NSViewController <WKScriptMessageHandler, WKNavigationDelegate>

@property (nonatomic, weak) IBOutlet WKWebView * webView;

@end

