//
//  File.swift
//  
//
//  Created by Ajay Thakur on 11/06/24.
//

import Foundation

public class ISMAuthViewModel{
    
    public init() {}
    
    public  func loginWith(email : String, password : String,completion :@escaping (ISMErrorMessage?)->()){
        
        let endPoint = ISMCallAuthEndpoints.authenticate
        let request =  ISMCallAPIRequest(endPoint:endPoint , requestBody: ISMAuthRequest(userIdentifier: email, password : password))
        
        ISMCallAPIManager.sendRequest(request: request) {  (result : ISMResult<ISMCallAuth, ISMCallAPIError>) in
            switch result{
            case .success(let user,_) :
                ISMConfiguration.shared.setUserId(user.userId)
                ISMConfiguration.shared.setUserToken(user.userToken)
                ISMCallManager.shared.updatePushRegisteryToken()
                completion(nil)
            case .failure(_) :
                print("Error")
                completion(ISMErrorMessage(error: "Failed", errorCode: 412))
            }
        }
    
    }
    
}
