//public struct SwiftVRChatAPI {
//    public private(set) var text = "Hello, World!"
//
//    public init() {
//    }
//}

import Foundation

//
// MARK: General Model
//

let domainUrl = "https://api.vrchat.cloud"
let baseUrl = "https://api.vrchat.cloud/api/1"


public struct User: Codable {
    public let requiresTwoFactorAuth: [String]?
    
    public let id: String?
    public let displayName: String?
    public let username: String?
    public let userIcon: String?
    public let bio: String?
    public let bioLinks: [String]?

    public let friends: [String]?

    public let currentAvatar: String?
    public let currentAvatarAssetUrl: String?
    public let currentAvatarImageUrl: String?
    public let currentAvatarThumbnailImageUrl: String?

    public let state: String?
    public let status: String?

    public let tags: [String]?

    public let onlineFriends: [String]?
    public let activeFriends: [String]?
    public let offlineFriends: [String]?
    
}

//
// MARK: API Helper
//

func decode<T:Codable>(data: Data) -> T? {
    
    //Debug
//    print("*** decode() ***")
//    do {
//        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
//        print(json!)
//    } catch let error {
//        print(error.localizedDescription)
//    }
    //Debug End
    
    do {
        return try JSONDecoder().decode(T.self, from: data)
    } catch let error {
        print(error.localizedDescription)
        return nil
    }
}

//
// MARK: API Client
//

public class APIClient {
    private var username: String?
    private var password: String?
    
    // Cookies
    private var auth: String?
    private var twoFactorAuth: String?
    private var apiKey: String?

    
    public init() {}
    
    public init(username: String, password: String) {
        self.username = username
        self.password = password
    }
    
    public func updateCookies() {
        self.auth = nil
        self.twoFactorAuth = nil
        self.apiKey = nil
        for cookie in HTTPCookieStorage.shared.cookies(for: URL(string: domainUrl)!)! {
            if (cookie.name == "auth") {
                self.auth = cookie.value
            } else if (cookie.name == "twoFactorAuth") {
                self.twoFactorAuth = cookie.value
            } else if (cookie.name == "apiKey") {
                self.apiKey = cookie.value
            }
        }
        
        //Debug
//        print("*** updateCookies() ***")
//        print("auth: \(auth)")
//        print("twoFactorAuth: \(twoFactorAuth)")
//        print("apiKey: \(apiKey)")
        //Debug End
    }
    
    func VRChatRequest(url: URL,
                       httpMethod: String,
                       authorization: Bool = false,
                       auth: Bool = false, twoFactorAuth: Bool = false, apiKey: Bool = false,
                       contentType: String? = nil,
                       httpBody: Data? = nil,
                       completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        
        // Authorization
        if authorization {
            let authData = ((username ?? "") + ":" + (password ?? "")).data(using: .utf8)!.base64EncodedString()
            request.addValue("Basic \(authData)", forHTTPHeaderField: "Authorization")
        }
        
        // Cookie
        var cookie = ""
        if auth {
            cookie.append("auth=\(self.auth ?? "auth"); ")
//            request.addValue("auth=\(self.auth ?? "auth")", forHTTPHeaderField: "Cookie")
        }
        if twoFactorAuth {
            cookie.append("twoFactorAuth=\(self.twoFactorAuth ?? "twoFactorAuth"); ")
//            request.addValue("twoFactorAuth=\(self.twoFactorAuth ?? "twoFactorAuth")", forHTTPHeaderField: "Cookie")
        }
        if apiKey {
            cookie.append("apiKey=\(self.apiKey ?? "apiKey"); ")
//            request.addValue("apiKey=\(self.apiKey ?? "apiKey")", forHTTPHeaderField: "Cookie")
        }
        request.addValue(cookie, forHTTPHeaderField: "Cookie")
        
        //Debug
//        print("*** VRChatRequest() ***")
//        print(request.allHTTPHeaderFields)
        //Debug End
        
        // HTTP Body
        if let contentType = contentType, let httpBody = httpBody {
            request.addValue(contentType, forHTTPHeaderField: "Content-Type")
            request.httpBody = httpBody
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            completionHandler(data, response, error)
        }.resume()
    }
}


//
// MARK: Authentication API
//

public struct AuthenticationAPI {
    static let authUrl = "\(baseUrl)/auth"
    static let auth2FAUrl = "\(baseUrl)/auth/twofactorauth"
    
    public static func loginUserInfo(client: APIClient, completionHandler: @escaping @Sendable (User?) -> Void) {
        let url = URL(string: "\(authUrl)/user")!
        
        client.VRChatRequest(url: url,
                             httpMethod: "GET",
                             authorization: true,
                             auth: true,
                             twoFactorAuth: true) { data, response, error in
            guard let data = data, error == nil else { return }

            let user:User? = decode(data: data)
            
            client.updateCookies()
            completionHandler(user)
        }
    }
    
    public static func logout(client: APIClient) {
        let url = URL(string: "\(baseUrl)/logout")!
        
        client.VRChatRequest(url: url,
                             httpMethod: "PUT",
                             auth: true) { data, response, error in
            guard error == nil else { return }

            client.updateCookies()
        }
    }
    
    public static func verify2FAEmail(client: APIClient, emailOTP: String, completionHandler: @escaping @Sendable (Bool?) -> Void) {
        
        struct VerifyResponse: Codable {
            let verified: Bool
        }
        
        let url = URL(string: "\(auth2FAUrl)/emailotp/verify")!
        
        let httpBody: Data?
        do {
            httpBody = try JSONSerialization.data(withJSONObject: ["code" : emailOTP], options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
            return
        }
        
        client.VRChatRequest(url: url,
                             httpMethod: "POST",
                             auth: true,
                             contentType: "application/json",
                             httpBody: httpBody) { data, response, error in
            guard let data = data, error == nil else { return }

            let verifyResponse:VerifyResponse? = decode(data: data)
            
            client.updateCookies()
            completionHandler(verifyResponse?.verified)
        }
    }
}

//
// MARK: User API
//

public struct UserAPI {
    static let userUrl = "\(baseUrl)/users"

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
