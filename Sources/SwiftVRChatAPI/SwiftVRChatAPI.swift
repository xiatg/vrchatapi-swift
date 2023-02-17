//public struct SwiftVRChatAPI {
//    public private(set) var text = "Hello, World!"
//
//    public init() {
//    }
//}

import Foundation

public let baseUrl = "https://api.vrchat.cloud/api/1"

public struct Configuration {
    public var username: String
    public var password: String
    
    public init(username: String, password: String) {
        self.username = username
        self.password = password
    }
}

public class APIClient {
    public var configuration: Configuration
    
    public init(configuration: Configuration) {
        self.configuration = configuration
    }
    
}

public class AuthenticationAPI {
    let authUrl = "\(baseUrl)/auth"
    
    var APIClient: APIClient
    
    init(APIClient: APIClient) {
        self.APIClient = APIClient
    }
    
    struct UserInfo: Codable {
        let requiresTwoFactorAuth: [String]?
        
        let id: String?
        let displayName: String?
        let userIcon: String?
        let bio: String?
        let bioLinks: String?
        
        let username: String?
        
        let friends: [String]?
        
        let currentAvatar: String?
        let currentAvatarImageUrl: String?
        let currentAvatarThumbnailImageUrl: String?
        let currentAvatarAssetUrl: String?
        
        let state: String?
        
        let tags: [String]?
        
        let status: String?
        
        let onlineFriends: [String]?
        let activeFriends: [String]?
        let offlineFriends: [String]?
        
    }
    
    func login() -> UserInfo? {
        let url = URL(string: "\(authUrl)/user")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let authData = (APIClient.configuration.username + ":" + APIClient.configuration.password).data(using: .utf8)!.base64EncodedString()
        request.addValue("Basic \(authData)", forHTTPHeaderField: "Authorization")
        
        var userInfo: UserInfo?
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            print(data)
            print(response)
            print(error)
            
            guard let data = data, error == nil else {
                return
            }
            
            guard let httpUrlResponse = response as? HTTPURLResponse else {
                return
            }
            
            switch (httpUrlResponse.statusCode) {
            case 200:
                userInfo = try? JSONDecoder().decode(UserInfo.self, from: data)
            default:
                return
            }
            
        }.resume()
        
        return userInfo
    }
}
