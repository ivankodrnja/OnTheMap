//
//  ParseConstants.swift
//  OnTheMap
//
//  Created by Ivan Kodrnja on 21/07/15.
//  Copyright (c) 2015 Ivan Kodrnja. All rights reserved.
//

extension ParseClient {
    
    // MARK: Constants
    
    struct Constants {
        
        static let ApplicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let APIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let baseSecureUrl: String = "https://api.parse.com/1/classes/StudentLocation"
    }
    

    struct ParameterKeys {
        
        static let Limit = "limit"
        
    }
    
    struct JSONResponseKeys {
        static let Results = "results"
        static let CreatedAt = "createdAt"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let ObjectID = "objectId"
        static let UniqueKey = "uniqueKey"
        static let UpdatedAt = "updatedAt"
        static let ObjID = "objectId"
    }
    
}