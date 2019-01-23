//
//  ViewController.swift
//  WebCache
//
//  Created by Xiao He on 2019/1/11.
//  Copyright © 2019 Mi Cheng. All rights reserved.
//

import UIKit
import WebKit
import HTTPURLCache

class ViewController: UIViewController {

    private let webView = WKWebView()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        WebCache.register()

        let url = URL(string: "http://localhost:3000/")!
        var request = URLRequest(url: url)
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
        webView.load(request)

        let reloadItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(reload))
        navigationItem.rightBarButtonItem = reloadItem

        let backItem = UIBarButtonItem(barButtonSystemItem: .undo, target: self, action: #selector(back))
        navigationItem.leftBarButtonItem = backItem

        //        let currentDiskUsage = URLCache.shared.currentDiskUsage
        //        let diskCapacity = URLCache.shared.diskCapacity
        //        let currentMemoryUsage = URLCache.shared.currentMemoryUsage
        //        let memoryCapacity = URLCache.shared.memoryCapacity
        //        print("load")

        //        let url2 = URL(string: "http://www.abc.com")!
        //        let request2 = URLRequest(url: url2)
        //        var headerFields: [String: String] = [:]
        //        headerFields["CacheControl"] = "no-store"
        //        let response = HTTPURLResponse(url: url2, statusCode: 200, httpVersion: nil, headerFields: headerFields)!
        //        let text = "123"
        //        let data = text.data(using: .utf8)!
        //        let cachedURLResponse = CachedURLResponse(response: response, data: data)
        //        URLCache.shared.storeCachedResponse(cachedURLResponse, for: request2)
    }

    override func loadView() {
        webView.uiDelegate = self
        webView.navigationDelegate = self
        view = webView
    }

    @objc private func back() {
        let url2 = URL(string: "http://www.abc.com")!
        let request = URLRequest(url: url2)
        let response = URLCache.shared.cachedResponse(for: request)
        print(response)
    }

    @objc private func reload() {
        webView.reload()
    }

}

extension ViewController: WKUIDelegate {

}

extension ViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("didFinish")
    }

}

