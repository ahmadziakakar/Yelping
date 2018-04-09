//
//  AKDataStorage.swift
//  Yelping
//
//  Created by Ahmad Zia Kakar on 4/7/18.
//  Copyright © 2018 Kakar. All rights reserved.
//

import Foundation

struct AKDataStorage {
    
    //TODO: Currently, DataStorage doesn't have an ability to remove old files
    // add a feature to remove old files automatically for memory managment
    
    static fileprivate func getURL() -> URL {
        if let url = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: .userDomainMask).first {
            return url
        } else {
            fatalError("Could not get directory URL")
        }
    }

    
    // Store an encodable object to specified directory
    static func store<T: Encodable>(_ object: T, as fileName: String) {
        let url = getURL().appendingPathComponent(fileName, isDirectory: false)
        
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(object)
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }
            FileManager.default.createFile(atPath: url.path, contents: data, attributes: nil)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    // Retrieve and convert a struct from a file on disk
    static func retrieve<T: Decodable>(_ fileName: String, as type: T.Type) -> T {
        let url = getURL().appendingPathComponent(fileName, isDirectory: false)
        
        if !FileManager.default.fileExists(atPath: url.path) {
            fatalError("File at path \(url.path) does not exist!")
        }
        
        if let data = FileManager.default.contents(atPath: url.path) {
            let decoder = JSONDecoder()
            do {
                let model = try decoder.decode(type, from: data)
                return model
            } catch {
                fatalError(error.localizedDescription)
            }
        } else {
            fatalError("No data at \(url.path)!")
        }
    }
    
    static func fileExists(_ fileName: String) -> Bool {
        let url = getURL().appendingPathComponent(fileName, isDirectory: false)
        return FileManager.default.fileExists(atPath: url.path)
    }

}
