//
//  ViewController.h
//  WebView3Old
//
//  Created by Anatoliy Goodz on 7/4/18.
//  Copyright © 2018 Anatoliy Goodz. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface ViewController : NSViewController
    <
        WebFrameLoadDelegate,
        WebUIDelegate,
        WebPolicyDelegate,
        WebResourceLoadDelegate,
        WebDownloadDelegate
    >

@property (nonatomic, weak) IBOutlet WebView * webView;

@end
