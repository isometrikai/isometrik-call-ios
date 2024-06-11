//
//  ISMCall+Type.swift
//  LiveKitCall
//
//  Created by Ajay Thakur on 11/04/24.
//

import Foundation
public enum ISMLiveCallType:String{
    case AudioCall
    case VideoCall
    case GroupCall
    
    
    
    public  var type : String{
        switch self{
        case .AudioCall :
            return "AudioCall"
        case .VideoCall :
            return "VideoCall"
        case .GroupCall :
            return "GroupCall"
        }
    }
    
}
