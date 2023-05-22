//public struct SwiftVRChatAPI {
//    public private(set) var text = "Hello, World!"
//
//    public init() {
//    }
//}

import Foundation

//
// MARK: API Client
//

@available(iOS 15.0, *)
public class APIClientAsync {
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
                       httpBody: Data? = nil) async -> (Data?, URLResponse?) {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        
        /// Authorization
        if authorization {
            let authData = ((username ?? "") + ":" + (password ?? "")).data(using: .utf8)!.base64EncodedString()
            request.addValue("Basic \(authData)", forHTTPHeaderField: "Authorization")
        }
        
        /// Cookie
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
        
        /// HTTP Body
        if let contentType = contentType, let httpBody = httpBody {
            request.addValue(contentType, forHTTPHeaderField: "Content-Type")
            request.httpBody = httpBody
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            return (data, response)
        } catch {
            print(error.localizedDescription)
            
            return (nil, nil)
        }
    }
}


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
