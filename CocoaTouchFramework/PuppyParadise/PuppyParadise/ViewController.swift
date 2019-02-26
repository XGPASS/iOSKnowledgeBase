//
//  ViewController.swift
//  PuppyParadise
//
//  Created by Alec O'Connor on 10/10/17.
//  Copyright © 2017 Alec O'Connor. All rights reserved.
//

// Modified by Linyongzhi 04/25/18

import UIKit

class ViewController: UIViewController {

    @IBAction func saveTapped(_ sender: Any) {
        presentModalStatusView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private var statusViewClass :AnyClass?
    
    func presentModalStatusView() {
        if (loadFrameworkNamed(name: "")) {
            let viewClass = statusViewClass as! UIView.Type
            let modalView = viewClass.init(frame: self.view.bounds)
            
            if let plugin = modalView as? YZStatusProtocol {
                let downloadImage = UIImage(named: "download") ?? UIImage()
                
                plugin.setImage(downloadImage)
                plugin.setHeadline("Downloading")
            }
            view.addSubview(modalView)
        }
    }
    
    func loadFrameworkNamed(name: String) -> Bool {
       
        let paths:[String] = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        var documentDirectory :String = ""
        
        guard paths.count > 0 else {
            return false
        }
        
        documentDirectory = paths[0]
        
        let bundlePath = documentDirectory + "/YZModalStatus.framework"
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: bundlePath) {
            let bundle :Bundle? = Bundle(path: bundlePath)
            
            if let loadedBundle = bundle {
                
                if let tempClass = loadedBundle.principalClass {
                    statusViewClass = tempClass
                    return true
                }
            }
        }
        
        return false;
    }
}

