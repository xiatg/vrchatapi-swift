//
//  Model.swift
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

public struct Response: Codable {
    public let message: String?
    public let status_code: Int?
}
