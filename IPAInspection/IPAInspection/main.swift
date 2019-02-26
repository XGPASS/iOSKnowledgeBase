//
//  main.swift
//  IPAInspection
//
//  Created by zhanghengyi on 2018/6/12.
//  Copyright © 2018 zhanghengyi. All rights reserved.
//

import Foundation
//http://download.zjssst.com/app/page/xysj.html
//http://admin.xayfyfej.com/app/good/case.html
//http://admin.xayfyfej.com/app/good/dba.html
//http://www.4001113900.com/dba.html


if CommandLine.arguments.count > 0 {
    //这里可以从arguments里面获取
    let downloadUrl = CommandLine.arguments[1];
    
    //这里使用了mock数据
    let downloadUrlMArray = ["http://download.zjssst.com/app/page/xysj.html",
//                             "http://admin.xayfyfej.com/app/good/case.html",
//                             "http://admin.xayfyfej.com/app/good/dba.html",
//                             "http://www.4001113900.com/dba.html"
    ]
    
    for htmlPath in downloadUrlMArray {
        let anotherQueue = DispatchQueue(label: htmlPath, qos: .utility, attributes: DispatchQueue.Attributes.concurrent, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.inherit, target: nil)
        anotherQueue.async {
            if let htmlStr = try? String.init(contentsOf: URL.init(string: htmlPath)!, encoding: String.Encoding.utf8)
            {
                let handlePlist = HandlePlist()
                handlePlist.analyseDownloadHtml(htmlStr)
            }
        }
    }
    
}

// Infinitely run the main loop to wait for our request.
// Only necessary if you are testing in the command line.
RunLoop.main.run()
