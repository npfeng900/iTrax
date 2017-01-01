//
//  AppDelegate.swift
//  iTrax
//
//  Created by Niu Panfeng on 29/12/2016.
//  Copyright © 2016 NaPaFeng. All rights reserved.
//

import UIKit

struct GPXURL {
    static let NotificationName = "GPXURL Radio Station"
    static let Key = "GPXURL URL Key"
    static let DefaultURL = NSURL(string: "http://web.stanford.edu/class/cs193p/Vacation.gpx")!
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    // AirDrop接受到文件（处理NSURL资源）时调用，true表示处理完毕
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        broadcastNotificationGPXURL(url)
        return true
    }

    // applicationDidBecomeActive
    func applicationDidBecomeActive(application: UIApplication) {

        /*
        let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
        dispatch_async(dispatch_get_global_queue(qos, 0)) {
            NSThread.sleepForTimeInterval(3)
            self.broadcastNotificationGPXURL(GPXURL.DefaultURL)
        }
        */
        
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(3 * NSEC_PER_SEC) )
        let queue = dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)
        dispatch_after(time, queue) {
            self.broadcastNotificationGPXURL(GPXURL.DefaultURL)
        }
    }
    
    // AppDelegate广播一个有NSURL信息的Notification
    private func broadcastNotificationGPXURL(url: NSURL) {
        let center = NSNotificationCenter.defaultCenter()
        let notification = NSNotification(name: GPXURL.NotificationName, object: self, userInfo: [GPXURL.Key : url ])
        center.postNotification(notification)
    }
    

    


}

