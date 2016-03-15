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
//  JMDashboardLoader.h
//  TIBCO JasperMobile
//

/**
@author Aleksandr Dakhno odahno@tibco.com
@since 2.1
*/

#import "JMJavascriptNativeBridge.h"
@protocol JMDashboardLoaderDelegate;
@class JMDashboard;
@class JMDashlet;
@class JMWebEnvironment;

typedef void(^JMDashboardLoaderCompletion)(BOOL success, NSError * __nullable error);

typedef NS_ENUM(NSInteger, JMDashboardLoaderErrorType) {
    JMDashboardLoaderErrorTypeUndefined,
    JMDashboardLoaderErrorTypeEmtpyReport,
    JMDashboardLoaderErrorTypeAuthentification
};

typedef NS_ENUM(NSInteger, JMHyperlinkType) {
    JMHyperlinkTypeLocalPage,
    JMHyperlinkTypeLocalAnchor,
    JMHyperlinkTypeRemotePage,
    JMHyperlinkTypeRemoteAnchor,
    JMHyperlinkTypeReference,
    JMHyperlinkTypeReportExecution,
    JMHyperlinkTypeAdHocExecution
};

@protocol JMDashboardLoader <NSObject>
@property (nonatomic, weak) id<JMDashboardLoaderDelegate> delegate;

- (id<JMDashboardLoader> __nullable)initWithDashboard:(JMDashboard *__nonnull)dashboard webEnvironment:(JMWebEnvironment * __nonnull)webEnvironment;
+ (id<JMDashboardLoader> __nullable)loaderWithDashboard:(JMDashboard *__nonnull)dashboard webEnvironment:(JMWebEnvironment * __nonnull)webEnvironment;

@optional
- (void)loadDashboardWithCompletion:(JMDashboardLoaderCompletion __nonnull) completion;
- (void)reloadDashboardWithCompletion:(JMDashboardLoaderCompletion __nonnull) completion;
- (void)fetchParametersWithCompletion:(JMDashboardLoaderCompletion __nonnull) completion;
- (void)applyParameters:(NSDictionary *__nonnull)parametersAsString;
- (void)maximizeDashlet:(JMDashlet *)dashlet;
- (void)minimizeDashlet:(JMDashlet *)dashlet;
- (void)minimizeDashlet;
- (void)cancel;
- (void)destroy;
- (void)reloadMaximizedDashletWithCompletion:(JMDashboardLoaderCompletion __nonnull) completion;
@end


@protocol JMDashboardLoaderDelegate <NSObject>
- (void)dashboardLoader:(id<JMDashboardLoader> __nonnull)loader didStartMaximazeDashletWithTitle:(NSString * __nonnull)title;
- (void)dashboardLoader:(id<JMDashboardLoader> __nonnull)loader didReceiveHyperlinkWithType:(JMHyperlinkType)hyperlinkType
         resourceLookup:(JSResourceLookup * __nullable)resourceLookup
             parameters:(NSArray * __nullable)parameters;
- (void)dashboardLoaderDidReceiveAuthRequest:(id<JMDashboardLoader> __nonnull)loader;
@end