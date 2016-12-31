//
//  ViewController.swift
//  iTrax
//
//  Created by Niu Panfeng on 29/12/2016.
//  Copyright © 2016 NaPaFeng. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    weak var nameObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 创建一个Observer，接收Notification（含有NSURL信息）
        let center = NSNotificationCenter.defaultCenter()
        let queue = NSOperationQueue.mainQueue()
        let appDelegate = UIApplication.sharedApplication().delegate
        nameObserver = center.addObserverForName(GPXURL.NotificationRadioStationName, object: appDelegate, queue: queue) { notification -> Void in
            if let url = notification.userInfo?[GPXURL.Key] as? NSURL {
                self.textView.text = "Receive URL: \(url)"
            }
        }
        
    }
    /** 移除nameObserver */
    deinit {
        if let nameObserver = nameObserver {
            NSNotificationCenter.defaultCenter().removeObserver(nameObserver) // 那我们就把它释放掉好了
        }
    }
}

