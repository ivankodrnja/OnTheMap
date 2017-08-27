//
//  PublicUserData.swift
//  OnTheMap
//
//  Created by Ivan Kodrnja on 23/07/15.
//  Copyright (c) 2015 Ivan Kodrnja. All rights reserved.
//



struct PublicUserData {
    
    var userKey: String?
    var firstName: String?
    var lastName: String?
    
    /* Construct a StudentInformation from a dictionary */
    init(dictionary: [String : AnyObject]) {
        
        userKey = dictionary[UdacityClient.JSONResponseKeys.Key] as? String
        firstName = dictionary[UdacityClient.JSONResponseKeys.FirstName] as? String
        lastName = dictionary[UdacityClient.JSONResponseKeys.LastName] as? String
        
    }
    
    /* Helper: Given a dictionary, convert it a PublicUserData objects */
    static func publicUserData(_ userData: [String : AnyObject]) -> [PublicUserData] {
        
        var user = [PublicUserData]()
        
        user.append(PublicUserData(dictionary: userData))
        
        return user
    }
    
}
