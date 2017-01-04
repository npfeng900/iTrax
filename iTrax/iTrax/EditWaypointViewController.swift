//
//  EditWaypointViewController.swift
//  iTrax
//
//  Created by Niu Panfeng on 03/01/2017.
//  Copyright © 2017 NaPaFeng. All rights reserved.
//

import UIKit
import MobileCoreServices

class EditWaypointViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
   
    // MARK: - Model
    var waypointToEdit: EditableWaypoint? { didSet{ updateUI() } }
    private func updateUI() {
        nameTextField?.text = waypointToEdit?.name
        infoTextField?.text = waypointToEdit?.info
        updateImage()
    }
    
    // MARK: - Outlet
    @IBOutlet weak var nameTextField: UITextField! { didSet{nameTextField.delegate = self } }
    @IBOutlet weak var infoTextField: UITextField! { didSet{infoTextField.delegate = self } }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Image
    var imageView: UIImageView = UIImageView() {
        didSet {
            imageView.contentMode = .ScaleAspectFill
        }
    }
    @IBOutlet weak var imageViewContainer: UIView! {
        didSet {
            imageViewContainer.addSubview(imageView)
        }
    }
    @IBAction func takePhoto() {
        let sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
        if let mediaType = UIImagePickerController.availableMediaTypesForSourceType(sourceType) {
            if UIImagePickerController.isSourceTypeAvailable(sourceType)  && mediaType.count > 0 {
                let picker = UIImagePickerController()
                picker.sourceType = sourceType
                picker.mediaTypes = mediaType
                picker.delegate = self
                picker.allowsEditing = true
                presentViewController(picker, animated: true, completion: nil)
            }
        }
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        /* ipad好像会自动Edit
        var image = info[UIImagePickerControllerEditedImage] as? UIImage
        if image == nil {
            image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }*/
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        imageView.image = image
        makeRoomForImage()
        dismissViewControllerAnimated(true, completion: nil)
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - ViewCotroller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        observeTextFields()
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        resignObserveTextFields()
    }
    @IBAction func done(sender: UIBarButtonItem) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - NSNotificationCenter
    var ntfObserver: NSObjectProtocol?
    var itfObserver: NSObjectProtocol?
    
    func observeTextFields() {
        let center = NSNotificationCenter.defaultCenter()
        let queue = NSOperationQueue.mainQueue()
        //name
        ntfObserver = center.addObserverForName(UITextFieldTextDidChangeNotification, object: nameTextField,queue: queue)
        { (notification) -> Void in
            if let waypoint = self.waypointToEdit {
                    waypoint.name = self.nameTextField.text
            }
        }
        //info
        itfObserver = center.addObserverForName(UITextFieldTextDidChangeNotification, object: infoTextField,queue: queue)
        { (notification) -> Void in
            if let waypoint = self.waypointToEdit {
                    waypoint.info = self.infoTextField.text
            }
        }
    }
    func resignObserveTextFields() {
        if let observer = ntfObserver {
            NSNotificationCenter.defaultCenter().removeObserver(observer)
        }
        if let observer = itfObserver {
            NSNotificationCenter.defaultCenter().removeObserver(observer)
        }
    }
   
}
// MARK: - Extension
extension EditWaypointViewController {
    //更新Image
    func updateImage() {
        if let url = waypointToEdit?.imageURL {
            //-----------------------------------------------------
            let queue = dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)
            dispatch_async(queue) { [weak self] in
                // 下载data
                if let imageData = NSData(contentsOfURL: url) {
                    // imageURL不变的情况，更新imageView
                    if url == self?.waypointToEdit?.imageURL {
                        if let image = UIImage(data: imageData) {
                            //-----------更新imageView--------------
                            dispatch_async(dispatch_get_main_queue()) {
                                self?.imageView.image = image
                                self?.makeRoomForImage() //可以写到属性观察期里
                            }
                            //-------------------------------------
                        }
                    }
                }
            }
            //-----------------------------------------------------
        }
    }
    //为Image计算EditWaypointViewController的preferredContentSize
    func makeRoomForImage() {
        var extraHeight: CGFloat = 0
        if imageView.image?.aspectRatio > 0 {
            if let width = imageView.superview?.frame.size.width {
                let height = width / imageView.image!.aspectRatio
                extraHeight = height - imageView.frame.height
                imageView.frame = CGRect(x: 0, y: 0, width: width, height: height)
            }
        } else {
            extraHeight = -imageView.frame.height
            imageView.frame = CGRectZero
        }
        
        imageViewContainer.frame.size = imageView.frame.size
        
        preferredContentSize = CGSize(width: preferredContentSize.width, height: preferredContentSize.height + extraHeight)
    }
}
extension UIImage {
    var aspectRatio: CGFloat {
        return size.height != 0 ? size.width / size.height : 0
    }
}

