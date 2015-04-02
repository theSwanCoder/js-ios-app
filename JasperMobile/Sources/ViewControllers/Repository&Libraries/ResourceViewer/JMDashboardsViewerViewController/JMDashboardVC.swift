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

class JMDashboardVC: JMResourceViewerVC {

    var dashboard: JMDashboard?
    var dashboardLoader: JMVisualizeDashboardLoader?
    var rightBarButtonItems: [AnyObject]?

    // UIViewController LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        rightBarButtonItems = navigationItem.rightBarButtonItems
    }

    // Actions
    override func backButtonAction() {
        dashboardLoader?.destroyDashboard()
        super.backButtonAction()
    }

    // overrided functions
    override func currentResourceLookup() -> JSResourceLookup? {
        return dashboard?.resourceLookup
    }

    // Start point
    override func runReportExecution() {
        if let dashboard = self.dashboard {
            dashboardLoader = JMVisualizeDashboardLoader(dashboard: dashboard, webView: webView)
            dashboardLoader!.delegate = self
            dashboardLoader!.run()
        } else {
            println("dashboard is nil")
        }
    }

    func minimizeDashlet() {
        dashboardLoader?.minimizeDashlet()
    }
}

extension JMDashboardVC: JMVisualizeDashboardLoaderDelegate {

    func loaderDidStartLoadDashboard(dashboardLoader: JMVisualizeDashboardLoader) {
        startShowLoaderWithMessage("Loading...", cancelBlock: { () -> Void in
            println("cancel loading dashboard")
        })
    }

    func loaderDidFinishLoadDashboard(dashboardLoader: JMVisualizeDashboardLoader) {
        stopShowLoader()
    }

    func loader(dashboardLoader: JMVisualizeDashboardLoader, didReceiveError error: NSError) {
        stopShowLoader()
        println("error of loading dashboard: \(error.localizedDescription)")
    }

    func loader(dashboardLoader: JMVisualizeDashboardLoader, didMaximizeDashlet dashlet: String) {
        var dashboardTitle = currentResourceLookup()?.label
        let backItem = backButtonWithTitle(dashboardTitle, target: self, action: "minimizeDashlet")
        navigationItem.leftBarButtonItem = backItem
        navigationItem.rightBarButtonItems = nil
        navigationItem.title = dashlet

        startShowLoaderWithMessage("Maximize \(dashlet)", cancelBlock: nil)
    }

    func loaderDidMinimizeDashlet(dashboardLoader: JMVisualizeDashboardLoader) {
        setupBackButton()
        navigationItem.rightBarButtonItems = rightBarButtonItems
    }
}
