//
//  AvatarAPI.swift
//  
//
//  Created by 夏同光 on 3/5/23.
//

import Foundation

public struct Avatar: Codable {
    public let id: String?
    public let name: String?
    public let description: String?
    public let authorId: String?
    public let authorName: String?
    public let tags: [String]?
    public let imageUrl: String?
    public let thumbnailImageUrl: String?
    public let releaseStatus: String?
    
    public let featured: Bool?
    
    public let created_at: String?
    public let updated_at: String?
}

//
// MARK: World API
//

public struct AvatarAPI {
    static let avatarUrl = "\(baseUrl)/avatars"

    public static func searchAvatar(client: APIClient,
                                    featured: Bool = true,
                                    n: Int = 60,
                                    completionHandler: @escaping @Sendable ([Avatar]?) -> Void) {
        
        let url = URL(string: "\(avatarUrl)?featured=\(featured)&n=\(n)")!
        
        client.VRChatRequest(url: url,
                             httpMethod: "GET",
                             auth: true,
                             apiKey: true) { data, response, error in
            guard let data = data, error == nil else { return }

            let avatars:[Avatar]? = decode(data: data)
            
            completionHandler(avatars)
        }
    }
}
