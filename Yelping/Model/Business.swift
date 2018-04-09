//
//  Response.swift
//  Yelping
//
//  Created by Ahmad Zia Kakar on 4/6/18.
//  Copyright © 2018 Kakar. All rights reserved.
//

import Foundation

struct Response: Codable {
    let total: Int
    let businesses: [Business]
}

struct Business: Codable, Equatable {
    let name: String
    let url: String
    let image_url: String
    let distance: Double
    let review_count: Int
    let phone: String
}
