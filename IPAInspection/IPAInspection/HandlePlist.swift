//
//  HandlePlist.swift
//  IPAInspection
//
//  Created by zhanghengyi on 2018/6/12.
//  Copyright © 2018 zhanghengyi. All rights reserved.
//

import Foundation

class HandlePlist : NSObject, URLSessionDownloadDelegate {
    
    private var ipaName: String = ""
    
    func analyseDownloadHtml(_ htmlStr: String) {
        
        if htmlStr != nil {
            //起始符
            let beginStr = "itms-services://?action=download-manifest&url="
            
            let beginRange = htmlStr.range(of: beginStr)
            
            let backwardStr = htmlStr.suffix(from: beginRange!.upperBound)
            //结束符
            let endStr = "\");"
            
            let endRange = backwardStr.range(of: endStr)
            
            let plistStr = backwardStr.prefix(upTo: endRange!.lowerBound)
            
            if let plist = String(plistStr) as? String {
                analysePlist(plist)
            }
        }
    }
    
    func analysePlist(_ plistXMLUrlStr: String) {
        if let plistDict = NSDictionary.init(contentsOf: URL.init(string: plistXMLUrlStr)!) {
            if let items = plistDict["items"],
                let itemsArray = items as? Array<Any>,
                let infoDict = itemsArray[0] as? Dictionary<String, Any>
            {
                if let assets = infoDict["assets"] as? Array<Any>,
                    let packageDict = assets[0] as? Dictionary<String, Any>,
                    let ipaStr = packageDict["url"] as? String{
                    
                    sessionSimpleDownload(ipaStr)
                }
            }
        }
    }
    
    func sessionSimpleDownload(_ ipaUrl: String){
        
        print(ipaUrl)
        
        //下载地址
        let url = URL(string: ipaUrl)
        //请求
        let request = URLRequest(url: url!)
        
        ipaName = String(url!.lastPathComponent.split(separator: ".")[0])
        
        
        let config = URLSessionConfiguration.default
        
        let session = URLSession.init(configuration: config, delegate: self, delegateQueue: nil)
        
        
        //下载任务
//        let downloadTask = session.downloadTask(with: request,
//                                                completionHandler: {[unowned self] (location:URL?, response:URLResponse?, error:Error?)
//                                                    -> Void in
//        })
        
        let downloadTask = session.downloadTask(with: request)
        
        //使用resume方法启动任务
        downloadTask.resume()
    }
    
//    https://stackoverflow.com/questions/26971240/how-do-i-run-an-terminal-command-in-a-swift-script-e-g-xcodebuild
    func shell(_ args: String...) {
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = args
        task.launch()
        task.waitUntilExit()
//        return task.terminationStatus
        
    }
    
    func analyseMobileProvision(_ plistXMLUrlStr: String) {
        //加载data数据
        if let profileData = try? Data(contentsOf: URL.init(fileURLWithPath: plistXMLUrlStr)) {
            //parse
            if let profile = try? ProvisioningProfile.parse(from: profileData) {
                //使用
                print("appIdName: ", profile.appIdName)
                print("creationDate: ", profile.creationDate)
                print("expirationDate: ", profile.expirationDate)
                print("过期剩余时间: ", caculateExpireTime(profile.creationDate, profile.expirationDate))
            }
        }
    }
    
    func caculateExpireTime(_ creationDate: Date, _ expirationDate: Date) -> String {
        let currentCalendar = Calendar.current
        let flags = Set<Calendar.Component>([.year, .month, .day])

        let now = Date.init(timeIntervalSinceNow: 0)
        
        let leftDateComponents = currentCalendar.dateComponents(flags, from: now, to: expirationDate)
        
        let year = leftDateComponents.year!
        let month = leftDateComponents.month!
        let day = leftDateComponents.day!
        
        var leftDateStr = ""
        
        if year > 0 {
            if month > 0 {
                leftDateStr = String("\(year)年零\(month)个月")
            } else {
                leftDateStr = String("\(year)年")
            }
        } else if month > 0 {
            if day > 0 {
                leftDateStr = String("\(month)个月零\(day)天")
            } else {
                leftDateStr = String("\(month)个月")
            }
        } else {
            if day > 0 {
                leftDateStr = String("\(day)天")
            }
        }
        return leftDateStr
    }
    
    // MARK: - URLSessionDownloadDelegate
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        //location位置转换
        let locationPath = location.path
        //拷贝到用户目录
        let documents:String = NSHomeDirectory() + "/Documents/IPAInspection"
        
        let fileName = documents + "/" + ipaName
        
        let ipaPath = fileName + ".zip"
        
        //创建文件管理器
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: ipaPath) {
            try? fileManager.removeItem(atPath: ipaPath)
        } else {
            try? fileManager.createDirectory(atPath: documents, withIntermediateDirectories: true, attributes: nil)
        }
        
        if fileManager.fileExists(atPath: fileName + "/embedded.mobileprovision") {
            try? fileManager.removeItem(atPath: fileName + "/embedded.mobileprovision")
        }
        
        try! fileManager.moveItem(atPath: locationPath, toPath: ipaPath)
        
        
        //https://my.oschina.net/CandyMi/blog/688887 解压出单个文件
        //这里unzip和-j不能合并写为"unzip -j"
        
        print("");
        
        self.shell("unzip", "-j", ipaPath, "Payload/*.app/embedded.mobileprovision", "-d", fileName)
        
        self.analyseMobileProvision(fileName + "/embedded.mobileprovision")
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
//        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
//        print("\(Int(progress * 100))%", terminator: "")
        print("#", terminator: "")
    }
}
