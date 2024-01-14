//
//  AuthenticationAPI.swift
//  
//
//  Created by 夏同光 on 2/23/23.
//

import Foundation

//
// MARK: Authentication API
//

let authUrl = "\(baseUrl)/auth"
let auth2FAUrl = "\(baseUrl)/auth/twofactorauth"

struct VerifyResponse: Codable {
    let verified: Bool
}

@available(macOS 12.0, *)
@available(iOS 15.0, *)
public struct AuthenticationAPIAsync {
    
    public static func loginUserInfo(client: APIClientAsync) async -> User? {
        let url = URL(string: "\(authUrl)/user")!
        
        let (data, _) = await client.VRChatRequest(url: url,
                             httpMethod: "GET",
                             authorization: true,
                             auth: true,
                             twoFactorAuth: true)
        
        guard let data = data else { return nil }

        let user:User? = decode(data: data)

        client.updateCookies()
        
        return user
    }
    
    public static func verify2FAEmail(client: APIClientAsync, emailOTP: String) async -> Bool? {
        let url = URL(string: "\(auth2FAUrl)/emailotp/verify")!
        
        let httpBody: Data?
        do {
            httpBody = try JSONSerialization.data(withJSONObject: ["code" : emailOTP], options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
        
        let (data, _) = await client.VRChatRequest(url: url,
                             httpMethod: "POST",
                             auth: true,
                             contentType: "application/json",
                             httpBody: httpBody)
        
        guard let data = data else { return nil }

        let verifyResponse:VerifyResponse? = decode(data: data)
        
        client.updateCookies()
        
        return verifyResponse?.verified
        
    }
    
    public static func verify2FATOTP(client: APIClientAsync, TOTP: String) async -> Bool? {
        let url = URL(string: "\(auth2FAUrl)/totp/verify")!
        
        let httpBody: Data?
        do {
            httpBody = try JSONSerialization.data(withJSONObject: ["code" : TOTP], options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
        
        let (data, _) = await client.VRChatRequest(url: url,
                             httpMethod: "POST",
                             auth: true,
                             contentType: "application/json",
                             httpBody: httpBody)
        
        guard let data = data else { return nil }

        let verifyResponse:VerifyResponse? = decode(data: data)
        
        client.updateCookies()
        
        return verifyResponse?.verified
        
    }
    
    public static func logout(client: APIClientAsync) async {
        let url = URL(string: "\(baseUrl)/logout")!
        
        let (_, _) = await client.VRChatRequest(url: url,
                             httpMethod: "PUT",
                             auth: true)

        client.updateCookies()
    }
}

public struct AuthenticationAPI {
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
