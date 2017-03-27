//
//  File.swift
//  JSCoreTest
//
//  Created by 熊智亮 on 2017/2/14.
//  Copyright © 2017年 熊智亮. All rights reserved.
//

import Foundation
import UIKit
import JavaScriptCore

/// 定义需要被JS调用的接口
@objc protocol JSDelegate: JSExport {
    /// 多参数方法，在JS中调用时，函数名应写成这样：callNativeWithCallback  ,及需要把后面的参数名写在方法名后
    func call(_ methodName: String, _ params:[String : AnyObject], _ callback: JSValue)

}

/// 实现 JSDelegate 协议
@objc class JSModel:NSObject, JSDelegate {

    weak var controller: UIViewController?
    weak var jsContext: JSContext?
    
    func call(_ methodName: String, _ params:[String : AnyObject], _ callback: JSValue) {
        print("\(params) called and have a callback ")
//        let result = ["isSuccess": true, "reason": "回调成功"] as [String : Any]
//        callback.call(withArguments: [result])
        
        if methodName != ""{
            let data = params["data"]
            // 调用方法，带参数
            switch methodName {
            case "showTitleBar":
                controller?.navigationController?.setNavigationBarHidden(false, animated: true)
            case "hideTitleBar":
                controller?.navigationController?.setNavigationBarHidden(true, animated: true)
            case "showNetWorkType":
                let reachability: Reachability = Reachability.init()!
                let networkType = reachability.currentReachabilityStatus.description
                let result = ["ok":true, "data":networkType] as [String: Any]
                callback.call(withArguments: [result])
            case "confirm":
                let cancelButton = data?["cancelButton"] as? String ?? "取消"
                let okButton = data?["okButton"] as? String ?? "确定"
                let message = data?["message"] as? String ?? ""
                let title = data?["title"] as? String ?? ""
                
                if message != "" {
                    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: cancelButton, style: .cancel) { (action) in
                        let result = ["ok": false, "reason": ""] as [String : Any]
                        let jsonData = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                        let resultStr = String(data: jsonData!, encoding: String.Encoding.utf8)
                        callback.call(withArguments: [resultStr ?? ""])
                    }
                    let confirmAction = UIAlertAction(title: okButton, style: .default) { (action) in
                        let result = ["ok": true, "reason": ""] as [String : Any]
                        let jsonData = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                        let resultStr = String(data: jsonData!, encoding: String.Encoding.utf8)
                        callback.call(withArguments: [resultStr ?? ""])
                    }
                    alert.addAction(cancelAction)
                    alert.addAction(confirmAction)
                    DispatchQueue.main.async {
                        self.controller?.present(alert, animated: true, completion: {
                            print("confirm show")
                        })
                    }
                }
            case "prompt":
              
              
                    let result = ["ok": true, "data": "dd" ] as [String : Any]
                    
                    callback.call(withArguments: [result])
              
               
            case "showShareButton":
                let icon = data?["icon"] as? String ?? "";
                //let shareUrl = params["data"]?["url"]
                if icon != "" {
                    let imgUrl = URL(string: icon)
                    let image = try? UIImage(data: Data(contentsOf: imgUrl!), scale: 3)
                    let rightBarButton = UIBarButtonItem(image: image!, style: UIBarButtonItemStyle.plain, target: self, action: #selector(rightBarButtonClick))
                    controller?.navigationItem.rightBarButtonItem = rightBarButton // 设置一个右按钮
                } else {
                    let rightBarButton = UIBarButtonItem(title: "分享", style: .plain, target: self, action: #selector(rightBarButtonClick))
                    controller?.navigationItem.rightBarButtonItem = rightBarButton // 设置一个右按钮
                }
                
                
            case "setTitle":
                let title = data?["title"] as? String ?? ""
                //let subTitle = params["data"]?["subtitle"] as? String ?? ""
                controller?.title = title
                
            case "alert":
                let title = data?["title"] as? String ?? ""
                let message = data?["message"] as? String ?? ""
                let button = data?["button"] as? String ?? ""
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                let alertAction = UIAlertAction(title: button, style: .default, handler: { (action) in
                    print("after alert action click")
                })
                alert.addAction(alertAction)
                DispatchQueue.main.async {
                    self.controller?.present(alert, animated: true, completion: {
                        print("afert alert")
                    })
                }
                
            case "toast":
                let position = data?["position"] as? String ?? "center"
                let message = data?["message"] as? String ?? ""
                let duration = data?["duration"] as? TimeInterval ?? 1.0
                if message != "" {
                    if "center" == position {
                        DispatchQueue.main.async {
                            self.controller?.view.makeToast(message, duration: duration, position: .center)
                        }
                    } else if "top" == position {
                        DispatchQueue.main.async {
                            self.controller?.view.makeToast(message, duration: duration, position: .top)
                        }
                    } else if "bottom" == position {
                        DispatchQueue.main.async {
                            self.controller?.view.makeToast(message, duration: duration, position: .bottom)
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.controller?.view.makeToast(message, duration: duration, position: .center)
                        }
                    }
                }
            case "playVoice":
                let resourceId = data?["resource_id"] as? String ?? "" // 图片的id
                let url = data?["url"] as? String ?? "" // 语音的链接
                
                if resourceId != "" {
                    print("get resource url and play voice")
                } else if url != "" {
                    print("just play voice by voice url")
                }
            case "openUrl":
                let newWindow = data?["new_window"] as? Bool ?? true // 是在本窗口跳转还是新开一个窗口访问新网址
                let url = data?["url"] as? String ?? ""
                let params = data?["params"] // 参数是一个复合对象[String:Any]
                if url != "" {
                    print("\(url) will be open , params \(params)")
                    // 判断是否需要打开一个新窗口
                    if newWindow {
                        let newWindow = ViewController()
                        newWindow.requestUrl = url
                        controller?.navigationController?.pushViewController(newWindow, animated: true)
                    } else {
                        print("open url in current page")
                    }
                    
                }
            default:
                print("no method found. \(methodName)")
            }
        } else {
            print("can not call a method without methodName")
        }
    }
    
    func rightBarButtonClick(sender: AnyObject) {
        print("share button clicked ")
        let alert = UIAlertController(title: "提示", message: "分享按钮被点击了", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "确定", style: .default, handler: { (action) in
            print("after alert action click")
        })
        alert.addAction(alertAction)
        // 一定要记得在主线程显示弹出框否则程序会crash
        DispatchQueue.main.async {
            self.controller?.present(alert, animated: true, completion: {
                print("afert alert")
            })
        }
        
    }
    
}
