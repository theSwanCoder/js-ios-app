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
//  JMVisualizeDashboardLoader.swift
//  TIBCO JasperMobile
//

/**
@author Aleksandr Dakhno odahno@tibco.com
@since 2.1
*/

import UIKit
import WebKit

class JMVisualizeDashboardLoader: NSObject {

    let CallbackHandler = "callback"
    weak var webView: WKWebView?
    let dashboard: JMDashboard

    deinit {
        if let webView = self.webView {
            webView.navigationDelegate = nil
        }
    }

    init(dashboard: JMDashboard, webView: WKWebView?) {
        self.dashboard = dashboard
        self.webView = webView

        super.init()

        if let localWebView = self.webView {
            localWebView.navigationDelegate = self
            // TODO: need handle adding script recieving
            if !JMWKWebViewManager.sharedInstance.hasScriptMessageHandler {
                JMWKWebViewManager.sharedInstance.hasScriptMessageHandler = true
                localWebView.configuration.userContentController.addScriptMessageHandler(self, name: CallbackHandler)
            }
        }
    }

    // public api
    func run() {
        loadDashboard()
    }

    func destroyDashboard() {
        let destroyDashboardJS = "MobileDashboard.destroy();"
        sendScriptMessage(destroyDashboardJS)
    }

    // private api
    private func loadDashboard() {
        if JMWKWebViewManager.sharedInstance.isVisualizeLoaded {
            runDashboard()
        } else {
            if let htmlString = HTMLString() {
                let baseURLString = self.restClient().serverProfile.serverUrl
                if let webView = self.webView {
                    webView.loadHTMLString(htmlString, baseURL: NSURL(string: baseURLString))
                }
            }
        }
    }

    private func runDashboard() {
        let authorizeString = "MobileDashboard.authorize({'username': '\(self.restClient().serverProfile.username)', 'password': '\(self.restClient().serverProfile.password)', 'organization': '\(self.restClient().serverProfile.organization)'});"
        sendScriptMessage(authorizeString)

        let runDashboardString = "MobileDashboard.run({'uri': '\(dashboard.resourceURI)'});"
        sendScriptMessage(runDashboardString)
    }

    private func removeScriptMessageHandler() {
        if let webView = self.webView {
            webView.configuration.userContentController.removeScriptMessageHandlerForName(self.CallbackHandler)
        }
    }

    private func sendScriptMessage(message: String) {
        if let webView = self.webView {
            webView.evaluateJavaScript(message, completionHandler: { (result, error) in
                println("\(message) result: \(result)")
                if let evaluateError = error {
                    println("error: \(evaluateError.localizedDescription)")
                }
            })
        }
    }
}

extension JMVisualizeDashboardLoader: WKNavigationDelegate {

    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        println("webView didStartProvisionalNavigation")
    }

    func webView(webView: WKWebView!, didFinishNavigation navigation: WKNavigation!) {
        println("webView didFinishNavigation")
    }

    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {

        let isLinkClicked = navigationAction.navigationType == .LinkActivated
        let requestString = navigationAction.request.URL.absoluteString!

        println("request: \(requestString)")
        println("isLinkClicked: \(isLinkClicked)")
        decisionHandler(.Allow)
    }

    func webView(webView: WKWebView, decidePolicyForNavigationResponse navigationResponse: WKNavigationResponse, decisionHandler: (WKNavigationResponsePolicy) -> Void) {

        let response = navigationResponse.response

        println("response: \(response)")
        decisionHandler(.Allow)
    }
}

extension JMVisualizeDashboardLoader {

    // helpers
    func HTMLString() -> String? {

        let dashboardHTMLPath = NSBundle.mainBundle().pathForResource("dashboard", ofType: "html")
        var dashboardHTMLContent = String(contentsOfFile: dashboardHTMLPath!, encoding: NSUTF8StringEncoding, error: nil)

        var htmlStringWithVisualizePath: String?

        if let htmlString = dashboardHTMLContent {
            let baseURLString = self.restClient().serverProfile.serverUrl

            htmlStringWithVisualizePath = htmlString.stringByReplacingOccurrencesOfString("VISUALIZE_PATH", withString: baseURLString + "/client/visualize.js?_showInputControls=true&_opt=true", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)

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
}

extension JMVisualizeDashboardLoader: WKScriptMessageHandler {

    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        if message.name == CallbackHandler {
            parseCommand(message.body as Dictionary<String, AnyObject>)
        }
    }

    // parsing command
    func parseCommand(commandDict: Dictionary<String, AnyObject>) {
        switch commandDict["command"] as String {
            case "onScriptLoaded" :
                onScriptLoaded(commandDict["parameters"] as Dictionary<String, AnyObject>)
            case "onLoadStart" :
                onLoadStart(commandDict["parameters"] as Dictionary<String, AnyObject>)
            case "onLoadDone" :
                onLoadDone(commandDict["parameters"] as Dictionary<String, AnyObject>)
            default:
                break
        }
    }

    // swift counterparts from js callbacks
    func onScriptLoaded(parameters: Dictionary<String, AnyObject>) {
        println("onScriptLoaded")
        println("parameters \(parameters)")
        JMWKWebViewManager.sharedInstance.isVisualizeLoaded = true
        runDashboard()
    }

    func onLoadStart(parameters: Dictionary<String, AnyObject>) {
        println("onLoadStart")
        println("parameters \(parameters)")
    }

    func onLoadDone(parameters: Dictionary<String, AnyObject>) {
        println("onLoadDone")
        println("parameters \(parameters)")
    }

    func onMaximize(parameters: Dictionary<String, AnyObject>) {
        println("onMaximize")
        println("parameters \(parameters)")
    }

    func onMinimize(parameters: Dictionary<String, AnyObject>) {
        println("onMinimize")
        println("parameters \(parameters)")
    }

    func onLoadError(parameters: Dictionary<String, AnyObject>) {
        println("onLoadError")
        println("parameters \(parameters)")
    }

}
