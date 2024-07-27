//
//  ISMLiveCallAPIManager.swift
//  ISMLiveCall
//
//  Created by Rahul Sharma on 12/09/23.
//

import Foundation
import SwiftyJSON
import UIKit


enum ISMHTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

struct APIError: Error {
    let message: String
}


protocol ISMURLConvertible{
    
    var baseURL : URL{
        get
    }
    var path : String{
        get
    }
    var method : ISMHTTPMethod{
        get
    }
    var queryParams : [String: String]?{
        get
    }
    var headers :[String: String]? {
        get
    }

    
}


extension ISMURLConvertible {
    func makeRequest() -> URLRequest? {
        var urlComponents = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = queryParams?.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        guard let url = urlComponents?.url else {
            return nil
        }
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // Set headers if provided
          headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        
        return request
    }
}



struct ISMCallAPIRequest<R> {
    let endPoint : ISMURLConvertible
    let requestBody: R?
}


struct ISMCallAPIManager {
    
    static func sendRequest<T: Codable, R:Any>(request: ISMCallAPIRequest<R>,showLoader:Bool = true, completion: @escaping (_ result : ISMResult<T, ISMCallAPIError>) -> Void) {
        
        if showLoader{
            DispatchQueue.main.async {
                ISMShowLoader.sharerd.startLoading()
            }
          
        }
        
        var urlComponents = URLComponents(url: request.endPoint.baseURL.appendingPathComponent(request.endPoint.path), resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = request.endPoint.queryParams?.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        guard let url = urlComponents?.url else {
            completion(.failure(.invalidResponse))
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.endPoint.method.rawValue
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        // Set headers if provided
        request.endPoint.headers?.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        
        if let requestBody = request.requestBody as? Codable {
            do {
                let jsonBody = try JSONEncoder().encode(requestBody)
                urlRequest.httpBody = jsonBody
            } catch {
                completion(.failure(.invalidResponse))
                DispatchQueue.main.async {
                    ISMShowLoader.sharerd.stopLoading()
                }
                return
            }
        }
        
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                DispatchQueue.main.async {
                    ISMShowLoader.sharerd.stopLoading()
                }
                return
            }
            if let error = error {
                completion(.failure(.decodingError(error)))
                return
            }
            
            
            guard let data = data else {
                completion(.failure(.invalidResponse))
                return
            }
            print(JSON(data))
            
            switch httpResponse.statusCode {
            case 200:
                do {
                    let responseObject = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(responseObject, nil))
                } catch {
                    completion(.failure(.decodingError(error)))
                }
            case 404:
                completion(.failure(.httpError(httpResponse.statusCode)))
               
            case 401, 406 :
                //handle the refresh token here.
               break
            default:
                /* For Alerts
                DispatchQueue.main.async {
                    do {
                        let errorMessage = try JSONDecoder().decode(ISMErrorMessage.self, from: data)
                        
                        if let topController =  ISMLiveKitCallUtil.topPresentedController(){
                            topController.showISMCallErrorAlerts(message: errorMessage.error ?? "We have got some error, please try again.")
                            
                        }
                        
                    } catch {
                        if let topController =  ISMLiveKitCallUtil.topPresentedController(){
                            topController.showISMCallErrorAlerts(message: "We have got some error, please try again.")
                            
                        }
                    }
                }
                */
                completion(.failure(.httpError(httpResponse.statusCode)))
            }
            
            if showLoader{
                DispatchQueue.main.async {
                    ISMShowLoader.sharerd.stopLoading()
                }
            }
        }
        
        task.resume()
    }
}


enum ISMCallAPIError: Error {
    case networkError(Error)
    case invalidResponse
    case decodingError(Error)
    case httpError(Int)
}


public struct ISMErrorMessage : Codable{
    public  let error : String?
    public  let errorCode : Int?
}

public enum ISMResult<T,ErrorData>{
    case success(T,Data?)
    case failure(ErrorData)
}






