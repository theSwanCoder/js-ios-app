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

@protocol JMDashboardLoaderDelegate;
@class JMDashboard;
@class JMWebEnvironment;
@class JMResource;
@class JMHyperlink;

typedef void(^JMDashboardLoaderCompletion)(BOOL success, NSError * __nullable error);

typedef NS_ENUM(NSInteger, JMDashboardLoaderErrorType) {
    JMDashboardLoaderErrorTypeUndefined,
    JMDashboardLoaderErrorTypeEmtpyReport,
    JMDashboardLoaderErrorTypeAuthentification
};

typedef NS_ENUM(NSInteger, JMDashboardLoaderState) {
    JMDashboardLoaderStateInitial,    // Empty loader without dashboard
    JMDashboardLoaderStateConfigured, // loader with dashboard and environment is ready
    JMDashboardLoaderStateLoading,    //
    JMDashboardLoaderStateReady,      // dashboard ready to interact
    JMDashboardLoaderStateFailed,     //
    JMDashboardLoaderStateDestroy,    //
    JMDashboardLoaderStateCancel      //
};

@protocol JMDashboardLoader <NSObject>
@property (nonatomic, weak, nullable) id<JMDashboardLoaderDelegate> delegate;
@property (nonatomic, strong, readonly, nonnull) JMDashboard *dashboard;
@property (nonatomic, assign, readonly) JMDashboardLoaderState state;
@property (nonatomic, copy, readonly, nonnull) JSRESTBase *restClient;

- (id<JMDashboardLoader> __nullable)initWithRESTClient:(JSRESTBase *__nonnull)restClient
                                        webEnvironment:(JMWebEnvironment * __nonnull)webEnvironment;
+ (id<JMDashboardLoader> __nullable)loaderWithRESTClient:(JSRESTBase *__nonnull)restClient
                                          webEnvironment:(JMWebEnvironment * __nonnull)webEnvironment;

- (void)runDashboard:(JMDashboard *__nonnull)dashboard completion:(JMDashboardLoaderCompletion __nonnull) completion;
- (void)destroy; // TODO: need completion?
- (void)cancel; // TODO: need completion?
@optional
- (void)reloadWithCompletion:(JMDashboardLoaderCompletion __nonnull) completion;
- (void)applyParameters:(NSDictionary <NSString *, NSArray <NSString *>*> *__nonnull)parameters completion:(JMDashboardLoaderCompletion __nonnull) completion;
- (void)reloadDashboardComponent:(JSDashboardComponent *__nonnull)component completion:(JMDashboardLoaderCompletion __nonnull) completion;
- (void)maximizeDashboardComponent:(JSDashboardComponent *__nonnull)component completion:(JMDashboardLoaderCompletion __nonnull) completion;
- (void)minimizeDashboardComponent:(JSDashboardComponent *__nonnull)component completion:(JMDashboardLoaderCompletion __nonnull) completion;
@end


@protocol JMDashboardLoaderDelegate <NSObject>
@optional
- (void)dashboardLoaderDidStartMaximizeDashlet:(id<JMDashboardLoader> __nonnull)loader;
- (void)dashboardLoader:(id<JMDashboardLoader> __nonnull)loader didEndMaximazeDashboardComponent:(JSDashboardComponent *__nonnull)component;
- (void)dashboardLoader:(id<JMDashboardLoader> __nonnull)loader didReceiveEventWithHyperlink:(JMHyperlink *__nonnull)hyperlink;
- (void)dashboardLoaderDidReceiveEventWithUnsupportedHyperlink:(id<JMDashboardLoader> __nonnull)loader;
@end