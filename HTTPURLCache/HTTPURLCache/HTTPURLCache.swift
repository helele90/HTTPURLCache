//
//  URLCache.swift
//  WebCache
//
//  Created by Xiao He on 2019/1/11.
//  Copyright © 2019 Mi Cheng. All rights reserved.
//

import UIKit

struct HTTPCachedURLResponse {

    let response: CachedURLResponse
    let needRefresh: Bool

}

class HTTPURLCache {

    private let urlCache: URLCache

    init(urlCache: URLCache = URLCache.shared) {
        self.urlCache = urlCache
    }

    func store(request: URLRequest, response: HTTPURLResponse, data: Data) {
        guard let cacheControl = response.cacheControl else {
            return
        }

        guard cacheControl.noStore else {
            return
        }

        let cachedURLResponse = CachedURLResponse(response: response, data: data)
        urlCache.storeCachedResponse(cachedURLResponse, for: request)
    }

    func cache(request: URLRequest) -> HTTPCachedURLResponse? {
        guard let cachedResponse = urlCache.cachedResponse(for: request), let httpURLResponse = cachedResponse.response as? HTTPURLResponse else {
            return nil
        }

        var needRefresh = false
        if let cacheControl = httpURLResponse.cacheControl {
            if cacheControl.noCache {
                needRefresh = true
            } else if let maxAge = cacheControl.maxAge {
                if maxAge == 0 {
                     needRefresh = true
                } else {
                    if let date = httpURLResponse.date {
                        let age = abs(date.timeIntervalSinceNow)
                        needRefresh = Int(age) > maxAge
                    } else {
                        needRefresh = true
                    }
                }
            }
        }

        return HTTPCachedURLResponse(response: cachedResponse, needRefresh: needRefresh)
    }

    func test(request: URLRequest, response: HTTPURLResponse) -> URLRequest {
        guard let cacheControl = response.cacheControl else {
            return request
        }

        var request = request
        if let lastModified = response.lastModified {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "E, dd MMM yyyy HH:mm:ss zzz"
            let ifModifiedSince = dateFormatter.string(from: lastModified)
            request.setValue(ifModifiedSince, forHTTPHeaderField: HTTPRequestHeaderKey.ifModifiedSince.rawValue)
        }

        if let eTag = response.eTag {
            request.setValue(eTag, forHTTPHeaderField: HTTPRequestHeaderKey.ifNoneMatch.rawValue)
        }

        return request
    }

}
