//
//  File.swift
//  
//
//  Created by Ajay Thakur on 11/06/24.
//

import Foundation

public class ISMAuthViewModel{
    
    public init() {}
    
    public func loginWith(email : String, password : String,completion :@escaping (ISMCallAuth?)->(),failure:@escaping (ISMErrorMessage)->()){
        
        let endPoint = ISMCallAuthEndpoints.authenticate
        let request =  ISMCallAPIRequest(endPoint:endPoint , requestBody: ISMAuthRequest(userIdentifier: email, password : password))
        
        ISMCallAPIManager.sendRequest(request: request) {  (result : ISMResult<ISMCallAuth, ISMCallAPIError>) in
            switch result{
            case .success(let user,_) :
                completion(user)
            case .failure(let error) :
                print("Error")
                failure(ISMErrorMessage(error: "Failed", errorCode: 412))
            }
        }
    
    }
    
}
