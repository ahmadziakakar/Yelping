//
//  AKSearchViewModel.swift
//  Yelping
//
//  Created by Ahmad Zia Kakar on 4/7/18.
//  Copyright © 2018 Kakar. All rights reserved.
//

import Foundation
import UIKit

class AKSearchViewModel: NSObject {
    
    // MARK: - Private variables
    private let dataManager = AKDataManager()
    private let configurator = AKBusinessCVCConfigurator()
    private var isLoading = false
    private var totalResults = 0
    private var businesses = [Business]() {
        didSet {
            reloadData?()
        }
    }
    
    private var currentSearchTerm = Constants.defaultSearchTerm {
        didSet {
            UserDefaults.standard.setSearchTerm(currentSearchTerm, key: Constants.searchTermKey)
        }
    }

    
    // MARK: - Public variables
    
    public var reloadData: (() -> Void)?
    public var dismissSearchController: (() -> Void)?
    public var showAPIErrorAlert: ((Error?) -> Void)?

    public struct Constants {
        static let businessesLimit = 25
        static let collectionViewFooterSize = CGSize(width: 0, height: 50)
        static let resultsControllerCellIdentifier = "resultsControllerCellIdentifier"
        static let defaultSearchLocation = "Los Angeles, CA"
        static let defaultSearchTerm = "Food"
        static let perPageLimit = 20
        static let searchTermKey = "BusinessSearchTermKey"
    }

    
    override init() {
        super.init()
        
        // Initial API call
        loadBusinesses(with: Constants.defaultSearchTerm)
    }

    
    // MARK: - Public instance methods
    
    public func loadBusinesses(with text: String?) {
        currentSearchTerm = text ?? currentSearchTerm
        dismissSearchController?()
        businesses.removeAll()
        loadBusinesses(withLocation: Constants.defaultSearchLocation, term: currentSearchTerm, limit: Constants.perPageLimit, offset: 0, completion: nil)
    }

    public func getBusiness(for indexPath: IndexPath) -> Business? {
        return (indexPath.row < businesses.count) ? businesses[indexPath.row] : nil
    }
    
    
    // MARK: - Private instance methods
    
    private func loadBusinesses(withLocation location: String, term: String, limit: Int, offset: Int, completion: (([Business]?, Error?) -> Void)?) {
        guard isLoading == false, canLoadMoreBusinesses() else {
            print("Could not load businesses --> isLoading = \(isLoading) : canLoadMoreBusinesses = \(canLoadMoreBusinesses())")
            return
        }
        
        isLoading = true
        dataManager.search(with: location, term: term, limit: limit, offset: offset) { [weak self] (businesses, total, error) in
            if let businesses = businesses, error == nil {
                
                // retrieve stored bussinesses
                if AKDataStorage.fileExists(term.jsonExt) {
                    self?.businesses = AKDataStorage.retrieve(term.jsonExt, as: [Business].self)
                }

                self?.totalResults = total
                                
                // TODO: Apparently API bug, total count is 19 but returns only 15 businesses
                // to avoid making unnecessary network calls, set totalResults var to 0
                if businesses.count == 0 {
                    self?.totalResults = 0
                }
                
                completion?(businesses, nil)
            }
            else {
                // If API call gets failed, DataManager will return stored businesses 'if any' for offline mode
                if let storedBusinesses = businesses {
                    self?.businesses = storedBusinesses
                }
                self?.totalResults = 0
                self?.showAPIErrorAlert?(error)
                completion?(nil, error)
            }
            self?.isLoading = false
        }
    }

    private func loadMoreBusinesses(from lastItem: Int) {
        loadBusinesses(withLocation: Constants.defaultSearchLocation, term: currentSearchTerm, limit: Constants.perPageLimit, offset: lastItem, completion: nil)
    }
    
    private func canLoadMoreBusinesses() -> Bool {
        let firstAPICall = (businesses.count == 0) // TODO: bad assumption
        return (firstAPICall || (businesses.count < totalResults))
    }
    
}


// MARK:- UICollectionViewDataSource

extension AKSearchViewModel: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return businesses.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let businessCVC = collectionView.dequeueReusableCell(withReuseIdentifier: AKBusinessCollectionViewCell.cellIdentifier, for: indexPath) as? AKBusinessCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let business = businesses[indexPath.row]
        configurator.configure(businessCVC, forDisplaying: business)
        return businessCVC
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "BusinessCVFooterIdentifier", for: indexPath)
        return footerView
    }
}


// MARK:- UICollectionViewDelegate

extension AKSearchViewModel: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let lastItem = businesses.count
        if lastItem == indexPath.row+1 {
            loadMoreBusinesses(from: lastItem)
        }
    }
}


// MARK:- UICollectionViewDelegateFlowLayout

extension AKSearchViewModel: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return canLoadMoreBusinesses() ? Constants.collectionViewFooterSize : CGSize.zero
    }
}


// MARK: - UITableViewDataSource & UITableViewDelegate

extension AKSearchViewModel: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserDefaults.standard.getSearchTermHistory(for: Constants.searchTermKey)?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.resultsControllerCellIdentifier, for: indexPath)
        
        if var history = UserDefaults.standard.getSearchTermHistory(for: Constants.searchTermKey) {
            cell.textLabel?.text = history[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if var history = UserDefaults.standard.value(forKey: Constants.searchTermKey) as? [String] {
            let text = history[indexPath.row]
            loadBusinesses(with: text)
        }
    }
}

