/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2015 TIBCO Software, Inc. All rights reserved.
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
//  JMReportViewerVC.h
//  TIBCO JasperMobile
//

/**
@author Aleksandr Dakhno odahno@tibco.com
@since 2.1
*/


#import "JMResourceViewerProtocol.h"
#import "JMMenuActionsView.h"
#import "JMResourceClientHolder.h"
#import "JMReportLoaderProtocol.h"

@class JMReportViewerToolBar;
@class JMReportPartViewToolbar;
@class JMReportViewerConfigurator;

@interface JMReportViewerVC : JMBaseViewController <JMResourceClientHolder, JMResourceViewerProtocol, JMMenuActionsViewDelegate, JMMenuActionsViewProtocol>
@property (nonatomic, strong) JMReportViewerConfigurator *configurator;
@property (nonatomic, strong) NSArray <JSReportParameter *> *initialReportParameters;
@property (nonatomic, strong) JSReportDestination *initialDestination;
- (JSReport *)report;

- (void)showOnTV;
- (void)switchFromTV;
@end
