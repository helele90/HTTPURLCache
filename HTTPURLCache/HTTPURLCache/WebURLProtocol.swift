//
//  URLProtocol2.swift
//  WebCache
//
//  Created by Xiao He on 2019/1/11.
//  Copyright © 2019 Mi Cheng. All rights reserved.
//

import Foundation

private var set: Set<String> = []

private var count = 0

class WebURLProtocol: URLProtocol {

    private let httpURLCache = HTTPURLCache()

    private let httpSession = HTTPSession()

    override func startLoading() {
        let cachedURLResponse = httpURLCache.cache(request: request)
        if let cachedURLResponse = cachedURLResponse, !cachedURLResponse.needRefresh {
            let httpResponse = cachedURLResponse.response
            self.client?.urlProtocol(self, didReceive: httpResponse.response, cacheStoragePolicy: httpResponse.storagePolicy)
            self.client?.urlProtocol(self, didLoad: httpResponse.data)
            self.client?.urlProtocolDidFinishLoading(self)
            return
        }

        URLProtocol.setProperty(true, forKey: "isLoading", in: request as! NSMutableURLRequest)
        load(cachedURLResponse: cachedURLResponse?.response)
    }

    private func load(cachedURLResponse: CachedURLResponse? = nil) {
        var request2 = request
        if let httpResponse = cachedURLResponse?.response as? HTTPURLResponse {
            request2 = httpURLCache.test(request: request, response: httpResponse)
        }

        count += 1
        print(request2.url?.absoluteString)
        set.insert(request2.url!.absoluteString)
        httpSession.dataTask(with: request2) { (data, response, error) in
            set.remove(request2.url!.absoluteString)

            if let error = error {
                self.client?.urlProtocol(self, didFailWithError: error)
                self.client?.urlProtocolDidFinishLoading(self)
                return
            }

            guard let response = response as? HTTPURLResponse else {
                self.client?.urlProtocolDidFinishLoading(self)
                return
            }

            guard response.statusCode != HTTPResponseStatusCode.notModified.rawValue else {
                if let cachedURLResponse = cachedURLResponse {
                    //重新保存
                    self.client?.urlProtocol(self, didReceive: cachedURLResponse.response, cacheStoragePolicy: cachedURLResponse.storagePolicy)
                    self.client?.urlProtocol(self, didLoad: cachedURLResponse.data)
                    self.client?.urlProtocolDidFinishLoading(self)
                }

                return
            }

            self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: URLCache.StoragePolicy.allowed)
            self.client?.urlProtocol(self, didLoad: data!)
            self.client?.urlProtocolDidFinishLoading(self)

            if let data = data {
                self.httpURLCache.store(request: request2, response: response, data: data)
            }
        }
    }

    override func stopLoading() {
        print("stopLoading")
        if let absoluteString = request.url?.absoluteString {
//            set.remove(absoluteString)
        }
    }

    override class func canInit(with request: URLRequest) -> Bool {
        guard request.httpMethod == HTTPMethod.get.rawValue else {
            return false
        }

        guard let absoluteString = request.url?.absoluteString else {
            return false
        }

        if set.contains(absoluteString) {
            return false
        }

        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

}
