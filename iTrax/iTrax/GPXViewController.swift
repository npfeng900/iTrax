//
//  ViewController.swift
//  iTrax
//
//  Created by Niu Panfeng on 29/12/2016.
//  Copyright © 2016 NaPaFeng. All rights reserved.
//

import UIKit
import MapKit

class GPXViewController: UIViewController, MKMapViewDelegate, UIPopoverPresentationControllerDelegate {

    // MARK: - Notification
    // 消息观察者
    weak var nameObserver: NSObjectProtocol?
    /** 创建nameObserver,接收Notification（含有NSURL信息) */
    private func createObserver() -> NSObjectProtocol  {
        let center = NSNotificationCenter.defaultCenter()
        let appDelegate = UIApplication.sharedApplication().delegate
        let queue = NSOperationQueue.mainQueue()
        let notificationObserver = center.addObserverForName(GPXURL.NotificationName, object: appDelegate, queue: queue) { notification -> Void in
            if let url = notification.userInfo?[GPXURL.Key] as? NSURL {
                self.gpxURL = url
            }
        }
        return notificationObserver
    }
    /** 移除nameObserver */
    deinit {
        if let nameObserver = nameObserver {
            NSNotificationCenter.defaultCenter().removeObserver(nameObserver) // 那我们就把它释放掉好了
        }
    }
    
    // MARK: - ViewController Lifecycle
    /** 视图控制器生命周期：viewDidLoad */
    override func viewDidLoad() {
        super.viewDidLoad()
        nameObserver = createObserver()
    }
    
    
    // MARK: - MapView
    // 故事板接口mapView
    @IBOutlet weak var mapView: MKMapView! {
        didSet{
            mapView.mapType = .Standard //.Satellite
            mapView.delegate = self
        }
    }
    // URL链接
    var gpxURL: NSURL? {
        didSet {
            clearWaypoints()   //先清除
            if let url = gpxURL {
                GPX.parse(url) { (gpxParsed:GPX?) -> Void in
                    if let gpx = gpxParsed {
                        self.handleWaypoints(gpx.waypoints)
                    }
                }
            }
        }
    }
    
    
    // MARK: - Waypoints
    /** 清除Waypoints */
    private func clearWaypoints() {
        if mapView?.annotations != nil {
            mapView.removeAnnotations(mapView.annotations)
        }
    }
    /** 处理Waypoints */
    private func handleWaypoints(waypoints: [GPX.Waypoint]) {
        mapView.addAnnotations(waypoints)
        mapView.showAnnotations(waypoints, animated: true)
    }
    /** 添加Waypoints */
    @IBAction func addWaypoints(sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.Began {
            let coordinate = mapView.convertPoint(sender.locationInView(mapView), toCoordinateFromView: mapView)
            let waypoint = EditableWaypoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
            waypoint.name = "Dropped"
            mapView.addAnnotation(waypoint)
        }
    }
    
    
    // MARK: - MKMapViewDelegate
    // 常量
    private struct Constants {
        static let PartialTrackColor = UIColor.greenColor()
        static let FullTrackColor = UIColor.blackColor()
        static let TrackLineWidth: CGFloat = 3.0
        static let ZoomCooldown = 1.5
        static let LeftCalloutFrame = CGRect(x: 0, y: 0, width: 59, height: 59)
        static let AnnotationViewReuseIdentifier = "waypoints"
        static let ShowImageSegue = "Show Image"
        static let EditWaypointSegue = "Edit Waypoint"
        static let EditWaypointPopoverWidth: CGFloat = 320
    }
    /** 自定义MKAnnotationView */
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        // 默认的MKAnnotationView（如果不写，系统也会默认为你写上）
        var view = mapView.dequeueReusableAnnotationViewWithIdentifier(Constants.AnnotationViewReuseIdentifier)
        if view == nil {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: Constants.AnnotationViewReuseIdentifier)
            view?.canShowCallout = true
        } else {
            view?.annotation = annotation
        }
        
        view?.draggable = annotation is EditableWaypoint
        
        //先将CalloutAccessoryView置空，再赋值
        //leftCalloutAccessoryView,rightCalloutAccessoryView都是MKAnnotation的子视图
        view?.leftCalloutAccessoryView = nil
        view?.rightCalloutAccessoryView = nil
        if let waypoint = annotation as? GPX.Waypoint {
            if waypoint.thumbnailURL != nil {
                //leftCalloutAccessoryView在被点击选中之后加载图片，因为annotationView可能永远不会被用户点击
                view?.leftCalloutAccessoryView = UIButton(frame: Constants.LeftCalloutFrame)
            }
            if annotation is EditableWaypoint {
                view?.rightCalloutAccessoryView = UIButton(type: UIButtonType.DetailDisclosure) as UIButton
            }
        }
        
        return view
    }
    /** didSelectAnnotationView，加载leftCalloutAccessoryView */
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if let waypoint = view.annotation as? GPX.Waypoint { // MKAnnotationView->GPX.Waypoint
            if let thumbnailImageButton = view.leftCalloutAccessoryView as? UIButton {//UIView->UIButton
                if let imageData = NSData(contentsOfURL: waypoint.thumbnailURL!) {//获取imageData
                    if let image = UIImage(data: imageData) { //imageData->iamge
                        thumbnailImageButton.setImage(image, forState: .Normal)
                    }
                }
            }
        }
    }
    /** calloutAccessoryControlTapped，从CalloutAccessoryView跳转 */
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if (control as? UIButton)?.buttonType == UIButtonType.DetailDisclosure {
            mapView.deselectAnnotation(view.annotation, animated: false)
            performSegueWithIdentifier(Constants.EditWaypointSegue, sender: view)
        }
        else if let waypoint = view.annotation as? GPX.Waypoint {
            if waypoint.imageURL != nil {
                performSegueWithIdentifier(Constants.ShowImageSegue, sender: view)
            }
        }
    }
    /** prepareForSegue */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Constants.ShowImageSegue {
            if let waypoint = (sender as? MKAnnotationView)?.annotation as? GPX.Waypoint {
                if let ivc = segue.destinationViewController.contentViewController as? ImageViewController {
                    ivc.imageURL = waypoint.imageURL
                    ivc.title = waypoint.name
                }
            }
        }
        else if segue.identifier == Constants.EditWaypointSegue {
            if let waypoint = (sender as? MKAnnotationView)?.annotation as? EditableWaypoint {
                if let ewvc = segue.destinationViewController.contentViewController as? EditWaypointViewController {
                    if let ppc = ewvc.popoverPresentationController {
                        //ewvc
                        let minimuSize = ewvc.view.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
                        ewvc.preferredContentSize = CGSize(width: Constants.EditWaypointPopoverWidth, height: minimuSize.height)
                        //ppc
                        let coordinatePoint = mapView.convertCoordinate(waypoint.coordinate, toPointToView: mapView)       //waypoint坐标
                        ppc.sourceRect = (sender as! MKAnnotationView).popoverSourceRectForCoordinatePoint(coordinatePoint)//pop的view大小
                        ppc.delegate = self
                    }
                    ewvc.waypointToEdit = waypoint
                    ewvc.title = waypoint.name
                }
            }
        }
    }
    
    // MARK: - UIPopoverPresentationControllerDelegate
    /** UIModal的呈现样式 */
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.OverFullScreen
    }
    /** 增加容器视图控制器:UINavigationController */
    func presentationController(controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        // 容器视图控制器
        let navcon = UINavigationController(rootViewController: controller.presentedViewController)
        // 模糊效果
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
        visualEffectView.frame = navcon.view.bounds
        navcon.view.insertSubview(visualEffectView, atIndex: 0)
        return navcon
    }

}

// MARK: - Extension
extension UIViewController {
    var contentViewController: UIViewController {
        // 如果是UINavigationController，返回根视图控制器
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController!
        }
        // 如果非UINavigationController，返回自身
        else {
            return self
        }
    }
}
extension MKAnnotationView {
    func popoverSourceRectForCoordinatePoint(coorinatePoint: CGPoint) -> CGRect {
        var popoverSourceRectCenter = coorinatePoint
        popoverSourceRectCenter.x -= frame.width/2 - centerOffset.x - calloutOffset.x
        popoverSourceRectCenter.y -= frame.height/2 - centerOffset.y - calloutOffset.y
        return CGRect(origin: popoverSourceRectCenter, size: frame.size)
    }
}

