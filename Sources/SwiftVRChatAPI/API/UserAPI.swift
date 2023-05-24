//
//  File.swift
//  
//
//  Created by 夏同光 on 2/23/23.
//

import Foundation

public struct User: Codable {
    
    public let requiresTwoFactorAuth: [String]?
    
    public struct errorMessage: Codable {
        public let message: String?
        public let status_code: Int?
    }
    public let error: errorMessage?
    
    public let id: String?
    public let displayName: String?
    public let userIcon: String?
    public let bio: String?
    public let bioLinks: [String]?
    public let statusDescription: String?
    public let username: String?

//    public let pastDisplayName

    public let friends: [String]?

    public let currentAvatar: String?
    public let currentAvatarThumbnailImageUrl: String?
    
    public let currentAvatarAssetUrl: String?
    public let currentAvatarImageUrl: String?
    

    public let state: String?
    
    public let tags: [String]?
    
    public let status: String?
    public let worldId: String?
    public let instanceId: String?
    public let location: String?
    public let travelingToWorld: String?
    public let travelingToInstance: String?
    public let travelingToLocation: String?

    public let onlineFriends: [String]?
    public let activeFriends: [String]?
    public let offlineFriends: [String]?
    
}

let userUrl = "\(baseUrl)/users"

//
// MARK: User API
//

@available(iOS 15.0, *)
public struct UserAPIAsync {
    
    public static func updateUserTags(client: APIClientAsync, userID: String, tags: [String]) async -> User? {
        let httpBody = try! JSONSerialization.data(withJSONObject: ["tags": tags])
        
        return await updateUser(client: client, userID: userID, httpBody: httpBody)
    }
    
    public static func updateUser(client: APIClientAsync, userID: String, httpBody: Data) async -> User? {
        let url = URL(string: "\(userUrl)/\(userID)")!
        
        let (data, _) = await client.VRChatRequest(url: url,
                                                   httpMethod: "PUT",
                                                   auth: true,
                                                   apiKey: true,
                                                   contentType: "application/json",
                                                   httpBody: httpBody)
        
        guard let data = data else { return nil }
        
        let user:User? = decode(data: data)
        
        return user
    }
}

public struct UserAPI {

    public static func getUser(client: APIClient, userID: String, completionHandler: @escaping @Sendable (User?) -> Void) {
        let url = URL(string: "\(userUrl)/\(userID)")!
        
        client.VRChatRequest(url: url,
                             httpMethod: "GET",
                             auth: true,
                             apiKey: true) { data, response, error in
            guard let data = data, error == nil else { return }

            let user:User? = decode(data: data)
            
            completionHandler(user)
        }
    }
}
