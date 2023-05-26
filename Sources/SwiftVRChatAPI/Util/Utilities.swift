//
//  File.swift
//  
//
//  Created by 夏同光 on 2/23/23.
//

import Foundation

//
// MARK: API Helper
//

func decode<T:Codable>(data: Data) -> T? {
    do {
        return try JSONDecoder().decode(T.self, from: data)
    } catch let error {
        print(error.localizedDescription)
        return nil
    }
}
