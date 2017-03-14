/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
@author Oleksandr Dahno odahno@tibco.com
@since 2.1
*/

#import "JaspersoftSDK.h"

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
- (void)dashboardLoader:(id<JMDashboardLoader> __nonnull)loader didStartMaximizeDashboardComponent:(JSDashboardComponent *__nonnull)component;
- (void)dashboardLoader:(id<JMDashboardLoader> __nonnull)loader didEndMaximazeDashboardComponent:(JSDashboardComponent *__nonnull)component;
- (void)dashboardLoader:(id<JMDashboardLoader> __nonnull)loader didStartMinimizeDashboardComponent:(JSDashboardComponent *__nonnull)component;
- (void)dashboardLoader:(id<JMDashboardLoader> __nonnull)loader didEndMinimizeDashboardComponent:(JSDashboardComponent *__nonnull)component;
- (void)dashboardLoader:(id<JMDashboardLoader> __nonnull)loader didReceiveEventWithHyperlink:(JMHyperlink *__nonnull)hyperlink;
- (void)dashboardLoaderDidReceiveEventWithUnsupportedHyperlink:(id<JMDashboardLoader> __nonnull)loader;
- (void)dashboardLoader:(id<JMDashboardLoader> __nonnull)loader didRecieveError:(NSError *__nonnull)error;
@end
