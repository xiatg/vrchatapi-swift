//
//  File.swift
//  
//
//  Created by 夏同光 on 2/23/23.
//

import Foundation

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
