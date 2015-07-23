//
//  UdacityConstants.swift
//  OnTheMap
//
//  Created by Ivan Kodrnja on 19/07/15.
//  Copyright (c) 2015 Ivan Kodrnja. All rights reserved.
//

extension UdacityClient {
    
    // MARK: Constants
    
    struct Constants {
        
        static let signupUrl: String = "https://www.udacity.com/account/auth#!/signup"
        static let baseSecureUrl: String = "https://www.udacity.com/api/"
    }
    
    struct Methods {
        static let SessionCreate = "session"
        static let SessionDelete = "session"
        static let GetPublicUserData = "users/{user_id}"
    }
    
    struct URLKeys {
        static let UserID = "user_id"
    }
    
    struct JSONResponseKeys {
        static let Session = "session"
        static let Id = "id"
        static let Status = "status"
        static let Account = "account"
        static let Key = "key"
        static let User = "user"
        static let FirstName = "first_name"
        static let LastName = "last_name"
    }
    
}
