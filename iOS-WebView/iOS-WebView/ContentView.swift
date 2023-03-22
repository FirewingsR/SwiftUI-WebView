//
//  ContentView.swift
//  iOS-WebView
//
//  Created by William on 2023/3/22.
//

import SwiftUI
import WebKit
import AVFoundation

struct ContentView: View {
  @StateObject var webViewStore = WebViewStore()
  
  var body: some View {
    NavigationView {
        WebView(webView: webViewStore.webView)
        .navigationBarTitle(Text(verbatim: webViewStore.title ?? ""), displayMode: .inline)
        .navigationBarItems(trailing: HStack {
          Button(action: goBack) {
            Image(systemName: "chevron.left")
              .imageScale(.large)
              .aspectRatio(contentMode: .fit)
              .frame(width: 32, height: 32)
          }.disabled(!webViewStore.canGoBack)
          Button(action: goForward) {
            Image(systemName: "chevron.right")
              .imageScale(.large)
              .aspectRatio(contentMode: .fit)
              .frame(width: 32, height: 32)
          }.disabled(!webViewStore.canGoForward)
        })
    }.onAppear {
        self.webViewStore.webView.load(URLRequest(url: URL(string: "https://www.baidu.com")!))
        print(webViewStore.webView)
        addJSFromIOS(wkWebView: webViewStore.webView)
    }
      
  }
  
  func goBack() {
    webViewStore.webView.goBack()
  }
  
  func goForward() {
    webViewStore.webView.goForward()
  }
    
  func addJSFromIOS(wkWebView: WKWebView!) {
      // ios 向网页注入 js，注入js分为在网页加载完毕注入(.atDocumentStart)和加载之前注入(.atDocumentEnd)
      let js = """
            document.getElementById('index-bn').innerText='调用ios原生';
            document.getElementById('index-bn').onclick=function(){  //通过匿名函数将调用的需要传入参数的函数包起来
                window.webkit.messageHandlers.jsToIOS.postMessage("这是js传递到ios的数据");
            };
            """
      let script = WKUserScript.init(source: js, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
      wkWebView?.configuration.userContentController.addUserScript(script)
      // jsToIOS 是JavaScript向IOS发送数据时，使用的函数名
      wkWebView?.configuration.userContentController.add(CustomWKHandler(), name: "jsToIOS")
  }
    
}

class CustomWKHandler : NSObject, WKScriptMessageHandler, WKUIDelegate {
    let speechSynthesizer = AVSpeechSynthesizer()
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("JS发送到IOS的数据====\(message.body), name=\(message.name)")
        speak([(phrase: (message.body as AnyObject).description, wait: 0.1)])
    }
    
    func speak(_ phrases: [(phrase: String, wait: Double)]) {
        if let (phrase, wait) = phrases.first {
            let speechUtterance = AVSpeechUtterance(string: phrase)
            speechSynthesizer.speak(speechUtterance)
            let rest = Array(phrases.dropFirst())
            if !rest.isEmpty {
                delay(wait) {
                    self.speak(rest)
                }
            }
        }
    }
    
    func delay(_ delay:Double, closure:@escaping ()->()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
