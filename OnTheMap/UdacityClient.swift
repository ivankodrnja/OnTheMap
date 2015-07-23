//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Ivan Kodrnja on 19/07/15.
//  Copyright (c) 2015 Ivan Kodrnja. All rights reserved.
//

import Foundation

class UdacityClient : NSObject {
    /* Shared Session */
    var session: NSURLSession
    
    // students dictionary that will be used for showing data in the list viewcontroller and mapviewcontroller
    var publicUserData = [PublicUserData]()
    
    // user key that is extracted from the POSTing a session
    var userKey: String?
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
 
    // MARK: - Helpers
    
    /* Helper: Substitute the key for the value that is contained within the method name */
    class func subtituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("{\(key)}") != nil {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> UdacityClient {
        
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        
        return Singleton.sharedInstance
    }
    
}