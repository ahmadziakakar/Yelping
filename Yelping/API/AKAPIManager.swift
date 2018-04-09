//
//  AKAPIManager.swift
//  Yelping
//
//  Created by Ahmad Zia Kakar on 4/7/18.
//  Copyright © 2018 Kakar. All rights reserved.
//

import Foundation
import Alamofire

struct AKAPIManager {
    
    private struct YelpAPIConstants {
        static let yelpSearchURLString = "https://api.yelp.com/v3/businesses/search"
        static let API_KEY = "Bearer vUnaoRel3gPSgzaPb7O5ypzaAB5i4iqP2LgXtKfbYxh4jfW9pzoxCDxzqtyuoBwzvjkABu9VNFLciE4EsliVoTbZ6yNQMJPvHhngpsfw072VHoiS3IYOEt6cVNnGWnYx"
    }
    
    
    public func search(with location: String, term: String, limit: Int, offset: Int, completion: ((Response?, Error?) -> Void)?) {
        guard Reachability.isConnectedToNetwork() else {
            let error = NetworkError.responseStatusError(status: 0, message: "Device is not connected to network.")
            completion?(nil, error)
            return
        }
        
        guard  let url = URL(string: YelpAPIConstants.yelpSearchURLString) else {
            print("Could not get Yelp Search URL --> \(YelpAPIConstants.yelpSearchURLString)")
            return
        }
        
        let param: [String: Any] = ["term" : term, "location" : location, "limit" : limit, "offset" : offset]
        let headers = [ "authorization" : YelpAPIConstants.API_KEY]
        
        Alamofire.request(url, method: HTTPMethod.get, parameters: param, headers: headers).responseJSON { (response) in
            switch response.result {
            case .success:
                if let resultData = response.data {
                    do {
                        let json = try JSONDecoder().decode(Response.self, from: resultData)
                        completion?(json, nil)
                    }
                    catch {
                        print("Failed: JSONDecoder failed to decode")
                        completion?(nil, response.error)
                    }
                }
            case .failure:
                print("Failed: \(response.error?.localizedDescription ?? "Error while fetching new businesses")")
                completion?(nil, response.error)
            }
        }
    }

}
