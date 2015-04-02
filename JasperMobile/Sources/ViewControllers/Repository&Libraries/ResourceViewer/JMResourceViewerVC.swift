/*
* TIBCO JasperMobile for iOS
* Copyright © 2005-2014 TIBCO Software, Inc. All rights reserved.
* http://community.jaspersoft.com/project/jaspermobile-ios
*
* Unless you have purchased a commercial license agreement from Jaspersoft,
* the following license terms apply:
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU Lesser General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License
* along with this program. If not, see <http://www.gnu.org/licenses/lgpl>.
*/

//
//  JMResourceViewerVC.swift
//  TIBCO JasperMobile
//

/**
@author Olexandr Dahno odahno@tibco.com
@since 2.1
*/

import UIKit
import WebKit

class JMResourceViewerVC: JMBaseResourceViewerVC {

    weak var webView: WKWebView!

    // Actions
    func backButtonAction() {
        webView.removeFromSuperview()
        webView = nil
        navigationController?.popViewControllerAnimated(true)
    }

    // Setups
    override func setupSubviews() {
        setupWebView()
        setupBackButton()
    }

    func setupWebView() {
        webView = JMWKWebViewManager.sharedInstance.webView
        webView.frame = view.bounds

        //webView.navigationDelegate = self
        self.view.insertSubview(webView, belowSubview:activityIndicator)
    }

    func setupBackButton() {
        let backButton = backButtonWithTitle(nil, target: self, action: "backButtonAction")
        navigationItem.leftBarButtonItem = backButton
    }

    // start point
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
