//
//  UdacityConvenience.swift
//  OnTheMap
//
//  Created by Ivan Kodrnja on 19/07/15.
//  Copyright (c) 2015 Ivan Kodrnja. All rights reserved.
//

import Foundation
import UIKit

extension UdacityClient {
    
    // MARK: authentcation method
    func authenticateUser(email: String, password: String, completionHandler: (success: Bool, errorString: String?) -> Void){
        
        self.getSessionID(email, password: password) { (success, error) in
        
        // if getting session succeeded
        if success{
            completionHandler(success: success, errorString: nil)
        } else {
            completionHandler(success: success, errorString: error?.localizedDescription)
        }
        
        
        }
    }
    
    
    func getSessionID(email: String, password: String, completionHandler: (success: Bool, error: NSError?) -> Void) {
        
        /* 1. Set the parameters */
        // will be set in the POST request
        
        /* 2. Build the URL */
        let urlString = UdacityClient.Constants.baseSecureUrl + UdacityClient.Methods.SessionCreate
        let url = NSURL(string: urlString)!
        
        /* 3. Configure the request */
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            
            if let error = downloadError {
                // "The Internet connection appears to be offline." error can be reproduced with a real device, not with a simulator
                completionHandler(success: false, error: error)
                /*
                // THIS CODE WAS SET WHILE I WAS INVESTIGATING THE INTERNET CONNECTION ABSENCE ON THE SIMULATOR AND THE I REALIZED EVERYTHING WORKS FINE ON A REAL DEVICE
                if error.domain == NSURLErrorDomain && error.code == NSURLErrorNotConnectedToInternet {
                    completionHandler(success: false, error: error)
                } else {
                    println("error in client: \(error)")

                    completionHandler(success: false, error: NSError(domain: "getSessionID", code: 0, userInfo:
                }
                */
            } else {
                    /* 5. Parse the data */
                    /* subset response data! As per the spec, first 5 character should be skipped */
                    let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
                    
                    var parsingError: NSError? = nil
                    let parsedResult = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
                    
                    /* 6. Use the data! */
                    if let error = parsingError {
                        println("Parsing Error: \(error)")
                    } else {
                        if let sessionID = parsedResult.valueForKey(UdacityClient.JSONResponseKeys.Session)?.valueForKey(UdacityClient.JSONResponseKeys.Id) as? String {
                            
                            // assign user key to the userKey variable
                            UdacityClient.sharedInstance().userKey = parsedResult.valueForKey(UdacityClient.JSONResponseKeys.Account)?.valueForKey(UdacityClient.JSONResponseKeys.Key) as? String

                            
                            completionHandler(success: true, error: nil)
                        } else {
                            if let status = parsedResult.valueForKey(UdacityClient.JSONResponseKeys.Status) as? Int {
                                if status == 403 {
                                  //  completionHandler(success: false, error: "Invalid Email or Password")
                                    completionHandler(success: false, error: NSError(domain: "Parsed SessionID", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid Email or Password"]))
                                } else if status == 400 {
                                  //  completionHandler(success: false, error: "Post request failed. Try again later.")
                                    completionHandler(success: false, error: NSError(domain: "Parsed SessionID", code: 0, userInfo: [NSLocalizedDescriptionKey: "Post request failed. Try again later."]))
                                }
                            }
                        }
                    }
                }
            }
        /* 7. Start the request */
        task.resume()
   }
   
    func logout(completionHandler:(success: Bool, error: NSError?) -> Void) {
        /* 1. Set the parameters */
        // will be set in the DELETE request
        
        /* 2. Build the URL */
        let urlString = UdacityClient.Constants.baseSecureUrl + UdacityClient.Methods.SessionDelete
        let url = NSURL(string: urlString)!
        
        /* 3. Configure the request */
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "DELETE"
        
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies as! [NSHTTPCookie] {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.addValue(xsrfCookie.value!, forHTTPHeaderField: "X-XSRF-Token")
        }
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            if let error = error {
                completionHandler(success: false, error: error)

            } else {
                /* 5. Parse the data */
                /* subset response data! As per the spec, first 5 character should be skipped */
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
                
                var parsingError: NSError? = nil
                let parsedResult = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
               
                /* 6. Use the data! */
                if let error = parsingError {
                    println("Parsing Error: \(error)")
                } else {
                    if let sessionID = parsedResult.valueForKey(UdacityClient.JSONResponseKeys.Session)?.valueForKey(UdacityClient.JSONResponseKeys.Id) as? String {
                        completionHandler(success: true, error: nil)
                    } else {
                        completionHandler(success: false, error: error)
                        }
                    }
                }
                
                
            }
        
        /* 7. Start the request */
        task.resume()

    }
    
    func getPublicUserData(key: String, completionHandler: (success: Bool, error: NSError?) -> Void) {
        
        /* 1. Set the parameters */
        // there are no parameters
        var mutableMethod: String = UdacityClient.Methods.GetPublicUserData
        mutableMethod = UdacityClient.subtituteKeyInMethod(mutableMethod, key: UdacityClient.URLKeys.UserID, value: String(key))!
        
        /* 2. Build the URL */
        let urlString = UdacityClient.Constants.baseSecureUrl + mutableMethod
        let url = NSURL(string: urlString)!
        
        /* 3. Configure the request */
        let request = NSMutableURLRequest(URL: url)
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            
            if let error = downloadError {
                 completionHandler(success: false, error: error)

            } else {
                /* 5. Parse the data */
                /* subset response data! As per the spec, first 5 character should be skipped */
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
                
                var parsingError: NSError? = nil
                let parsedResult = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
                
                /* 6. Use the data! */
                if let error = parsingError {
                    println("Parsing Error: \(error)")
                } else {
                    if let user = parsedResult.valueForKey(UdacityClient.JSONResponseKeys.User) as? [String:AnyObject] {
                        
                        // populate publicUSerData variable
                        UdacityClient.sharedInstance().publicUserData = PublicUserData.publicUserData(user)

                        completionHandler(success: true, error: nil)
                    } else {
                        completionHandler(success: false, error: NSError(domain: "Public User Data", code: 0, userInfo: [NSLocalizedDescriptionKey: "Couldn't get public user data."]))
                    }
                }
            }
        }
        /* 7. Start the request */
        task.resume()
    }

}

