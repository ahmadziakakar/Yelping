//
//  Extensions.swift
//  Yelping
//
//  Created by Ahmad Zia Kakar on 4/7/18.
//  Copyright © 2018 Kakar. All rights reserved.
//

import Foundation


// MARK: - UserDefaults extensions

extension UserDefaults {
    func setSearchTerm(_ term: String, key: String) {
        if var history = value(forKey: key) as? [String] {
            
            // remove search term if already exist
            if let index = history.index(of: term) {
                history.remove(at: index)
            }
            history.insert(term, at: 0)
            set(history, forKey: key)
        }
        else {
            set([term], forKey: key)
        }
    }
    
    func getSearchTermHistory(for key: String) -> [String]? {
        if let history = value(forKey: key) as? [String] {
            return history
        }
        return nil
    }
}

// MARK: - LocalizedError extensions

enum NetworkError: LocalizedError {
    case responseStatusError(status: Int, message: String)
}

extension NetworkError {
    var errorDescription: String {
        switch self {
        case .responseStatusError(status: let status, message: let message):
            return "Error with status \(status) and message \(message) was thrown"
        }
    }
}


// MARK: - Array extensions

public extension Array where Element : Equatable {
    public mutating func mergeElements<C : Collection>(newElements: C) where C.Iterator.Element == Element{
        let filteredList = newElements.filter({!self.contains($0)})
        self.append(contentsOf: filteredList)
    }
}

public extension Sequence where Iterator.Element: Equatable {
    var uniqueElements: [Iterator.Element] {
        return self.reduce([]) { uniqueElements, element in
            uniqueElements.contains(element) ? uniqueElements : uniqueElements + [element]
        }
    }
}


// MARK: - String extensions

extension String {
    var jsonExt: String {
        return "\(self).json"
    }
}
