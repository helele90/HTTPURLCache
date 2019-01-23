//
//  HttpHeader.swift
//  WebCache
//
//  Created by Xiao He on 2019/1/11.
//  Copyright © 2019 Mi Cheng. All rights reserved.
//

import UIKit

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

enum HTTPHeaderKey: String {

    case cacheControl = "Cache-Control"
    case date = "Date"

}

enum HTTPRequestHeaderKey: String {

    case ifNoneMatch = "If-None-Match"
    case ifModifiedSince = "If-Modified-Since"
    case ifMatch = "If-Match"

}

enum HTTPResponseHeaderKey: String {

    case eTag = "Etag"
    case lastModified = "Last-Modified"
    case vary = "Vary"

}

struct HTTPHeaderCacheControl {

    let cacheControl: String

    var noCache: Bool {
        return cacheControl.contains("no-cache")
    }

    var noStore: Bool {
        return cacheControl.contains("no-store")
    }

    var onlyIfCached: Bool {
        return !cacheControl.contains("only-if-cached")
    }

    var maxAge: Int? {
        let pattern = "( ,|)max-age=([0-9]+)"
        let regex = try! NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
        let res = regex.matches(in: cacheControl, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, cacheControl.count))
        guard !res.isEmpty else {
            return nil
        }

        let range = NSMakeRange(res[0].range.lowerBound + 8, res[0].range.upperBound - 8)
        let maxAge = (cacheControl as NSString).substring(with: range)
        return Int(maxAge)
    }

}

enum HTTPResponseStatusCode: Int {
    case notModified = 304
}

enum HttpHeaderCacheControlCacheability: String {
    case `public` = "public"
    case `private` = "private"
    case noCache = "no-cache"
    case onlyIfCached = "only-if-cached"

}

enum HttpHeaderCacheControlExpiration: String {
    case maxAge = "max-age"
    case sMaxage = "s-maxage"
    case maxStale = "max-stale"
    case minFresh = "min-fresh"

}

extension URLRequest {

    var cacheControl: HTTPHeaderCacheControl? {
        guard let cacheControl = allHTTPHeaderFields?[HTTPHeaderKey.cacheControl.rawValue] else {
            return nil
        }

        return HTTPHeaderCacheControl(cacheControl: cacheControl)
    }

    var date: String? {
        return allHTTPHeaderFields?[HTTPHeaderKey.date.rawValue]
    }

    var ifNoneMatch: String? {
        return allHTTPHeaderFields?[HTTPRequestHeaderKey.ifNoneMatch.rawValue]
    }

    var ifModifiedSince: String? {
        return allHTTPHeaderFields?[HTTPRequestHeaderKey.ifModifiedSince.rawValue]
    }

    var ifMatch: String? {
        return allHTTPHeaderFields?[HTTPRequestHeaderKey.ifMatch.rawValue]
    }

}

extension HTTPURLResponse {

    var cacheControl: HTTPHeaderCacheControl? {
        guard let cacheControl = allHeaderFields[HTTPHeaderKey.cacheControl.rawValue] as? String else {
            return nil
        }

        return HTTPHeaderCacheControl(cacheControl: cacheControl)
    }

    var date: Date? {
        guard let dateString = allHeaderFields[HTTPHeaderKey.date.rawValue] as? String else {
            return nil
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, dd MMM yyyy HH:mm:ss zzz"
        return dateFormatter.date(from: dateString)
    }

    var eTag: String? {
        return allHeaderFields[HTTPResponseHeaderKey.eTag.rawValue] as? String
    }

    var lastModified: Date? {
        return allHeaderFields[HTTPResponseHeaderKey.lastModified.rawValue] as? Date
    }

//    var vray: String? {
//        return allHeaderFields[HTTPResponseHeaderKey.vary.rawValue] as? String
//    }

}

