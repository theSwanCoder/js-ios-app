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
//  JMDashboardViewerConfigurator.h
//  TIBCO JasperMobile
//

/**
@author Aleksandr Dakhno odahno@tibco.com
@since 2.1
*/

#import <UIKit/UIKit.h>

@protocol JMDashboardLoader;
@protocol JMDashboardLoaderDelegate;
@class JMDashboard;
@class JMWebEnvironment;
@class JMDashboardViewerStateManager;
@class JMResourceViewerInfoPageManager;
@class JMResourceViewerPrintManager;
@class JMResourceViewerShareManager;
@class JMResourceViewerHyperlinksManager;
@class JMResourceViewerDocumentManager;
@class JMResourceViewerSessionManager;
@class JMDashboardViewerExternalScreenManager;

@interface JMDashboardViewerConfigurator : NSObject
@property (nonatomic, strong, readonly, nonnull) id<JMDashboardLoader> dashboardLoader;
@property (nonatomic, strong, readonly, nonnull) JMWebEnvironment *webEnvironment;
@property (nonatomic, strong, nonnull) JMDashboardViewerStateManager *stateManager;
@property (nonatomic, strong, nonnull) JMResourceViewerInfoPageManager * infoPageManager;
@property (nonatomic, strong, nonnull) JMResourceViewerPrintManager * printManager;
@property (nonatomic, strong, nonnull) JMResourceViewerShareManager * shareManager;
@property (nonatomic, strong, nonnull) JMResourceViewerHyperlinksManager * hyperlinksManager;
@property (nonatomic, strong, nonnull) JMResourceViewerDocumentManager * documentManager;
@property (nonatomic, strong, nonnull) JMResourceViewerSessionManager *sessionManager;
@property (nonatomic, strong, nonnull) JMDashboardViewerExternalScreenManager *externalScreenManager;
@property (nonatomic, assign) CGFloat viewportScaleFactor;

- (instancetype __nullable)initWithWebEnvironment:(JMWebEnvironment *__nonnull)webEnvironment;
+ (instancetype __nullable)configuratorWithWebEnvironment:(JMWebEnvironment *__nonnull)webEnvironment;

- (void)setup;
- (void)reset;
@end