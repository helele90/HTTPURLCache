//
//  WebCache.swift
//  WebCache
//
//  Created by Xiao He on 2019/1/11.
//  Copyright © 2019 Mi Cheng. All rights reserved.
//

import UIKit

public class WebCache {

    public static func register() {
        URLProtocol.registerClass(WebURLProtocol.self)
        guard let cls = NSClassFromString("WKBrowsingContextController") as? NSObject.Type else {
            return
        }

        let sel = NSSelectorFromString("registerSchemeForCustomProtocol:")
        if cls.responds(to: sel) {
            cls.perform(sel, with: "http")
            cls.perform(sel, with: "https")
        }
    }

}
