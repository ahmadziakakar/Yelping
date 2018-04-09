//
//  AKBusinessCollectionViewCell.swift
//  Yelping
//
//  Created by Ahmad Zia Kakar on 4/6/18.
//  Copyright © 2018 Kakar. All rights reserved.
//

import UIKit

class AKBusinessCollectionViewCell: UICollectionViewCell {
    
    public static let cellIdentifier = "AKBusinessCollectionViewCell"
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
}
