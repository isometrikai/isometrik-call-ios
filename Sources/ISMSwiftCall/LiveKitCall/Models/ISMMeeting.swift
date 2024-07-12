//
//  ISMMeeting.swift
//  ISMLiveCall
//
//  Created by Rahul Sharma on 13/09/23.
//


import Foundation

// MARK: - Welcome
struct ISMMeetings: Codable {
    let msg: String?
    var meetings: [ISMMeeting]?
}

public struct ISMMeeting: Codable {
    public  var sentAt : Double?
    public var recordingUrl : String?
    public  var privateOneToOne : Bool?
    public   var missedByMembers : [String]?
    public  var messageId : String?
    public var meetingImageUrl : String?
    public var meetingId : String?
    public var meetingDescription : String?
    public  var initiatorName : String?
    public var initiatorImageUrl : String?
    public var initiatorIdentifier : String?
    public var initiatorId : String?
    public var deliveryReadEventsEnabled : Bool?
    public var deliveredToAll : Bool?
    public var conversationStatusMessage : Bool?
    public  var conversationId : String?
    public var callDurations : [ISMCallMeetingDuration]?
    public var action : String?
    public var adminCount : Int?
    public let members : [ISMCallMember]?
    public var enableRecording : Bool?
    public let customType: String?
    public let createdBy : String?
    public let creationTime: Int?
    public var audioOnly : Bool?
    public var active : Bool?
    public var autoTerminate : Bool?
    public var selfHosted : Bool?
    public var config : ISMCallConfig?
    public var hdMeeting : Bool?
    public let rtcToken : String?
    public let uid : Int?
    public  let userId : String?
    public let senderId: String?
    public let body: String?
    public let senderName : String?
    func callType() -> ISMLiveCallType{
        return ISMLiveCallType(rawValue: customType ?? "") ?? .AudioCall
    }
    
    public init(
        meetingId: String,
        sentAt: Double? = nil,
        recordingUrl: String? = nil,
        privateOneToOne: Bool? = nil,
        missedByMembers: [String]? = nil,
        messageId: String? = nil,
        meetingImageUrl: String? = nil,
        meetingDescription: String? = nil,
        initiatorName: String? = nil,
        initiatorImageUrl: String? = nil,
        initiatorIdentifier: String? = nil,
        initiatorId: String? = nil,
        deliveryReadEventsEnabled: Bool? = nil,
        deliveredToAll: Bool? = nil,
        conversationStatusMessage: Bool? = nil,
        conversationId: String? = nil,
        callDurations: [ISMCallMeetingDuration]? = nil,
        action: String? = nil,
        adminCount: Int? = nil,
        members: [ISMCallMember]? = nil,
        enableRecording: Bool? = nil,
        customType: String? = nil,
        createdBy: String? = nil,
        creationTime: Int? = nil,
        audioOnly: Bool? = nil,
        active: Bool? = nil,
        autoTerminate: Bool? = nil,
        selfHosted: Bool? = nil,
        config: ISMCallConfig? = nil,
        hdMeeting: Bool? = nil,
        rtcToken: String? = nil,
        uid: Int? = nil,
        userId: String? = nil,
        senderId: String? = nil,
        body: String? = nil,
        senderName: String? = nil
    ) {
        self.meetingId = meetingId
        self.sentAt = sentAt
        self.recordingUrl = recordingUrl
        self.privateOneToOne = privateOneToOne
        self.missedByMembers = missedByMembers
        self.messageId = messageId
        self.meetingImageUrl = meetingImageUrl
        self.meetingDescription = meetingDescription
        self.initiatorName = initiatorName
        self.initiatorImageUrl = initiatorImageUrl
        self.initiatorIdentifier = initiatorIdentifier
        self.initiatorId = initiatorId
        self.deliveryReadEventsEnabled = deliveryReadEventsEnabled
        self.deliveredToAll = deliveredToAll
        self.conversationStatusMessage = conversationStatusMessage
        self.conversationId = conversationId
        self.callDurations = callDurations
        self.action = action
        self.adminCount = adminCount
        self.members = members
        self.enableRecording = enableRecording
        self.customType = customType
        self.createdBy = createdBy
        self.creationTime = creationTime
        self.audioOnly = audioOnly
        self.active = active
        self.autoTerminate = autoTerminate
        self.selfHosted = selfHosted
        self.config = config
        self.hdMeeting = hdMeeting
        self.rtcToken = rtcToken
        self.uid = uid
        self.userId = userId
        self.senderId = senderId
        self.body = body
        self.senderName = senderName
    }
}


public struct ISMCallMeetingDuration : Codable{
    public   var memberId : String?
    public   var durationInMilliseconds : Double?
    public  init(memberId: String? = nil, durationInMilliseconds: Double? = nil) {
        self.memberId = memberId
        self.durationInMilliseconds = durationInMilliseconds
    }
}
public struct ISMCallConfig: Codable {
    public let pushNotifications: Bool
}





// MARK: - Config
struct Config: Codable {
    let pushNotifications: Bool
}

// MARK: - MetaData
struct MetaData: Codable {
    let openMeeting: Bool
    
    enum CodingKeys: String, CodingKey {
        case openMeeting = "open meeting"
    }
}

// MARK: - Encode/decode helpers

class JSONNull: Codable {
    
    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }
    
    public init() {}
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}

class JSONCodingKey: CodingKey {
    let key: String
    
    required init?(intValue: Int) {
        return nil
    }
    
    required init?(stringValue: String) {
        key = stringValue
    }
    
    var intValue: Int? {
        return nil
    }
    
    var stringValue: String {
        return key
    }
}

class JSONAny: Codable {
    
    let value: Any
    
    static func decodingError(forCodingPath codingPath: [CodingKey]) -> DecodingError {
        let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Cannot decode JSONAny")
        return DecodingError.typeMismatch(JSONAny.self, context)
    }
    
    static func encodingError(forValue value: Any, codingPath: [CodingKey]) -> EncodingError {
        let context = EncodingError.Context(codingPath: codingPath, debugDescription: "Cannot encode JSONAny")
        return EncodingError.invalidValue(value, context)
    }
    
    static func decode(from container: SingleValueDecodingContainer) throws -> Any {
        if let value = try? container.decode(Bool.self) {
            return value
        }
        if let value = try? container.decode(Int64.self) {
            return value
        }
        if let value = try? container.decode(Double.self) {
            return value
        }
        if let value = try? container.decode(String.self) {
            return value
        }
        if container.decodeNil() {
            return JSONNull()
        }
        throw decodingError(forCodingPath: container.codingPath)
    }
    
    static func decode(from container: inout UnkeyedDecodingContainer) throws -> Any {
        if let value = try? container.decode(Bool.self) {
            return value
        }
        if let value = try? container.decode(Int64.self) {
            return value
        }
        if let value = try? container.decode(Double.self) {
            return value
        }
        if let value = try? container.decode(String.self) {
            return value
        }
        if let value = try? container.decodeNil() {
            if value {
                return JSONNull()
            }
        }
        if var container = try? container.nestedUnkeyedContainer() {
            return try decodeArray(from: &container)
        }
        if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self) {
            return try decodeDictionary(from: &container)
        }
        throw decodingError(forCodingPath: container.codingPath)
    }
    
    static func decode(from container: inout KeyedDecodingContainer<JSONCodingKey>, forKey key: JSONCodingKey) throws -> Any {
        if let value = try? container.decode(Bool.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(Int64.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(Double.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(String.self, forKey: key) {
            return value
        }
        if let value = try? container.decodeNil(forKey: key) {
            if value {
                return JSONNull()
            }
        }
        if var container = try? container.nestedUnkeyedContainer(forKey: key) {
            return try decodeArray(from: &container)
        }
        if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key) {
            return try decodeDictionary(from: &container)
        }
        throw decodingError(forCodingPath: container.codingPath)
    }
    
    static func decodeArray(from container: inout UnkeyedDecodingContainer) throws -> [Any] {
        var arr: [Any] = []
        while !container.isAtEnd {
            let value = try decode(from: &container)
            arr.append(value)
        }
        return arr
    }
    
    static func decodeDictionary(from container: inout KeyedDecodingContainer<JSONCodingKey>) throws -> [String: Any] {
        var dict = [String: Any]()
        for key in container.allKeys {
            let value = try decode(from: &container, forKey: key)
            dict[key.stringValue] = value
        }
        return dict
    }
    
    static func encode(to container: inout UnkeyedEncodingContainer, array: [Any]) throws {
        for value in array {
            if let value = value as? Bool {
                try container.encode(value)
            } else if let value = value as? Int64 {
                try container.encode(value)
            } else if let value = value as? Double {
                try container.encode(value)
            } else if let value = value as? String {
                try container.encode(value)
            } else if value is JSONNull {
                try container.encodeNil()
            } else if let value = value as? [Any] {
                var container = container.nestedUnkeyedContainer()
                try encode(to: &container, array: value)
            } else if let value = value as? [String: Any] {
                var container = container.nestedContainer(keyedBy: JSONCodingKey.self)
                try encode(to: &container, dictionary: value)
            } else {
                throw encodingError(forValue: value, codingPath: container.codingPath)
            }
        }
    }
    
    static func encode(to container: inout KeyedEncodingContainer<JSONCodingKey>, dictionary: [String: Any]) throws {
        for (key, value) in dictionary {
            let key = JSONCodingKey(stringValue: key)!
            if let value = value as? Bool {
                try container.encode(value, forKey: key)
            } else if let value = value as? Int64 {
                try container.encode(value, forKey: key)
            } else if let value = value as? Double {
                try container.encode(value, forKey: key)
            } else if let value = value as? String {
                try container.encode(value, forKey: key)
            } else if value is JSONNull {
                try container.encodeNil(forKey: key)
            } else if let value = value as? [Any] {
                var container = container.nestedUnkeyedContainer(forKey: key)
                try encode(to: &container, array: value)
            } else if let value = value as? [String: Any] {
                var container = container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key)
                try encode(to: &container, dictionary: value)
            } else {
                throw encodingError(forValue: value, codingPath: container.codingPath)
            }
        }
    }
    
    static func encode(to container: inout SingleValueEncodingContainer, value: Any) throws {
        if let value = value as? Bool {
            try container.encode(value)
        } else if let value = value as? Int64 {
            try container.encode(value)
        } else if let value = value as? Double {
            try container.encode(value)
        } else if let value = value as? String {
            try container.encode(value)
        } else if value is JSONNull {
            try container.encodeNil()
        } else {
            throw encodingError(forValue: value, codingPath: container.codingPath)
        }
    }
    
    public required init(from decoder: Decoder) throws {
        if var arrayContainer = try? decoder.unkeyedContainer() {
            self.value = try JSONAny.decodeArray(from: &arrayContainer)
        } else if var container = try? decoder.container(keyedBy: JSONCodingKey.self) {
            self.value = try JSONAny.decodeDictionary(from: &container)
        } else {
            let container = try decoder.singleValueContainer()
            self.value = try JSONAny.decode(from: container)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        if let arr = self.value as? [Any] {
            var container = encoder.unkeyedContainer()
            try JSONAny.encode(to: &container, array: arr)
        } else if let dict = self.value as? [String: Any] {
            var container = encoder.container(keyedBy: JSONCodingKey.self)
            try JSONAny.encode(to: &container, dictionary: dict)
        } else {
            var container = encoder.singleValueContainer()
            try JSONAny.encode(to: &container, value: self.value)
        }
    }
}



struct ISMCallMeetingLeft : Codable{
    let membersCount : Int?
    let error : String?
}


