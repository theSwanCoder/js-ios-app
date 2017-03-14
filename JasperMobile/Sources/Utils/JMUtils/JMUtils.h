/*
 * Copyright ©  2013 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Vlad Zavadskii vzavadskii@jaspersoft.com
 @author Oleksii Gubariev ogubarie@tibco.com
 @since 1.6
 */

#import <Foundation/Foundation.h>
#import "JMServerProfile.h"
#import "JMLoginViewController.h"
#import "JMWebViewManager.h"

@class JMReportViewerConfigurator;
@class JMDashboardViewerConfigurator;
@class JMContentResourceViewerConfigurator;


#define JMLog(...) jmDebugLog(__VA_ARGS__);
void jmDebugLog(NSString * __nonnull format, ...);


@interface JMUtils : NSObject

/**
 Validates report name and directory to store report

 @param reportName A report name to validate. It needs to be unique, without /: characters, not empty, and less or equals than 250 symbols (last 5 are reserved for extension)
 @return YES if report name is valid, otherwise returns NO
 */
+ (BOOL)validateResourceName:(NSString *__nonnull)reportName errorMessage:(NSString *__nullable*__nullable)errorMessage;

/**
 Returns full path of NSDocumentDirectory directory for NSUserDomainMask domain

 @return full path of document directory
*/
+ (NSString *__nonnull)applicationDocumentsDirectory;

+ (NSString *__nonnull)applicationTempDirectory;

/**
 Shows network activity indicator
 */
+ (void)showNetworkActivityIndicator;

/**
 Hides network activity indicator
 */
+ (void)hideNetworkActivityIndicator;

/**
 Checks if current device is iPhone

 @return YES if current device is iPhone
 */
+ (BOOL)isIphone;

/**
 Verify system version is 9
 */
+ (BOOL)isSystemVersionEqualOrUp9;

/**
 Returns YES if crash reports sending is available

 @return YES if crash reports sending is available
 */
+ (BOOL)crashReportsSendingEnable;

+ (BOOL)isAutofillLoginDataEnable;

/**
 Update sending of crash reports
 */
+ (void)activateCrashReportSendingIfNeeded;

+ (NSArray  * __nonnull)supportedFormatsForReportSaving;

+ (NSArray * __nonnull)supportedFormatsForDashboardSaving;

    /**
 Build Version
 */
+ (NSString * __nonnull)buildVersion;

+ (void)showLoginViewAnimated:(BOOL)animated completion:(void (^ __nullable)(void))completion;

+ (void)showLoginViewAnimated:(BOOL)animated completion:(void (^ __nullable)(void))completion loginCompletion:(LoginCompletionBlock __nullable)loginCompletion;

+ (void)showLoginViewForRestoreSessionWithCompletion:(LoginCompletionBlock __nonnull)loginCompletion;

+ (NSString *__nullable)lastUserName;

+ (void)saveLastUserName:(NSString *__nullable)userName;

+ (JMServerProfile *__nullable)lastServerProfile;

+ (void)saveLastServerProfile:(JMServerProfile *__nullable)serverProfile;

+ (void)askUserAgreementWithCompletion:(void (^ __nonnull)(BOOL isAgree))completion;

+ (BOOL)isUserAcceptAgreement;

+ (void)setUserAcceptAgreement:(BOOL)isAccept;

+ (void)presentAlertControllerWithError:(NSError *__nonnull)error completion:(void (^__nullable)(void))completion;

/**
 Returns YES if JRS instance has version equal 6.0 or upper

 @return YES if JRS instance has version equal 6.0 or upper
 */
+ (BOOL)isServerVersionUpOrEqual6;

/**
@return YES if JRS instance has version equal 6.0 or 6.0.1
*/
+ (BOOL)isServerAmber;

/**
 Returns YES if visualize is supported on current JRS instance

 @return YES if visualize is supported on current JRS instance
 */
+ (BOOL)isSupportVisualize;

+ (BOOL)isSupportSearchInSchedules;

/**
 Returns YES if JRS instance has Pro Edition

 @return YES if JRS instance has Pro Edition
 */
+ (BOOL)isServerProEdition;

+ (NSString *__nonnull)localizedStringFromDate:(NSDate *__nonnull)date;

+ (NSDateFormatter *__nonnull)formatterForSimpleDate;

+ (NSDateFormatter *__nonnull)formatterForSimpleTime;

+ (NSDateFormatter *__nonnull)formatterForSimpleDateTime;

+ (UIStoryboard *__nonnull)mainStoryBoard;

+ (UIViewController *__nonnull)launchScreenViewController;

+ (BOOL)isDemoAccount;

+ (JMServerProfile *__nullable)activeServerProfile;

+ (float)minSupportedServerVersion;

+ (JMResourceFlowType)flowTypeForReportViewer;

+ (JMReportViewerConfigurator * __nonnull)reportViewerConfiguratorReusableWebView;

+ (JMReportViewerConfigurator * __nonnull)reportViewerConfiguratorNonReusableWebView;

+ (JMDashboardViewerConfigurator * __nonnull)dashboardViewerConfiguratorReusableWebView;

+ (JMDashboardViewerConfigurator * __nonnull)dashboardViewerConfiguratorNonReusableWebView;

+ (JMContentResourceViewerConfigurator * __nonnull)contentResourceViewerConfigurator;

+ (BOOL)isCompactWidth;

+ (BOOL)isCompactHeight;

@end
