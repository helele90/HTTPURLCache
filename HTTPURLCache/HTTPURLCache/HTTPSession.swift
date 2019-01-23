//
//  HTTPSession.swift
//  WebCache
//
//  Created by Xiao He on 2019/1/14.
//  Copyright © 2019 Mi Cheng. All rights reserved.
//

import UIKit

class HTTPSession {

    let session: URLSession

    init() {
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = nil
        session = URLSession(configuration: configuration)
    }

    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let task = session.dataTask(with: request) { (data, response, error) in
            completionHandler(data, response, error)
        }
        
        task.resume()
    }

}
