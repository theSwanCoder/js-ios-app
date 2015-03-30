//
//  JMResourceViewerVC.swift
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 3/30/15.
//  Copyright (c) 2015 TIBCO JasperMobile. All rights reserved.
//

import UIKit
import WebKit

class JMResourceViewerVC: JMBaseResourceViewerVC {

    weak var webView: WKWebView?

    override func setupSubviews() {
        setupWebView()
    }

    // Setups
    func setupWebView() {
        let rootViewBounds = navigationController!.view.bounds
        let webView = JMWKWebViewManager.sharedInstance.webView
        webView.frame = view.frame

        webView.navigationDelegate = self
        self.view.insertSubview(webView, belowSubview:activityIndicator)
        self.webView = webView
    }

    override func runReportExecution() {
        println("run report execution")
    }
}

extension JMResourceViewerVC: WKNavigationDelegate {

    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        println("webView didStartProvisionalNavigation")
        startShowLoadingIndicators()
//        startShowLoaderWithMessage("Loading...", cancelBlock: { () -> Void in
//            println("cancel loading dashboard")
//        })
    }

    func webView(webView: WKWebView!, didFinishNavigation navigation: WKNavigation!) {
        println("webView didFinishNavigation")
        stopShowLoadingIndicators()
//        stopShowLoader()
    }
}
