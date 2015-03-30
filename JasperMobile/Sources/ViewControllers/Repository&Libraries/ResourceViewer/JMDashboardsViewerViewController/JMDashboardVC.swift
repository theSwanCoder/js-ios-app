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

    deinit {
        if let loader = dashboardLoader {
            loader.destroy()
        }
    }

    // overrided functions
    override func currentResourceLookup() -> JSResourceLookup! {
        var resourceLookup : JSResourceLookup?
        if let dashboard = self.dashboard {
            resourceLookup = dashboard.resourceLookup
        }
        return resourceLookup
    }

    // Start point
    override func runReportExecution() {

        if let dashboard = self.dashboard {
            dashboardLoader = JMVisualizeDashboardLoader(dashboard: dashboard)
            if let loader = dashboardLoader {
                loader.webView = webView
                loader.webView?.navigationDelegate = loader
                loader.run()
            }
        } else {
            println("dashboard isn't assigned")
        }
    }
}
