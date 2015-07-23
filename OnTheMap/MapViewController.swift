//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Ivan Kodrnja on 19/07/15.
//  Copyright (c) 2015 Ivan Kodrnja. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {


    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
   // MARK: - Initialization
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.parentViewController?.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: "logoutButtonTouchUp")
        
        var rightRefreshBarButtonItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "getStudentLocations")
        var rightInformationPostingButtonItem: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "Pin Icon"), style: UIBarButtonItemStyle.Plain, target: self, action: "postInformation")
        
        self.parentViewController?.navigationItem.setRightBarButtonItems([rightRefreshBarButtonItem, rightInformationPostingButtonItem], animated: true)
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.getStudentLocations()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayError(errorString: String?) {
        dispatch_async(dispatch_get_main_queue(), {
            self.activityIndicator.stopAnimating()
            
            if let errorString = errorString {
                self.showAlertView(errorString)
            }
        })
    }
    
    
    
    func logoutButtonTouchUp(){
        self.activityIndicator.startAnimating()
        
        UdacityClient.sharedInstance().logout(){ success, error in
            
            if success{
                self.activityIndicator.stopAnimating()
                
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                println(error)
            }
        }
        
        
    }
    
    func getStudentLocations(){
        activityIndicator.startAnimating()
        
        // get locations
        ParseClient.sharedInstance().getStudentLocations(){(result, error) in
            // proceeed if we got result from Parse API with student locations (information)
            ParseClient.sharedInstance().studentsDict = result!
            
            if error == nil {
                ParseClient.sharedInstance().createAnnotationsFromLocations(result!) { (result, error) in
                    
                    // proceed if we successfully created annotations
                    if error == nil {
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            self.activityIndicator.stopAnimating()
                            
                            self.mapView.addAnnotations(result!)
                        })
                    } else {
                        self.displayError(error?.localizedDescription)
                    }
                    
                }
                
            } else {
                self.displayError(error?.localizedDescription)
                
            }
        }
    }
    
    func postInformation(){
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("InformationPostingViewController") as! InformationPostingViewController 
        self.presentViewController(controller, animated: true, completion: nil)
        
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
    

    
    
    // MARK: - Map delegate methods
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        

        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .Red
            pinView!.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    // This delegate method opens the system browser to the URL specified in the annotationViews subtitle property.
    func mapView(mapView: MKMapView!, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == annotationView.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            app.openURL(NSURL(string: annotationView.annotation.subtitle!)!)
        }
    }

}

