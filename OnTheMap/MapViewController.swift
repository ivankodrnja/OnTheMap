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
        self.parent?.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(MapViewController.logoutButtonTouchUp))
        
        let rightRefreshBarButtonItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.refresh, target: self, action: #selector(MapViewController.getStudentLocations))
        let rightInformationPostingButtonItem: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "Pin Icon"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(MapViewController.postInformation))
        
        self.parent?.navigationItem.setRightBarButtonItems([rightRefreshBarButtonItem, rightInformationPostingButtonItem], animated: true)
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.getStudentLocations()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayError(_ errorString: String?) {
        DispatchQueue.main.async(execute: {
            self.activityIndicator.stopAnimating()
            
            if let errorString = errorString {
                self.showAlertView(errorString)
            }
        })
    }
    
    
    
    @objc func logoutButtonTouchUp(){
        self.activityIndicator.startAnimating()
        
        UdacityClient.sharedInstance().logout(){ success, error in
            
            if success{
                self.activityIndicator.stopAnimating()
                
                self.dismiss(animated: true, completion: nil)
            } else {
                print(error!)
            }
        }
        
        
    }
    
    @objc func getStudentLocations(){
        activityIndicator.startAnimating()
        
        // get locations
        ParseClient.sharedInstance().getStudentLocations(){(result, error) in
            // proceeed if we got result from Parse API with student locations (information)
            ParseClient.sharedInstance().studentsDict = result!
            
            if error == nil {
                ParseClient.sharedInstance().createAnnotationsFromLocations(result!) { (result, error) in
                    
                    // proceed if we successfully created annotations
                    if error == nil {
                        
                        DispatchQueue.main.async(execute: {
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
    
    @objc func postInformation(){
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "InformationPostingViewController") as! InformationPostingViewController 
        self.present(controller, animated: true, completion: nil)
        
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
    

    
    
    // MARK: - Map delegate methods
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        

        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    // This delegate method opens the system browser to the URL specified in the annotationViews subtitle property.
    func mapView(_ mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == annotationView.rightCalloutAccessoryView {
            let app = UIApplication.shared
            app.openURL(URL(string: annotationView.annotation!.subtitle!!)!)
        }
    }

}

