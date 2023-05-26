//
//  InstanceAPI.swift
//  
//
//  Created by 夏同光 on 2/24/23.
//

import Foundation

public struct Instance: Codable {
    public let id: String?
    public let location: String?
    public let instanceId: String?
    public let name: String?
    public let worldId: String?
    public let type: String?
    public let ownerId: String?
    public let tags: [String]?
    public let active: Bool?
    public let full: Bool?
    public let n_users: Int?
    public let capacity: Int?
    
//    public let platforms: Platform?
    public let secureName: String?
    public let shortName: String?
    
//    public let clientNumber: String?
    
    public let photonRegion: String?
    public let region: String?
    
    public let canRequestInvite: Bool?
    public let permanent: Bool?
    public let strict: Bool?
}

//
// MARK: Instance API
//

public struct InstanceAPI {
    
    static let instanceUrl = "\(baseUrl)/instances"

    public static func getInstance(client: APIClient, worldID: String, instanceID: String, completionHandler: @escaping @Sendable (Instance?) -> Void) {
        let url = URL(string: "\(instanceUrl)/\(worldID):\(instanceID)")!
        
        client.VRChatRequest(url: url,
                             httpMethod: "GET",
                             auth: true,
                             apiKey: true) { data, response, error in
            guard let data = data, error == nil else { return }

            let instance:Instance? = decode(data: data)
            
            completionHandler(instance)
        }
    }
}
