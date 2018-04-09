//
//  AKBusinessCVCConfigurator.swift
//  Yelping
//
//  Created by Ahmad Zia Kakar on 4/7/18.
//  Copyright © 2018 Kakar. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

struct AKBusinessCVCConfigurator {
    let placeHolderImage = UIImage(named: "yelp_logo")
    
    public func configure(_ cell: AKBusinessCollectionViewCell, forDisplaying business: Business) {
        cell.nameLabel.text =  business.name
        cell.addressLabel.text = business.phone
        
        if let imageURL = URL(string: business.image_url) {
            cell.backgroundImageView.sd_setImage(with: imageURL, placeholderImage: placeHolderImage)
        }
    }
}
