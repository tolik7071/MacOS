//
//  ViewController.h
//  WebView3
//
//  Created by Anatoliy Goodz on 7/4/18.
//  Copyright © 2018 Anatoliy Goodz. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface ViewController : NSViewController <WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler>

@property (nonatomic, weak) IBOutlet WKWebView * webView;

@end
