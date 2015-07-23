//
//  ParseConvenience.swift
//  OnTheMap
//
//  Created by Ivan Kodrnja on 21/07/15.
//  Copyright (c) 2015 Ivan Kodrnja. All rights reserved.
//

import Foundation
import UIKit
import MapKit

extension ParseClient {

    
    func getStudentLocations(locationsNumber: Int = 100, completionHandler: (result: [StudentInformation]?, error: NSError?) -> Void) {
        
        /* 1. Set the parameters */
        let methodParameters = [ParseClient.ParameterKeys.Limit: locationsNumber]
        
        /* 2. Build the URL */
        let urlString = ParseClient.Constants.baseSecureUrl + ParseClient.escapedParameters(methodParameters)
        let url = NSURL(string: urlString)!
        
        /* 3. Configure the request */
        let request = NSMutableURLRequest(URL: url)
        request.addValue(ParseClient.Constants.ApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(ParseClient.Constants.APIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            
            if let error = downloadError {
             
                completionHandler(result: nil, error: error)
            } else {
                /* 5. Parse the data */
                var parsingError: NSError? = nil
                let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
                
                /* 6. Use the data! */
                if let error = parsingError {
                    println("Parsing Error: \(error)")
                } else {
                    if let results = parsedResult.valueForKey(ParseClient.JSONResponseKeys.Results) as? [[String : AnyObject]] {
                        
                        var students = StudentInformation.studentsFromResults(results)
                        
                        completionHandler(result: students, error: nil)
                        
                    } else {
                        completionHandler(result: nil, error: NSError(domain: "Results from Parse", code: 0, userInfo: [NSLocalizedDescriptionKey: "Download (server) error occured. Please retry."]))
                    }
                }
            }
        }
        /* 7. Start the request */
        task.resume()
    }
    
    
    func createAnnotationsFromLocations(locations:[StudentInformation], completionHandler: (result: [MKPointAnnotation]?, error: NSError?) -> Void){
        
        
        if locations.isEmpty {
            
            completionHandler(result: nil, error: NSError(domain: "AnnotationParsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Couldn't create annotations."]))
            
        } else {


            var annotations = [MKPointAnnotation]()
            
            for dictionary in locations {
                
                // Notice that the float values are being used to create CLLocationDegree values.
                // This is a version of the Double type.
                let lat = CLLocationDegrees(dictionary.latitude! as Double)
                let long = CLLocationDegrees(dictionary.longitude! as Double)
                
                // The lat and long are used to create a CLLocationCoordinates2D instance.
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                
                let first = dictionary.firstName! as String
                let last = dictionary.lastName! as String
                let mediaURL = dictionary.mediaUrl! as String
                
                // Here we create the annotation and set its coordiate, title, and subtitle properties
                var annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = "\(first) \(last)"
                annotation.subtitle = mediaURL
                
                // Finally we place the annotation in an array of annotations.
                annotations.append(annotation)
                
            }
            
            completionHandler(result: annotations, error: nil)
        }
    }
    
    
    func postStudentLocation(key: String, firstName: String, lastName:String, mapString: String, mediaURL: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees, completionHandler: (success: Bool, error: NSError?) -> Void) {
        
        /* 1. Set the parameters */
        // will be set in the POST request
        
        /* 2. Build the URL */
        let urlString = ParseClient.Constants.baseSecureUrl
        let url = NSURL(string: urlString)!
        
        /* 3. Configure the request */
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"uniqueKey\": \"\(key)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}".dataUsingEncoding(NSUTF8StringEncoding)

        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            
            if let error = downloadError {
                
                completionHandler(success: false, error: error)
            } else {
                /* 5. Parse the data */
                
                var parsingError: NSError? = nil
                let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
                
                /* 6. Use the data! */
                if let error = parsingError {
                    println("Parsing Error: \(error)")
                } else {
                    if let objectID = parsedResult.valueForKey(ParseClient.JSONResponseKeys.ObjID) as? String {
                        
                        completionHandler(success: true, error: nil)
                    } else {
                        completionHandler(success: false, error: NSError(domain: "PostStudentLocation", code: 0, userInfo: [NSLocalizedDescriptionKey: "Post request failed. Try again later."]))
                    }
                }
            }
        }
        /* 7. Start the request */
        task.resume()
    }
    
    
    
}
