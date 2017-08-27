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
    func authenticateUser(_ email: String, password: String, completionHandler: @escaping (_ success: Bool, _ error: NSError?) -> Void){
        
        self.getSessionID(email, password: password) { (success, error) in
        
        // if getting session succeeded
        if success{
            completionHandler(success, nil)
        } else {
            completionHandler(success, error)
        }
        
        }
    }
    
    
    func getSessionID(_ email: String, password: String, completionHandlerForGetSession: @escaping (_ success: Bool, _ error: NSError?) -> Void) {
        
        /* 1. Set the parameters */
        // will be set in the POST request
        
        /* 2. Build the URL */
        let urlString = UdacityClient.Constants.baseSecureUrl + UdacityClient.Methods.SessionCreate
        let url = URL(string: urlString)!
        
        /* 3. Configure the request */
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}".data(using: String.Encoding.utf8)
        
        /* 4. Make the request */
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGetSession(false, NSError(domain: "getSessionID", code: 1, userInfo: userInfo))
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
            /* subset response data! As per the spec, first 5 character should be skipped */
            //let newData = data.subdata(in: Range(5, data.count - 5))
            let range = Range(5..<data.count)
            
            let newData = data.subdata(in: range)
            
            let parsedResult: [String:AnyObject]
            do {
                parsedResult = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as! [String:AnyObject]
            } catch {
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            if let _ = parsedResult[UdacityClient.JSONResponseKeys.Session]?.value(forKey: UdacityClient.JSONResponseKeys.Id) as? String {
                
                // assign user key to the userKey variable
                UdacityClient.sharedInstance().userKey = parsedResult[UdacityClient.JSONResponseKeys.Account]?.value(forKey: UdacityClient.JSONResponseKeys.Key) as? String

                
                completionHandlerForGetSession(true, nil)
            } else {
                if let status = parsedResult[UdacityClient.JSONResponseKeys.Status] as? Int {
                    if status == 403 {
                        completionHandlerForGetSession(false, NSError(domain: "Parsed SessionID", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid Email or Password"]))
                    } else if status == 400 {
                        completionHandlerForGetSession(false, NSError(domain: "Parsed SessionID", code: 0, userInfo: [NSLocalizedDescriptionKey: "Post request failed. Try again later."]))
                    }
                }
            }
            
            
            }
        /* 7. Start the request */
        task.resume()
   }
   
    func logout(_ completionHandlerForLogout:@escaping (_ success: Bool, _ error: NSError?) -> Void) {
        /* 1. Set the parameters */
        // will be set in the DELETE request
        
        /* 2. Build the URL */
        let urlString = UdacityClient.Constants.baseSecureUrl + UdacityClient.Methods.SessionDelete
        let url = URL(string: urlString)!
        
        /* 3. Configure the request */
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "DELETE"
        
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! as [HTTPCookie] {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.addValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-Token")
        }
        
        /* 4. Make the request */
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForLogout(false, NSError(domain: "logout", code: 1, userInfo: userInfo))
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
            /* subset response data! As per the spec, first 5 character should be skipped */
            //let newData = data.subdata(with: NSMakeRange(5, data.count - 5))
            
            let range = Range(5..<data.count)
            
            let newData = data.subdata(in: range)
            
            let parsedResult: [String:AnyObject]
            do {
                parsedResult = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as! [String:AnyObject]
            } catch {

                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            /* 6. Use the data! */
            if let _ = parsedResult[UdacityClient.JSONResponseKeys.Session]?.value(forKey: UdacityClient.JSONResponseKeys.Id) as? String {
                DispatchQueue.main.async {
                    completionHandlerForLogout(true, nil)
                }
            } else {
                completionHandlerForLogout(false, NSError(domain: "Logout", code: 0, userInfo: [NSLocalizedDescriptionKey: "Couldn't logout."]))
                }
                
            }
        
        /* 7. Start the request */
        task.resume()

    }
    
    func getPublicUserData(_ key: String, completionHandlerForPublicUserData: @escaping (_ success: Bool, _ error: NSError?) -> Void) {
        
        /* 1. Set the parameters */
        // there are no parameters
        var mutableMethod: String = UdacityClient.Methods.GetPublicUserData
        mutableMethod = UdacityClient.subtituteKeyInMethod(mutableMethod, key: UdacityClient.URLKeys.UserID, value: String(key))!
        
        /* 2. Build the URL */
        let urlString = UdacityClient.Constants.baseSecureUrl + mutableMethod
        let url = URL(string: urlString)!
        
        /* 3. Configure the request */
        let request = NSMutableURLRequest(url: url)
        
        /* 4. Make the request */
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForPublicUserData(false, NSError(domain: "getPublicUserData", code: 1, userInfo: userInfo))
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
            /* subset response data! As per the spec, first 5 character should be skipped */
            //let newData = data.subdata(with: NSMakeRange(5, data.count - 5))
            
            let range = Range(5..<data.count)
            
            let newData = data.subdata(in: range)
            
            let parsedResult: [String:AnyObject]
            do {
                parsedResult = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as! [String:AnyObject]
            } catch {
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
        
            /* 6. Use the data! */
            if let user = parsedResult[UdacityClient.JSONResponseKeys.User] as? [String:AnyObject] {
                
                // populate publicUSerData variable
                UdacityClient.sharedInstance().publicUserData = PublicUserData.publicUserData(user)

                completionHandlerForPublicUserData(true, nil)
            } else {
                completionHandlerForPublicUserData(false, NSError(domain: "Public User Data", code: 0, userInfo: [NSLocalizedDescriptionKey: "Couldn't get public user data."]))
            }
                
            
        }
        /* 7. Start the request */
        task.resume()
    }

}

