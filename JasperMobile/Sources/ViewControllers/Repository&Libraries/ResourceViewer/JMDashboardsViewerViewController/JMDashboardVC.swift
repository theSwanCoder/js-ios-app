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
//  JMDashboardVC.swift
//  TIBCO JasperMobile
//

/**
@author Olexandr Dahno odahno@tibco.com
@since 2.1
*/

import UIKit
import WebKit

class JMDashboardVC: GAITrackedViewController, JMResourceClientHolder {

    var resourceLookup: JSResourceLookup?
    var dashboard: JMDashboard?

    // IBOutlets
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    weak var webView: WKWebView!

    deinit {
        let destroyDashboardJS = "MobileDashboard.destroy();"
        webView.evaluateJavaScript(destroyDashboardJS, completionHandler: nil)
    }

    // ViewController LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupWebView()
        loadDashboard()

        activityIndicator.stopAnimating()

        let destroyButton = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: "destroyDashboard")
        self.navigationItem.rightBarButtonItem = destroyButton
    }

    // Actions
    func destroyDashboard() {
        println("destroy dashboard")
        let destroyDashboardJS = "MobileDashboard.destroy();"
        webView.evaluateJavaScript(destroyDashboardJS, completionHandler: nil)
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

    // Start point
    func loadDashboard() {
        if let dashboard = self.dashboard {
            if JMWKWebViewManager.sharedInstance.isVisualizeLoaded {
                runDashboard()
            } else {
                if let htmlString = HTMLString() {
                    let baseURLString = self.restClient().serverProfile.serverUrl
                    webView.loadHTMLString(htmlString, baseURL: NSURL(string: baseURLString))
                }
            }
        }
    }

    func HTMLString() -> String? {

        let dashboardHTMLPath = NSBundle.mainBundle().pathForResource("dashboard", ofType: "html")
        var dashboardHTMLContent = String(contentsOfFile: dashboardHTMLPath!, encoding: NSUTF8StringEncoding, error: nil)

        var htmlStringWithVisualizePath: String?

        if let htmlString = dashboardHTMLContent {
            let baseURLString = self.restClient().serverProfile.serverUrl

            htmlStringWithVisualizePath = htmlString.stringByReplacingOccurrencesOfString("VISUALIZE_PATH", withString: baseURLString + "/client/visualize.js", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)

            // requreJS
            let requireJSPath = NSBundle.mainBundle().pathForResource("require.min", ofType: "js")
            let requireJSContent = String(contentsOfFile: requireJSPath!, encoding: NSUTF8StringEncoding, error: nil)
            if let requireJS = requireJSContent {
                htmlStringWithVisualizePath = htmlStringWithVisualizePath!.stringByReplacingOccurrencesOfString("REQUIRE_JS", withString: requireJS, options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
            }

            // mobilejs
            let mobileJSPath = NSBundle.mainBundle().pathForResource("dashboard-amber2-ios-mobilejs-sdk", ofType: "js")
            let mobileJSContent = String(contentsOfFile: mobileJSPath!, encoding: NSUTF8StringEncoding, error: nil)
            if let mobileJS = mobileJSContent {
                htmlStringWithVisualizePath = htmlStringWithVisualizePath!.stringByReplacingOccurrencesOfString("JASPERMOBILE_SCRIPT", withString: mobileJS, options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
            }
        }
        return htmlStringWithVisualizePath
    }

    // run dashboard
    func runDashboard() {
        let authorizeString = "MobileDashboard.authorize({'username': '\(self.restClient().serverProfile.username)', 'password': '\(self.restClient().serverProfile.password)', 'organization': '\(self.restClient().serverProfile.organization)'});"
        webView.evaluateJavaScript(authorizeString, completionHandler: nil)

        if let dashboard = self.dashboard {
            let runDashboardString = "MobileDashboard.run({'uri': '\(dashboard.resourceURI)'});"
            webView.evaluateJavaScript(runDashboardString, completionHandler: nil)
        }
    }
}

extension JMDashboardVC: WKNavigationDelegate {

    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        println("webView didStartProvisionalNavigation")
        activityIndicator.startAnimating()
    }

    func webView(webView: WKWebView!, didFinishNavigation navigation: WKNavigation!) {
        JMWKWebViewManager.sharedInstance.isVisualizeLoaded = true
        println("webView didFinishNavigation")
        activityIndicator.stopAnimating()

        runDashboard()
    }

}
