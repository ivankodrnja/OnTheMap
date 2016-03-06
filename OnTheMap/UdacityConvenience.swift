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
    func authenticateUser(email: String, password: String, completionHandler: (success: Bool, error: NSError?) -> Void){
        
        self.getSessionID(email, password: password) { (success, error) in
        
        // if getting session succeeded
        if success{
            completionHandler(success: success, error: nil)
        } else {
            completionHandler(success: success, error: error)
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
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                
                completionHandler(success: false, error: error)
                print("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                    completionHandler(success: false, error: NSError(domain: "Session ID", code: 0, userInfo: [NSLocalizedDescriptionKey : "Your request returned an invalid response! Status code: \(response.statusCode)"]))
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                    completionHandler(success: false, error: NSError(domain: "Session ID", code: 0, userInfo: [NSLocalizedDescriptionKey : "\(response)"]))
                } else {
                    print("Your request returned an invalid response!")
                    completionHandler(success: false, error: NSError(domain: "Session ID", code: 0, userInfo: [NSLocalizedDescriptionKey : "\(response!)"]))
                }
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            /* 5. Parse the data */
            /* subset response data! As per the spec, first 5 character should be skipped */
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
            } catch {
                parsedResult = nil
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            if let _ = parsedResult.valueForKey(UdacityClient.JSONResponseKeys.Session)?.valueForKey(UdacityClient.JSONResponseKeys.Id) as? String {
                
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
        for cookie in sharedCookieStorage.cookies! as [NSHTTPCookie] {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.addValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-Token")
        }
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                
                completionHandler(success: false, error: error)
                print("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your request returned an invalid response!")
                }
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            
            /* 5. Parse the data */
            /* subset response data! As per the spec, first 5 character should be skipped */
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
            } catch {
                parsedResult = nil
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            /* 6. Use the data! */
            if let _ = parsedResult.valueForKey(UdacityClient.JSONResponseKeys.Session)?.valueForKey(UdacityClient.JSONResponseKeys.Id) as? String {
                completionHandler(success: true, error: nil)
            } else {
                completionHandler(success: false, error: error)
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
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                
                completionHandler(success: false, error: error)
                print("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your request returned an invalid response!")
                }
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            /* 5. Parse the data */
            /* subset response data! As per the spec, first 5 character should be skipped */
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
            } catch {
                parsedResult = nil
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
        
            /* 6. Use the data! */
            if let user = parsedResult.valueForKey(UdacityClient.JSONResponseKeys.User) as? [String:AnyObject] {
                
                // populate publicUSerData variable
                UdacityClient.sharedInstance().publicUserData = PublicUserData.publicUserData(user)

                completionHandler(success: true, error: nil)
            } else {
                completionHandler(success: false, error: NSError(domain: "Public User Data", code: 0, userInfo: [NSLocalizedDescriptionKey: "Couldn't get public user data."]))
            }
                
            
        }
        /* 7. Start the request */
        task.resume()
    }

}

