//
//  AKWebViewController.swift
//  Yelping
//
//  Created by Ahmad Zia Kakar on 4/8/18.
//  Copyright © 2018 Kakar. All rights reserved.
//

import UIKit

class AKWebViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    public var businessURL: URL? {
        didSet {
            updateUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Yelping"

        // Do any additional setup after loading the view.
        updateUI()
    }
    
    private func updateUI() {
        if let url = businessURL {
            activityIndicator?.startAnimating()
            webView?.loadRequest(URLRequest(url: url))
        }
    }
}


// MARK:- UIWebViewDelegate

extension AKWebViewController: UIWebViewDelegate {    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        activityIndicator.stopAnimating()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        //TODO: Handle error
        activityIndicator.stopAnimating()
    }
}

