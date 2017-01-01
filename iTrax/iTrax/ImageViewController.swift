//
//  ImageViewController.swift
//  iCassini
//
//  Created by Niu Panfeng on 25/12/2016.
//  Copyright © 2016 NaPaFeng. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate, UIPopoverControllerDelegate {
    
    //imageURL -> update image
    var imageURL: NSURL? {
        didSet{
            image = nil
            //view在界面window中显示时update image
            if view.window != nil {
                fetchImage()
            }
        }
    }
    //update image
    private func fetchImage() {
        if let url = imageURL
        {
            spinner?.startAnimating()
            // 同步操作
            /*
            let imageData = NSData(contentsOfURL: url)
            if url == self.imageURL { //验证url是否是实时请求的imageURL，多线程问题
                if imageData != nil {
                    self.image = UIImage(data: imageData!)
                } else {
                    self.image = nil
                }
                
            }
            */
            // 异步操作
            let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
            dispatch_async(dispatch_get_global_queue(qos, 0)) { () -> Void in
                let imageData = NSData(contentsOfURL: url)
                dispatch_async(dispatch_get_main_queue()) {
                    if url == self.imageURL { //验证url是否是实时请求的imageURL，多线程问题
                        if imageData != nil {
                            self.image = UIImage(data: imageData!)
                        } else {
                            self.image = nil
                        }
                    }
                }
            }
        }
    }
    
    //image -> update imageView && scrollView
    private var image: UIImage? {
        get { return imageView.image }
        set {
            imageView.image = newValue
            imageView.sizeToFit() //imageView自适应Subview的尺寸
            scrollView?.contentSize = imageView.frame.size //scrollView的@IBOutlet可能为空
            scrollView?.contentOffset = CGPointZero
            spinner?.stopAnimating()
        }
    }
    /* scroll时显示contentOffset
    func scrollViewDidScroll(scrollView: UIScrollView) {
        print(scrollView.contentOffset)
    }*/
    //imageView
    private var imageView = UIImageView()
    
    //scrollView
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.contentSize = imageView.frame.size
            //缩放
            scrollView.delegate = self
            scrollView.minimumZoomScale = 0.2
            scrollView.maximumZoomScale = 3.0
        }
    }
    
    //spinner
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    //缩放
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    /** View Controll life cycle*/
    override func viewDidLoad() {
        super.viewDidLoad()
        //scrollView.scrollEnabled = false
        scrollView.addSubview(imageView)
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if image == nil {
            fetchImage()
        }
    }
}
