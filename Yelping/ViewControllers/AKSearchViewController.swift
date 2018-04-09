//
//  AKSearchViewController.swift
//  Yelping
//
//  Created by Ahmad Zia Kakar on 4/6/18.
//  Copyright © 2018 Kakar. All rights reserved.
//

import UIKit

class AKSearchViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    // MARK: - Private variables

    private var viewModel: AKSearchViewModel!
    private var searchController: UISearchController!
    private var resultsController: UITableViewController!
    
    private struct Constants {
        static let minimumLineSpacing: CGFloat = 8
        static let minimumInteritemSpacing: CGFloat = 8
        static let edgeSpacingTop: CGFloat = 8
        static let edgeSpacingBottom: CGFloat = 8
        static let edgeSpacingRight: CGFloat = 8
        static let edgeSpacingLeft: CGFloat = 8
        static let resultsControllerCellIdentifier = "resultsControllerCellIdentifier"
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // setup navigation bar
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.hidesSearchBarWhenScrolling = false
        title = "Search"
        
        setupSearchController()
        setupCollectionViewLayoutFlow()
        setupViewModel()
        
        collectionView.insertSubview(refreshControl, at: 0)
    }
    
    
    // MARK: - Private functions
    
    private func setupSearchController() {
        resultsController = UITableViewController(style: .plain)
        resultsController.tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.resultsControllerCellIdentifier)
        
        searchController = UISearchController(searchResultsController: resultsController)
        searchController.searchBar.placeholder = "Search Businesses"
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func setupCollectionViewLayoutFlow() {
        let cellSize = ((view.bounds.size.width - (Constants.minimumLineSpacing * 3)) / 2)
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: cellSize, height: cellSize)
        layout.minimumInteritemSpacing = Constants.minimumInteritemSpacing
        layout.minimumLineSpacing = Constants.minimumLineSpacing
        layout.sectionInset = UIEdgeInsets(top: Constants.edgeSpacingTop, left: Constants.edgeSpacingLeft, bottom: Constants.edgeSpacingBottom, right: Constants.edgeSpacingRight)
        collectionView.collectionViewLayout = layout
    }
    
    private func showAlert(with title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - ViewModel setup

    private func setupViewModel() {
        viewModel = AKSearchViewModel()
        collectionView.delegate = viewModel
        collectionView.dataSource = viewModel
        resultsController.tableView.dataSource = viewModel
        resultsController.tableView.delegate = viewModel

        viewModel.reloadData = { [weak self] in
            self?.collectionView.reloadData()
            self?.resultsController.tableView.reloadData()
        }
        
        viewModel.dismissSearchController = { [weak self] in
            self?.searchController.isActive = false
        }
        
        viewModel.showAPIErrorAlert = { [weak self] error in
            let errorMessage = error?.localizedDescription ?? "Could not load businesses"
            self?.showAlert(with: "Error", message: errorMessage)
        }
    }
    
    
    // MARK: - Refresh Control

    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(AKSearchViewController.handleRefresh(_:)), for: .valueChanged)
        refreshControl.tintColor = .gray
        return refreshControl
    }()

    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        viewModel.loadBusinesses(with: nil)
        refreshControl.endRefreshing()
    }

    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let webVC = segue.destination as? AKWebViewController,
            let cell = sender as? AKBusinessCollectionViewCell,
            let indexPath = collectionView.indexPath(for: cell) {
            guard let business = viewModel.getBusiness(for: indexPath) else { return }
            webVC.businessURL = URL(string: business.url)
        }
    }
}


// MARK: - UISearchResultsUpdating Delegate

extension AKSearchViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        resultsController.view.isHidden = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else { return }
        viewModel.loadBusinesses(with: text)
    }
}





