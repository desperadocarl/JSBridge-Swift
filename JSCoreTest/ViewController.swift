//
//  ViewController.swift
//  JSCoreTest
//
//  Created by 熊智亮 on 2017/2/14.
//  Copyright © 2017年 熊智亮. All rights reserved.
//

import UIKit
import JavaScriptCore

class ViewController: UIViewController, UIWebViewDelegate {

    var webView: UIWebView!
    var jsContext: JSContext!
    
    var requestUrl: String! = "http://www.llbe.com.cn/JSBridge/test.htm"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.webView = UIWebView(frame: self.view.bounds)
        self.view.addSubview(webView)
        self.webView.delegate = self
        self.webView.scalesPageToFit = true
        
        let url = Bundle.main.url(forResource: "test", withExtension: "html")
  
        //let url = URL(string: requestUrl)
        
        let request = URLRequest(url: url!)
        self.webView.loadRequest(request)
        
    }
    
    
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.jsContext = webView.value(forKeyPath: "documentView.webView.mainFrame.javaScriptContext") as! JSContext
        
        let model = JSModel()
        
        model.controller = self
        model.jsContext = self.jsContext
        
        //将model注入js，即可通过DDJSBridge调用我们暴露的方法
        let key = "DDJSBridge"
        self.jsContext.setObject(model, forKeyedSubscript: key as (NSCopying & NSObjectProtocol)!)
        
        let url = Bundle.main.url(forResource: "test", withExtension: "html")
        //let url = URL(string: requestUrl)
        
        let content = try? String(contentsOf: url!, encoding: String.Encoding.utf8)
        let _ = self.jsContext.evaluateScript(content as String!)
        
        
        self.jsContext.exceptionHandler = { (context, exception) in
            print("exception:", exception ?? "no exception")
        }
        
        print("WebView didFinishLoad")
    }
}
