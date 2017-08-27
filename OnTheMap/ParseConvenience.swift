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

    
    func getStudentLocations(_ locationsNumber: Int = 100, completionHandlerForGetLocations: @escaping (_ result: [StudentInformation]?, _ error: NSError?) -> Void) {
        
        /* 1. Set the parameters */
        let methodParameters = [ParseClient.ParameterKeys.Limit: locationsNumber]
        
        /* 2. Build the URL */
        let urlString = ParseClient.Constants.baseSecureUrl + ParseClient.escapedParameters(methodParameters as [String : AnyObject])
        let url = URL(string: urlString)!
        
        /* 3. Configure the request */
        let request = NSMutableURLRequest(url: url)
        request.addValue(ParseClient.Constants.ApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(ParseClient.Constants.APIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        /* 4. Make the request */
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGetLocations(nil, NSError(domain: "getStudentLocations", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                
                sendError("There was an error with your request: \(error!)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            

            /* 5. Parse the data */
            let parsedResult: [String:AnyObject]
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            /* 6. Use the data! */
            if let results = parsedResult[ParseClient.JSONResponseKeys.Results] as? [[String : AnyObject]] {
                
                let students = StudentInformation.studentsFromResults(results)
                
                completionHandlerForGetLocations(students, nil)
                
            } else {
                completionHandlerForGetLocations(nil, NSError(domain: "Results from Parse", code: 0, userInfo: [NSLocalizedDescriptionKey: "Download (server) error occured. Please retry."]))
            }
            
            
        }
        /* 7. Start the request */
        task.resume()
    }
    
    
    func createAnnotationsFromLocations(_ locations:[StudentInformation], completionHandler: (_ result: [MKPointAnnotation]?, _ error: NSError?) -> Void){
        
        
        if locations.isEmpty {
            
            completionHandler(nil, NSError(domain: "AnnotationParsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Couldn't create annotations."]))
            
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
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = "\(first) \(last)"
                annotation.subtitle = mediaURL
                
                // Finally we place the annotation in an array of annotations.
                annotations.append(annotation)
                
            }
            
            completionHandler(annotations, nil)
        }
    }
    
    
    func postStudentLocation(_ key: String, firstName: String, lastName:String, mapString: String, mediaURL: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees, completionHandlerForPostLocation: @escaping (_ success: Bool, _ error: NSError?) -> Void) {
        
        /* 1. Set the parameters */
        // will be set in the POST request
        
        /* 2. Build the URL */
        let urlString = ParseClient.Constants.baseSecureUrl
        let url = URL(string: urlString)!
        
        /* 3. Configure the request */
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(ParseClient.Constants.ApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(ParseClient.Constants.APIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(key)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}".data(using: String.Encoding.utf8)

        
        /* 4. Make the request */
        let task = session.dataTask(with: request as URLRequest)  { (data, response, error) in
            
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForPostLocation(false, NSError(domain: "postStudentLocation", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                
                sendError("There was an error with your request: \(error!)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }

            
            /* 5. Parse the data */
            let parsedResult: [String:AnyObject]
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            /* 6. Use the data! */
            if let _ = parsedResult[ParseClient.JSONResponseKeys.ObjID] as? String {
                
                completionHandlerForPostLocation(true, nil)
            } else {
                completionHandlerForPostLocation(false, NSError(domain: "PostStudentLocation", code: 0, userInfo: [NSLocalizedDescriptionKey: "Post request failed. Try again later."]))
            }
            
            
        }
        /* 7. Start the request */
        task.resume()
    }
    
    
    
}
