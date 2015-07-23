//
//  InformationPostingViewController.swift
//  OnTheMap
//
//  Created by Ivan Kodrnja on 22/07/15.
//  Copyright (c) 2015 Ivan Kodrnja. All rights reserved.
//

import UIKit
import MapKit

class InformationPostingViewController: UIViewController {
    
    
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var findOnTheMapButton: UIButton!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var locationMapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var cancelWhiteButton: UIButton!
    
    
    
    var latitude: CLLocationDegrees?
    var longitude: CLLocationDegrees?
    
    var tapRecognizer: UITapGestureRecognizer? = nil
    var keyboardAdjusted = false
    var lastKeyboardOffset : CGFloat = 0.0
    
    var coords: CLLocationCoordinate2D?
    
     // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()
        
        /* Configure tap recognizer */
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.submitButton.hidden = true
        self.linkTextField.hidden = true
        self.locationMapView.hidden = true
        self.cancelWhiteButton.hidden = true
        
        self.addKeyboardDismissRecognizer()
        self.subscribeToKeyboardNotifications()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.removeKeyboardDismissRecognizer()
        self.unsubscribeToKeyboardNotifications()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Keyboard Fixes
    
    func addKeyboardDismissRecognizer() {
        self.view.addGestureRecognizer(tapRecognizer!)
    }
    
    func removeKeyboardDismissRecognizer() {
        self.view.removeGestureRecognizer(tapRecognizer!)
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if keyboardAdjusted == false {
            lastKeyboardOffset = getKeyboardHeight(notification) / 2
            self.view.superview?.frame.origin.y -= lastKeyboardOffset
            keyboardAdjusted = true
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        if keyboardAdjusted == true {
            self.view.superview?.frame.origin.y += lastKeyboardOffset
            keyboardAdjusted = false
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    
    // MARK: - Actions

    @IBAction func cancelAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }


    @IBAction func findOnTheMapAction(sender: AnyObject) {
        
        activityIndicator.startAnimating()
        self.view.alpha = 0.5
        
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(self.locationTextField.text) { (placemarks: [AnyObject]!, error: NSError!) in
            
            if error != nil {
                self.view.alpha = 1.0
                self.displayError("Could not Geocode the String.")
            } else {
                
                // hide and show UI elements appropriately
                self.findOnTheMapButton.hidden = true
                self.findOnTheMapButton.enabled = false
                self.locationTextField.hidden = true
                self.topLabel.hidden = true
                self.submitButton.hidden = false
                self.linkTextField.hidden = false
                self.locationMapView.hidden = false
                self.cancelButton.hidden = false
                self.cancelWhiteButton.hidden = false
                
                self.view.alpha = 1.0
                
                // create coordinates and annotation
                let placemark = placemarks[0] as! CLPlacemark
                let location = placemark.location
                self.coords = location.coordinate
                
                
                self.latitude = self.coords!.latitude
                self.longitude = self.coords!.longitude
                
                let coordinate = CLLocationCoordinate2D(latitude: self.latitude!, longitude: self.longitude!)
                
                var annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                
                // construct the visible area of the map based on the lat/lon
                let region = MKCoordinateRegionMakeWithDistance(coordinate, 100000, 100000)
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.activityIndicator.stopAnimating()
                    
                    self.locationMapView.addAnnotation(annotation)
                    self.locationMapView.setRegion(region, animated: true)
                    
                }
            }
            
        }
    }
    
    @IBAction func submitAction(sender: AnyObject) {
        
        self.activityIndicator.startAnimating()
        self.view.alpha = 0.5
        self.findOnTheMapButton.enabled = false
        
        // check if the link text field is empty
        if self.linkTextField.text.isEmpty {
            self.displayError("Must Enter a Link.")
        } else {
            // check if the entered url is valid
            if self.validateUrl(self.linkTextField.text) {
            
                // prevent the user for submitting twice
                self.submitButton.enabled = false
                
                // get public user data using the user key (we need first_name and last_name)
                UdacityClient.sharedInstance().getPublicUserData(UdacityClient.sharedInstance().userKey!) { (success, error) in
                    
                    
                    if success {
                        
                        var tempKey: String?
                        var tempFirstName: String?
                        var tempLastName: String?
                        
                        // get values from the PublicUserData struct, this data will be used as parameter in the posting function
                        for member in UdacityClient.sharedInstance().publicUserData {
                            tempKey = member.userKey!
                            tempFirstName = member.firstName!
                            tempLastName = member.lastName!
                        }
                        // post student location
                        ParseClient.sharedInstance().postStudentLocation(tempKey!, firstName: tempFirstName!, lastName: tempLastName!, mapString: self.locationTextField.text, mediaURL: self.linkTextField.text, latitude: self.latitude!, longitude: self.longitude!)  { (success, error) in
                            // student location has been posted
                            if success {
                                dispatch_async(dispatch_get_main_queue(), {
                                self.dismissViewControllerAnimated(true, completion: nil)
                                self.activityIndicator.stopAnimating()
                                self.view.alpha = 1.0
                                })

                            } else {
                                self.displayError(error?.localizedDescription)
                                dispatch_async(dispatch_get_main_queue(), {
                                    self.submitButton.enabled = true
                                })
                            }
                       
                        }
                        
                    } else {
                        self.displayError(error?.localizedDescription)
                        dispatch_async(dispatch_get_main_queue(), {
                            self.submitButton.enabled = true
                        })

                    }
                }
                
                
            } else {
                self.displayError("Invalid Link. Include http(s)://")
            }
        }
        
        
        
    }
    
    // MARK: - helpers
    
    func showAlertView(errorMessage: String?) {
        
        let alertController = UIAlertController(title: nil, message: errorMessage!, preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Dismiss", style: .Cancel) {(action) in
            
            
        }
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true){
            
        }
        
    }
    
    func displayError(errorString: String?) {
        dispatch_async(dispatch_get_main_queue(), {
            self.activityIndicator.stopAnimating()
            self.view.alpha = 1.0
            if let errorString = errorString {
                self.showAlertView(errorString)
            }
        })
    }
    
    // REGEX for validating entered url
    func validateUrl(url: String) -> Bool {
        let pattern = "^(https?:\\/\\/)([a-zA-Z0-9_\\-~]+\\.)+[a-zA-Z0-9_\\-~\\/\\.]+$"
        if let match = url.rangeOfString(pattern, options: .RegularExpressionSearch){
            return true
        }
        return false
    }
    
    
}
