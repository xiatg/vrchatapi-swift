//public struct SwiftVRChatAPI {
//    public private(set) var text = "Hello, World!"
//
//    public init() {
//    }
//}

import Foundation

let domainUrl = "https://api.vrchat.cloud"
let baseUrl = "https://api.vrchat.cloud/api/1"

public class APIClient {
    public var username: String?
    public var password: String?
    public var cookies: [String : String?] = ["auth": nil, "twoFactorAuth": nil, "apiKey": nil]

    
    public init() {
        
    }
    
    public init(username: String, password: String) {
        self.username = username
        self.password = password
    }
    
    public init(auth: String?, twoFactorAuth: String?, apiKey: String?) {
        self.cookies["auth"] = auth
        self.cookies["twoFactorAuth"] = twoFactorAuth
        self.cookies["apiKey"] = apiKey
    }
    
    public func updateCookies() {
        self.cookies = ["auth": nil, "twoFactorAuth": nil, "apiKey": nil]
        for cookie in HTTPCookieStorage.shared.cookies(for: URL(string: domainUrl)!)! {
            if (cookie.name == "auth" || cookie.name == "twoFactorAuth" || cookie.name == "apiKey") {
                self.cookies[cookie.name] = cookie.value
            }
        }
    }

}

public class AuthenticationAPI {
    let authUrl = "\(baseUrl)/auth"
    let auth2FAUrl = "\(baseUrl)/auth/twofactorauth"
    
    public var client: APIClient
    
    public init(client: APIClient) {
        self.client = client
    }
    
    public struct UserInfo: Codable {
        public let requiresTwoFactorAuth: [String]?
        
        public let id: String?
        public let displayName: String?
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
    
    public func loginUserInfo() -> UserInfo? {
        let url = URL(string: "\(authUrl)/user")!
        let sem = DispatchSemaphore(value: 0)
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        request.addValue("twoFactorAuth=\(client.cookies["twoFactorAuth"]! ?? "twoFactorAuth"); auth=\(client.cookies["auth"]! ?? "auth")", forHTTPHeaderField: "Cookie")
        
        let authData = ((client.username ?? "") + ":" + (client.password ?? "")).data(using: .utf8)!.base64EncodedString()
        request.addValue("Basic \(authData)", forHTTPHeaderField: "Authorization")
        
        var userInfo: UserInfo?
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            defer { sem.signal() }
            
            guard let data = data, error == nil else {
                return
            }
        
            do {
                userInfo = try JSONDecoder().decode(UserInfo.self, from: data)
            } catch let error {
                do {
                    print(error.localizedDescription)
                    
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
                    print(json!)
                } catch let error {
                    print(error.localizedDescription)
                }
            }

        }.resume()
        
        sem.wait()
        
        client.updateCookies()
        
        return userInfo
    }
    
    public func logout() -> Bool? {
        let url = URL(string: "\(baseUrl)/logout")!
        let sem = DispatchSemaphore(value: 0)
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        request.addValue("auth=\(client.cookies["auth"]! ?? "auth")", forHTTPHeaderField: "Cookie")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            defer { sem.signal() }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
                print(json!)
            } catch let error {
                print(error.localizedDescription)
            }

        }.resume()
        
        sem.wait()
        
        client.updateCookies()
        
        return true
    }
    
    
    
    struct VerifyResponse: Codable {
        let verified: Bool
    }
    
    public func verify2FAEmail(emailOTP: String) -> Bool? {
        let url = URL(string: "\(auth2FAUrl)/emailotp/verify")!
        let sem = DispatchSemaphore(value: 0)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let emailOTPWrapper = ["code" : emailOTP]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: emailOTPWrapper, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var verifyResponse: VerifyResponse?
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            defer { sem.signal() }
            
            guard let data = data, error == nil else {
                return
            }
            
            do {
                verifyResponse = try JSONDecoder().decode(VerifyResponse.self, from: data)
            } catch let error {
                do {
                    print(error.localizedDescription)
                    
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
                    print(json!)
                } catch let error {
                    print(error.localizedDescription)
                }
            }
            
        }.resume()
        
        sem.wait()
        
        client.updateCookies()
        
        return verifyResponse?.verified
    }
}
