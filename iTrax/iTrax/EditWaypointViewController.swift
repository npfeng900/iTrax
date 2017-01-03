//
//  EditWaypointViewController.swift
//  iTrax
//
//  Created by Niu Panfeng on 03/01/2017.
//  Copyright © 2017 NaPaFeng. All rights reserved.
//

import UIKit

class EditWaypointViewController: UIViewController, UITextFieldDelegate {
   
    // MARK: - Model
    var waypointToEdit: EditableWaypoint? { didSet{ updateUI() } }
    
    // MARK: - Outlet
    @IBOutlet weak var nameTextField: UITextField! { didSet{nameTextField.delegate = self } }
    @IBOutlet weak var infoTextField: UITextField! { didSet{infoTextField.delegate = self } }
    
    private func updateUI() {
        nameTextField?.text = waypointToEdit?.name
        infoTextField?.text = waypointToEdit?.info
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
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
   
}
