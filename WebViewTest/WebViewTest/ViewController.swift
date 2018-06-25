//
//  ViewController.swift
//  WebViewTest
//
//  Created by Anatoliy Goodz on 6/15/18.
//  Copyright © 2018 Anatoliy Goodz. All rights reserved.
//

import Cocoa
import WebKit

// EXAMPLE: http://www.joshuakehn.com/2014/10/29/using-javascript-with-wkwebview-in-ios-8.html

class ViewController: NSViewController, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {

   @IBOutlet weak var webView : WKWebView!
    
//    class override func webScriptName(for selector: Selector!) -> String! {
//        return ""
//    }

   override func viewDidLoad() {
        super.viewDidLoad()

        print(#function)

        let url = Bundle.main.url(forResource: "test", withExtension: "html")
        let request = URLRequest(url: url!)

        webView.navigationDelegate = self
        webView.uiDelegate = self

        webView.configuration.userContentController.add(self, name: "observe")
        webView.configuration.userContentController.add(self, name: "logtoswift")

        let script = WKUserScript(source: "window.change_color = function() {document.getElementById('color_changeble').style.backgroundColor = 'blue';}", injectionTime: WKUserScriptInjectionTime.atDocumentEnd, forMainFrameOnly: true)
        webView.configuration.userContentController.addUserScript(script);

        let script2 = WKUserScript(source:
        """
            if (window.FTM == undefined) {
                window.FTM = {};
            }
            window.FTM.callme = function() {
                window.webkit.messageHandlers.observe.postMessage('WOW');
            }

            window.webkit.messageHandlers.logtoswift.postMessage("#3");
        """, injectionTime: WKUserScriptInjectionTime.atDocumentEnd, forMainFrameOnly: true)
        webView.configuration.userContentController.addUserScript(script2);

        webView.load(request)
    }

   @IBAction func sendDateTime(sender: NSButton) {
      webView.evaluateJavaScript("send_current_date_time()", completionHandler: nil)
   }

   // MARK: - WKNavigationDelegate -

   func webView(_ webView: WKWebView,
                decidePolicyFor navigationAction: WKNavigationAction,
                decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void)
   {
      print("\(#function), -> type : , \(navigationAction.navigationType.rawValue)")
      decisionHandler(WKNavigationActionPolicy.allow)
   }

   func webView(_ webView: WKWebView,
                decidePolicyFor navigationResponse: WKNavigationResponse,
                decisionHandler: @escaping (WKNavigationResponsePolicy) -> Swift.Void)
   {
      print(#function)
      decisionHandler(WKNavigationResponsePolicy.allow)
   }

   func webView(_ webView: WKWebView,
                didStartProvisionalNavigation navigation: WKNavigation!)
   {
      print(#function)
   }

   func webView(_ webView: WKWebView,
                didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!)
   {
      print(#function)
   }

   func webView(_ webView: WKWebView,
                didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error)
   {
      print(#function)
   }

   func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!)
   {
      print(#function)
   }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!)
    {
        print(#function)
        let script = WKUserScript(source: "window.FTM.callme = function() { window.webkit.messageHandlers.observe.postMessage('WOW'); }", injectionTime: WKUserScriptInjectionTime.atDocumentEnd, forMainFrameOnly: true)
        webView.configuration.userContentController.addUserScript(script);
//        webView.evaluateJavaScript("window.FTM.callme = function() { window.webkit.messageHandlers.observe.postMessage('WOW'); }", completionHandler: nil);
    }

   func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error)
   {
      print(#function)
   }

   func webView(_ webView: WKWebView,
                didReceive challenge: URLAuthenticationChallenge,
                completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void)
   {
      print(#function)
      completionHandler(URLSession.AuthChallengeDisposition.performDefaultHandling, nil)
   }

   func webViewWebContentProcessDidTerminate(_ webView: WKWebView)
   {
      print(#function)
   }

   // MARK: - WKUIDelegate -

   func webView(_ webView: WKWebView,
                createWebViewWith configuration: WKWebViewConfiguration,
                for navigationAction: WKNavigationAction,
                windowFeatures: WKWindowFeatures) -> WKWebView?
   {
      print(#function)
      //return WKWebView(frame: NSMakeRect(0, 0, 200, 200), configuration: configuration);
      return nil;
   }

   func webViewDidClose(_ webView: WKWebView)
   {
      print(#function)
   }

   func webView(_ webView: WKWebView,
               runJavaScriptAlertPanelWithMessage message: String,
               initiatedByFrame frame: WKFrameInfo,
               completionHandler: @escaping () -> Swift.Void)
   {
      print(#function)
      completionHandler()
      let alert : NSAlert = NSAlert()
      alert.messageText = message
      alert.runModal()
   }

   func webView(_ webView: WKWebView,
                runJavaScriptConfirmPanelWithMessage message: String,
                initiatedByFrame frame: WKFrameInfo,
                completionHandler: @escaping (Bool) -> Swift.Void)
   {
      print(#function)
   }

   func webView(_ webView: WKWebView,
                runJavaScriptTextInputPanelWithPrompt prompt: String,
                defaultText: String?,
                initiatedByFrame frame: WKFrameInfo,
                completionHandler: @escaping (String?) -> Swift.Void)
   {
      print(#function)
   }

   func webView(_ webView: WKWebView,
                runOpenPanelWith parameters: WKOpenPanelParameters,
                initiatedByFrame frame: WKFrameInfo,
                completionHandler: @escaping ([URL]?) -> Swift.Void)
   {
      print(#function)
   }

   // MARK: - WKScriptMessageHandler -

   func userContentController(_ userContentController: WKUserContentController,
                              didReceive message: WKScriptMessage)
   {
      print("\(#function) -> \(message.name) : \(message.body)")
   }
}
