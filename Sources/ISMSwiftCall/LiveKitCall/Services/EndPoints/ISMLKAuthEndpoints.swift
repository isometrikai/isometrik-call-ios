//
//  Auth.swift
//  ISMLiveCall
//
//  Created by Rahul Sharma on 12/09/23.
//

import Foundation

enum ISMCallAuthEndpoints : ISMURLConvertible {
    
    case authenticate
    case fetchUsers(searchTag:String,skip:Int = 0, limit : Int = 10)
    
    var baseURL: URL {
        return URL(string:"https://apis.isometrik.io")!
    }
    
    var path: String {
        switch self {
        case .authenticate:
            return "/streaming/v2/user/authenticate"
        case .fetchUsers:
            return "/streaming/v2/users"
        }
    }
    
    var method: ISMHTTPMethod {
        switch self {
        case .authenticate:
            return .post
        case .fetchUsers:
            return  .get
        }
    }
    
    var queryParams: [String: String]? {
        switch self {
        case .fetchUsers(let searchTags, let skip, let limit):
            var params : [String : String] = [
                         "skip" : "\(skip)",
                         "limit" : "\(limit)"
            ]
            if !searchTags.isEmpty{
                params.updateValue(searchTags, forKey: "searchTag")
            }
            return params
            
        case .authenticate:
            return nil

        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .authenticate,.fetchUsers:
            return ["appSecret":ISMConfiguration.getAppSecret(),
                    "userSecret" : ISMConfiguration.getUserSecret() ,
                    "licenseKey" : ISMConfiguration.getLicenseKey()
            ]
            
        }
    }
  
    
}






