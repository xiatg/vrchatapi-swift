//
//  File.swift
//  
//
//  Created by 夏同光 on 2/23/23.
//

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
