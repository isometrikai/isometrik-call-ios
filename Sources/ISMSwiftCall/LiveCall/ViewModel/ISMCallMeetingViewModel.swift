//
//  ISMCallMeetingViewModel.swift
//  ISMLiveCall
//
//  Created by Rahul Sharma on 13/09/23.
//

import Foundation

public class ISMCallMeetingViewModel{
    
    public init() {}
    
    public  func getMeetings(completion :@escaping ([ISMMeeting])->()){
        
        let request = ISMCallAPIRequest<Any>(endPoint: ISMCallMeetingEndpoints.getMeetings, requestBody: nil)
        
        ISMCallAPIManager.sendRequest(request: request) { (result : ISMResult<ISMMeetings,ISMCallAPIError>) in
            
            switch result{
            case .success(let meetings,_) :
                completion(meetings.meetings ?? [])
            case .failure(_) :
                completion([])
            }
            
            
        }
    
    }
    
    public  func createMeeting(memberIds:[String],conversationId : String? = nil, callType : ISMLiveCallType ,meetingDescription : String?, completion :@escaping (ISMMeeting)->()){
        
        let requestBody = ISMMeetingRequest(members: memberIds,meetingDescription : meetingDescription ?? "NA", deviceId: ISMDeviceId,customType: callType.rawValue, audioOnly: callType == .AudioCall, conversationId: conversationId)
        
        let request = ISMCallAPIRequest(endPoint: ISMCallMeetingEndpoints.createMeeting, requestBody: requestBody)
        
        ISMCallAPIManager.sendRequest(request: request) { (result : ISMResult<ISMMeeting,ISMCallAPIError>) in
            
            switch result{
            case .success(let rtcDetails,_) :
                completion(rtcDetails)
            case .failure(_) :
                print("Error")
            }
            
            
        }
    
    }
    
    public func rejectCall(meetingId : String,completion :@escaping (ISMMeeting)->()){
        
        let startPublishingRequest = ISMStartPublishingRequest(meetingId:meetingId , deviceId: ISMDeviceId)
        
        let request = ISMCallAPIRequest(endPoint: ISMCallMeetingEndpoints.rejectMeeting, requestBody: startPublishingRequest)
        
        ISMCallAPIManager.sendRequest(request: request) { (result : ISMResult<ISMMeeting,ISMCallAPIError>) in
            
            switch result{
            case .success(let rtcDetails,_) :
                completion(rtcDetails)
            case .failure(_) :
                print("Error")
            }
            
            
        }
    }
    
    public func accpetCall(meetingId : String,completion :@escaping (ISMMeeting)->(),failure : @escaping ()->()){
        
        let startPublishingRequest = ISMStartPublishingRequest(meetingId:meetingId , deviceId: ISMDeviceId)
        
        let request = ISMCallAPIRequest(endPoint: ISMCallMeetingEndpoints.accpetMeeting, requestBody: startPublishingRequest)
        
        ISMCallAPIManager.sendRequest(request: request) { (result : ISMResult<ISMMeeting,ISMCallAPIError>) in
            
            switch result{
            case .success(let rtcDetails,_) :
                completion(rtcDetails)
            case .failure(_) :
                failure()
            }
            
            
        }
    }
    
    
    public func startPublishing(meetingId : String,completion :@escaping (ISMMeeting)->()){
        
        let startPublishingRequest = ISMStartPublishingRequest(meetingId:meetingId , deviceId: ISMDeviceId)
        
        let request = ISMCallAPIRequest(endPoint: ISMCallMeetingEndpoints.startPublishing, requestBody: startPublishingRequest)
        
        ISMCallAPIManager.sendRequest(request: request) { (result : ISMResult<ISMMeeting,ISMCallAPIError>) in
            
            switch result{
            case .success(let rtcDetails,_) :
                completion(rtcDetails)
            case .failure(_) :
                print("Error")
            }
            
            
        }
    }
    
    public func fetchUsers(searchTag : String,completion :@escaping ([ISMCallUser])->()){

        let request = ISMCallAPIRequest<Any>(endPoint: ISMCallAuthEndpoints.fetchUsers(searchTag:searchTag ), requestBody: nil)
        
        ISMCallAPIManager.sendRequest(request: request) { (result : ISMResult<ISMCallUsers,ISMCallAPIError>) in
            
            switch result{
            case .success(let usersData,_) :
                completion(usersData.users)
            case .failure(_) :
                completion([])
            }
            
            
        }
    }

    public func leaveMeeting(meetingId : String,completion :@escaping ()->()){
     
        let request = ISMCallAPIRequest<Any>(endPoint: ISMCallMeetingEndpoints.leaveMeeting(meetingId: meetingId), requestBody: nil)
        
        ISMCallAPIManager.sendRequest(request: request) { (result : ISMResult<ISMCallMeetingLeft,ISMCallAPIError>) in
            
            switch result{
            case .success(_,_) :
                completion()
            case .failure(_) :
                print("Error")
                completion()
            }
            
            
        }
    }
    
    public func publishMessage(meetingId : String,message : String, completion :@escaping ()->()){
     
       let requestBody = ISMPublishMessage(deviceId: ISMDeviceId, meetingId: meetingId, messageType: "1", body: message)
        let request = ISMCallAPIRequest<Any>(endPoint: ISMCallMeetingEndpoints.publishMessage, requestBody: requestBody)
        
        ISMCallAPIManager.sendRequest(request: request) { (result : ISMResult<ISMCallMeetingLeft,ISMCallAPIError>) in
            
            switch result{
            case .success(_,_) :
                completion()
            case .failure(_) :
                print("Error")
            }
            
            
        }
    }
    
    
    
    public func updatePushRegisteryApnsToken(addApnsDeviceToken:Bool,apnsDeviceToken:String, completion :@escaping ()->()){
        
        let endPoint = ISMCallMeetingEndpoints.updateUser
         let request =  ISMCallAPIRequest(endPoint:endPoint , requestBody: ISMUpdateUserRequest(addApnsDeviceToken: addApnsDeviceToken, apnsDeviceToken: apnsDeviceToken))
        
        ISMCallAPIManager.sendRequest(request: request,showLoader: false) {  (result : ISMResult<ISMUpdateUser, ISMCallAPIError>) in
            switch result{
            case .success(let update,_) :
               print("APNSPushToken : \(update.msg ?? "token updated successfully")")
                completion()
            case .failure(_) :
                print("APNSPushToken : token update failed")
                completion()
            }
        }
    
    }
    
    
    /// fetch all memebers in meeting
    /// - Parameters:
    ///   - meetingId: meetingId
    ///   - completion: return the list
    public func fetchMembersInMeeting(meetingId : String,completion :@escaping ([ISMCallMember])->()){

        let request = ISMCallAPIRequest<Any>(endPoint: ISMCallMeetingEndpoints.fetchMembers(meetingId:meetingId ), requestBody: nil)
        
        ISMCallAPIManager.sendRequest(request: request) { (result : ISMResult<ISMMeetingMembers,ISMCallAPIError>) in
            
            switch result{
            case .success(let response,_) :
                completion(response.meetingMembers ?? [])
            case .failure(_) :
                completion([])
            }
            
            
        }
    }
    
}



