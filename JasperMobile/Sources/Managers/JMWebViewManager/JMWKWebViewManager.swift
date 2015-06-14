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
//  JMVisualizeWebViewManager.swift
//  TIBCO JasperMobile
//

/**
@author Aleksandr Dakhno odahno@tibco.com
@since 2.1
*/

import UIKit
import WebKit

class JMWKWebViewManager: NSObject {
    var isVisualizeLoaded = false
    let webView: WKWebView
    var messageHandler: AnyObject?

    class var sharedInstance: JMWKWebViewManager {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: JMWKWebViewManager? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = JMWKWebViewManager()
        }
        return Static.instance!
    }

    deinit {
        println("JMWKWebViewManager.deinit")
    }

    override init() {
        let config = WKWebViewConfiguration()
        self.webView = WKWebView(frame: CGRectZero, configuration: config)
        self.webView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        self.webView.scrollView.bounces = false

        super.init()
    }

//    func setupMessageHandler(messageHandler: JMVisualizeMessageHandler, name: String) {
//        webView.configuration.userContentController.addScriptMessageHandler(messageHandler, name: name)
//        self.messageHandler = messageHandler
//    }

    // TODO: need mechanism of removing message handler
    func removeMessageHanlerForName(name: String) {
        webView.configuration.userContentController.removeScriptMessageHandlerForName(name)
        messageHandler = nil
    }
}