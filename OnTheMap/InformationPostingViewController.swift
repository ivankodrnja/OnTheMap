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
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(InformationPostingViewController.handleSingleTap(_:)))
        tapRecognizer?.numberOfTapsRequired = 1
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.submitButton.isHidden = true
        self.linkTextField.isHidden = true
        self.locationMapView.isHidden = true
        self.cancelWhiteButton.isHidden = true
        
        self.addKeyboardDismissRecognizer()
        self.subscribeToKeyboardNotifications()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
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
    
    @objc func handleSingleTap(_ recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(InformationPostingViewController.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(InformationPostingViewController.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        
        if keyboardAdjusted == false {
            lastKeyboardOffset = getKeyboardHeight(notification) / 2
            self.view.superview?.frame.origin.y -= lastKeyboardOffset
            keyboardAdjusted = true
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        
        if keyboardAdjusted == true {
            self.view.superview?.frame.origin.y += lastKeyboardOffset
            keyboardAdjusted = false
        }
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    
    // MARK: - Actions

    @IBAction func cancelAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
        
    }


    @IBAction func findOnTheMapAction(_ sender: AnyObject) {
        
        activityIndicator.startAnimating()
        self.view.alpha = 0.5
        
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(self.locationTextField.text!) { (placemarks, error) -> Void in
            
            if error != nil {
                self.view.alpha = 1.0
                self.displayError("Could not Geocode the String.")
            } else {
                
                // hide and show UI elements appropriately
                self.findOnTheMapButton.isHidden = true
                self.findOnTheMapButton.isEnabled = false
                self.locationTextField.isHidden = true
                self.topLabel.isHidden = true
                self.submitButton.isHidden = false
                self.linkTextField.isHidden = false
                self.locationMapView.isHidden = false
                self.cancelButton.isHidden = false
                self.cancelWhiteButton.isHidden = false
                
                self.view.alpha = 1.0
                
                // create coordinates and annotation
                let placemark = placemarks![0] 
                let location = placemark.location
                self.coords = location!.coordinate
                
                
                self.latitude = self.coords!.latitude
                self.longitude = self.coords!.longitude
                
                let coordinate = CLLocationCoordinate2D(latitude: self.latitude!, longitude: self.longitude!)
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                
                // construct the visible area of the map based on the lat/lon
                let region = MKCoordinateRegion.init(center: coordinate, latitudinalMeters: 100000, longitudinalMeters: 100000)
                
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    
                    self.locationMapView.addAnnotation(annotation)
                    self.locationMapView.setRegion(region, animated: true)
                    
                }
            }
            
        }
    }
    
    @IBAction func submitAction(_ sender: AnyObject) {
        
        self.activityIndicator.startAnimating()
        self.view.alpha = 0.5
        self.findOnTheMapButton.isEnabled = false
        
        // check if the link text field is empty
        if self.linkTextField.text!.isEmpty {
            self.displayError("Must Enter a Link.")
        } else {
            // check if the entered url is valid
            if self.validateUrl(self.linkTextField.text!) {
            
                // prevent the user for submitting twice
                self.submitButton.isEnabled = false
                
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
                        ParseClient.sharedInstance().postStudentLocation(tempKey!, firstName: tempFirstName!, lastName: tempLastName!, mapString: self.locationTextField.text!, mediaURL: self.linkTextField.text!, latitude: self.latitude!, longitude: self.longitude!)  { (success, error) in
                            // student location has been posted
                            if success {
                                DispatchQueue.main.async(execute: {
                                self.dismiss(animated: true, completion: nil)
                                self.activityIndicator.stopAnimating()
                                self.view.alpha = 1.0
                                })

                            } else {
                                self.displayError(error?.localizedDescription)
                                DispatchQueue.main.async(execute: {
                                    self.submitButton.isEnabled = true
                                })
                            }
                       
                        }
                        
                    } else {
                        self.displayError(error?.localizedDescription)
                        DispatchQueue.main.async(execute: {
                            self.submitButton.isEnabled = true
                        })

                    }
                }
                
                
            } else {
                self.displayError("Invalid Link. Include http(s)://")
            }
        }
        
        
        
    }
    
    // MARK: - helpers
    
    func showAlertView(_ errorMessage: String?) {
        
        let alertController = UIAlertController(title: nil, message: errorMessage!, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Dismiss", style: .cancel) {(action) in
            
            
        }
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true){
            
        }
        
    }
    
    func displayError(_ errorString: String?) {
        DispatchQueue.main.async(execute: {
            self.activityIndicator.stopAnimating()
            self.view.alpha = 1.0
            if let errorString = errorString {
                self.showAlertView(errorString)
            }
        })
    }
    
    // REGEX for validating entered url
    func validateUrl(_ url: String) -> Bool {
        let pattern = "^(https?:\\/\\/)([a-zA-Z0-9_\\-~]+\\.)+[a-zA-Z0-9_\\-~\\/\\.]+$"
        if let _ = url.range(of: pattern, options: .regularExpression){
            return true
        }
        return false
    }
    
    
}
