//
//  FavoriteAPI.swift
//  
//
//  Created by 夏同光 on 5/25/23.
//

import Foundation

public enum FavoriteType: String, Codable {
    case world
    case avatar
    case friend
}

public struct Favorite: Codable {
    
    public let success: Response?
    public let error: Response?
    
    public let id: String?
    public let type: FavoriteType?
    public let favoriteId: String?
    public let tags: [String]?
}

//
// MARK: Favorite API
//

let favoriteUrl = "\(baseUrl)/favorites"

@available(macOS 12.0, *)
@available(iOS 15.0, *)
public struct FavoriteAPIAsync {

    public static func getFavorites(client: APIClientAsync, n: Int = 60) async -> [Favorite]? {
        
        let urlRaw = "\(favoriteUrl)?n=\(n)"
        
        let url = URL(string: urlRaw)!
        
        let (data, _) = await client.VRChatRequest(url: url,
                             httpMethod: "GET",
                             auth: true,
                             apiKey: true)
        
        guard let data = data else { return nil }

        let favorites:[Favorite]? = decode(data: data)
        
        return favorites
    }
    
    public static func addFavorite(client: APIClientAsync, type: FavoriteType = .friend, favoriteId: String, tags: [String]? = nil) async -> Favorite? {
        let url = URL(string: "\(favoriteUrl)")!
        
        var favoriteInfo: [String: Any] = [:]
        
        favoriteInfo["type"] = type.rawValue
        favoriteInfo["favoriteId"] = favoriteId
        
        if tags == nil {
            switch type {
            case .world:
                favoriteInfo["tags"] = ["worlds1"]
            case .avatar:
                favoriteInfo["tags"] = ["avatars1"]
            case .friend:
                favoriteInfo["tags"] = ["group_0"]
            }
        } else {
            favoriteInfo["tags"] = tags
        }
        
        var httpBody: Data
        
        do {
            httpBody = try JSONSerialization.data(withJSONObject: favoriteInfo)
        } catch {
            print(error.localizedDescription)
            return nil
        }
        
        let (data, _) = await client.VRChatRequest(url: url,
                             httpMethod: "POST",
                             auth: true,
                             apiKey: true,
                             contentType: "application/json",
                             httpBody: httpBody)
        
        guard let data = data else { return nil }
        
        let favorite:Favorite? = decode(data: data)
        
        return favorite
    }
    
    public static func removeFavorite(client: APIClientAsync, favoriteId: String) async -> Favorite? {
        let url = URL(string: "\(favoriteUrl)/\(favoriteId)")!
        
        let (data, _) = await client.VRChatRequest(url: url,
                             httpMethod: "DELETE",
                             auth: true,
                             apiKey: true)
        
        guard let data = data else { return nil }
        
        let favorite:Favorite? = decode(data: data)
        
        return favorite
    }
}


public struct FavoriteAPI {

    public static func getFavorites(client: APIClient, n: Int = 60, completionHandler: @escaping @Sendable ([Favorite]?) -> Void) {
        
        let urlRaw = "\(favoriteUrl)?n=\(n)"
        
        let url = URL(string: urlRaw)!
        
        client.VRChatRequest(url: url,
                             httpMethod: "GET",
                             auth: true,
                             apiKey: true) { data, response, error in
            guard let data = data, error == nil else { return }

            let favorites:[Favorite]? = decode(data: data)
            
            completionHandler(favorites)
        }
    }
}
