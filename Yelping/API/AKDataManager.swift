//
//  AKDataManager.swift
//  Yelping
//
//  Created by Ahmad Zia Kakar on 4/7/18.
//  Copyright © 2018 Kakar. All rights reserved.
//

import Foundation


struct AKDataManager {
    
    private let apiManager = AKAPIManager()
    
    public func search(with location: String, term: String, limit: Int, offset: Int, completion: (([Business]?, Int, Error?) -> Void)?) {
        apiManager.search(with: location, term: term, limit: limit, offset: offset) { (response, error) in
            if let newBusinesses = response?.businesses {
                
                // fetch stored businesses from Storage, if available
                var storedBusinesses:[Business] = []
                if AKDataStorage.fileExists(term.jsonExt) {
                    storedBusinesses = AKDataStorage.retrieve(term.jsonExt, as: [Business].self)
                }
                
                // Step 1: merge only unique fetched bussinesses
                // Step 2: store all unique businesses in storage
                var uniqueBusinesses = storedBusinesses
                uniqueBusinesses.mergeElements(newElements: newBusinesses)
                AKDataStorage.store(uniqueBusinesses, as: term.jsonExt)
                
                DispatchQueue.main.async {
                    completion?(newBusinesses, response?.total ?? 0,  nil)
                }
            }
            else {
                // incase of error, return stored businesses if available
                if AKDataStorage.fileExists(term.jsonExt) {
                    let storedBusinesses = AKDataStorage.retrieve(term.jsonExt, as: [Business].self)
                    DispatchQueue.main.async {
                        completion?(storedBusinesses, 0, error)
                    }
                }
                else {
                    DispatchQueue.main.async {
                        completion?(nil, 0, error)
                    }
                }
            }
        }
    }
    
}
