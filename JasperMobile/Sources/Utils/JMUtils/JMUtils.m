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
//  JMUtils.m
//  TIBCO JasperMobile
//

#import "JMUtils.h"
#import "JMConstants.h"
#import "JMLocalization.h"
#import "JMSavedResources+Helpers.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "JasperMobileAppDelegate.h"
#import "JMMainNavigationController.h"
#import "SWRevealViewController.h"
#import "JMMenuViewController.h"
#import "JMEULAViewController.h"
#import "JMServerProfile+Helpers.h"
#import "JSConstants.h"
#import "JMServersGridViewController.h"
#import "JMServerOptionsViewController.h"


void jmDebugLog(NSString *format, ...) {
#ifndef __RELEASE__
    va_list argumentList;
    va_start(argumentList, format);
    NSMutableString * message = [[NSMutableString alloc] initWithFormat:format
                                                              arguments:argumentList];
    
    [message insertString:@"<JM Debug> " atIndex:0]; //
    NSLogv(message, argumentList); // Originally NSLog is a wrapper around NSLogv.
    va_end(argumentList);
#endif
}

@implementation JMUtils

#define kJMNameMin 1
#define kJMNameMax 250
#define kJMInvalidCharacters     @"~!#$%^|`@&*()-+={}[]:;\"'<>,?/|\\"

+ (BOOL)validateReportName:(NSString *)reportName errorMessage:(NSString **)errorMessage
{
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:kJMInvalidCharacters];
    reportName = [reportName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (reportName.length < kJMNameMin) {
        *errorMessage = JMCustomLocalizedString(@"report.viewer.save.name.errmsg.empty", nil);
    } else if (reportName.length > kJMNameMax) {
        *errorMessage = [NSString stringWithFormat:JMCustomLocalizedString(@"report.viewer.save.name.errmsg.maxlength", nil), kJMNameMax];
    } else if ([reportName rangeOfCharacterFromSet:characterSet].location != NSNotFound) {
        *errorMessage = [NSString stringWithFormat:JMCustomLocalizedString(@"report.viewer.save.name.errmsg.characters", nil), kJMInvalidCharacters];
    }
    return [*errorMessage length] == 0;
}

+ (NSString *)applicationDocumentsDirectory
{
    static NSString *reportDirectory;
    if (!reportDirectory) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        reportDirectory = paths[0];
    }
    return reportDirectory;
}

+ (NSString *)applicationTempDirectory
{
    static NSString *tempDirectory;
    if (!tempDirectory) {
        tempDirectory = NSTemporaryDirectory();
    }
    return tempDirectory;
}

+ (void)showNetworkActivityIndicator
{
    [[AFNetworkActivityIndicatorManager sharedManager] incrementActivityCount];
}

+ (void)hideNetworkActivityIndicator
{
    [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
}

+ (BOOL)isIphone
{
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone;
}

+ (BOOL)isSystemVersion9
{
    return [UIDevice currentDevice].systemVersion.integerValue == 9;
}

+ (BOOL)crashReportsSendingEnable
{
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kJMDefaultSendingCrashReport]) {
        [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:kJMDefaultSendingCrashReport];
    }

    id crashReportsSettings = [[NSUserDefaults standardUserDefaults] objectForKey:kJMDefaultSendingCrashReport];
    if (crashReportsSettings) {
        return [crashReportsSettings boolValue];
    }
    return YES;
}

+ (void)activateCrashReportSendingIfNeeded
{
    if ([self crashReportsSendingEnable]) {
        [Fabric with:@[
                       [Crashlytics class]
                       ]];
    }
}

+ (NSArray *)supportedFormatsForReportSaving
{
    static NSArray *reportFormats;
    if (!reportFormats) {
        reportFormats = @[
                           kJS_CONTENT_TYPE_HTML,
                           kJS_CONTENT_TYPE_PDF,
                           kJS_CONTENT_TYPE_XLS,
                           ];
    }
    return reportFormats;
}

+ (NSString *)buildVersion
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle]infoDictionary];
    return infoDictionary[(NSString*)kCFBundleVersionKey];
}

#pragma mark - Login VC

+ (void)showLoginViewAnimated:(BOOL)animated completion:(void (^)(void))completion
{
    [self showLoginViewAnimated:animated completion:completion loginCompletion:nil];
}

+ (void)showLoginViewAnimated:(BOOL)animated completion:(void (^)(void))completion loginCompletion:(LoginCompletionBlock)loginCompletion
{
    [self showLoginViewWithRestoreSession:NO animated:animated completion:completion loginCompletion:loginCompletion];
}

+ (void)showLoginViewForRestoreSessionWithCompletion:(LoginCompletionBlock)loginCompletion
{
    [self showLoginViewWithRestoreSession:YES animated:YES completion:nil loginCompletion:loginCompletion];
}

+ (void)showLoginViewWithRestoreSession:(BOOL)restoreSession animated:(BOOL)animated completion:(void (^)(void))completion loginCompletion:(LoginCompletionBlock)loginCompletion
{
    if (!restoreSession) {
        [[JMSessionManager sharedManager] logout];
    }

    SWRevealViewController *revealViewController = (SWRevealViewController *) [UIApplication sharedApplication].delegate.window.rootViewController;
    JMMenuViewController *menuViewController = (JMMenuViewController *) revealViewController.rearViewController;

    BOOL isPresentedByNavVC = [revealViewController.presentedViewController isKindOfClass:[UINavigationController class]];
    BOOL isLoginVC = [((UINavigationController *) revealViewController.presentedViewController).topViewController isKindOfClass:[JMLoginViewController class]];
    BOOL isServersVC = [((UINavigationController *) revealViewController.presentedViewController).topViewController isKindOfClass:[JMServersGridViewController class]];
    BOOL isNewServerVC = [((UINavigationController *) revealViewController.presentedViewController).topViewController isKindOfClass:[JMServerOptionsViewController class]];
    if (isPresentedByNavVC && (isLoginVC || isServersVC || isNewServerVC)) {
        // if a nav view controller was loaded previously
        return;
    }

    UINavigationController *loginNavController = (UINavigationController *) [revealViewController.storyboard instantiateViewControllerWithIdentifier:@"JMLoginNavigationViewController"];
    JMLoginViewController *loginViewController = (JMLoginViewController *)loginNavController.topViewController;
    loginViewController.showForRestoreSession = restoreSession;
    loginViewController.completion = ^(void){
        if (loginCompletion) {
            loginCompletion();
        } else {
            [menuViewController setSelectedItemIndex:[JMMenuViewController defaultItemIndex]];
        }
    };

    [revealViewController presentViewController:loginNavController animated:animated completion:completion];
}

#pragma mark - EULA
+ (void)askUserAgreementWithCompletion:(void(^ __nonnull)(BOOL isAgree))completion
{
    // get key
    BOOL isAccept = [self isUserAcceptAgreement];
    if (isAccept) {
        completion(YES);
    } else {
        // show text of agreement
        UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;

        JMEULAViewController *EULAViewController = (JMEULAViewController *) [rootViewController.storyboard instantiateViewControllerWithIdentifier:@"JMEULAViewController"];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:EULAViewController];
        EULAViewController.shouldUserAccept = YES;
        EULAViewController.completion = ^{
            [rootViewController dismissViewControllerAnimated:YES completion:nil];
            [self setUserAcceptAgreement:YES];
            completion(YES);
        };

        if (rootViewController.presentedViewController && [rootViewController.presentedViewController isKindOfClass:[UINavigationController class]]) {
            return;
        } else if (rootViewController.presentedViewController && ![rootViewController.presentedViewController isKindOfClass:[UINavigationController class]]) {
            [rootViewController dismissViewControllerAnimated:YES completion:nil];
        }

        [rootViewController presentViewController:navController
                                         animated:YES
                                       completion:nil];
    }
}

+ (BOOL)isUserAcceptAgreement
{
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kJMUserAcceptAgreement]) {
        [[NSUserDefaults standardUserDefaults] setObject:@(NO)
                                                  forKey:kJMUserAcceptAgreement];
    }

    BOOL isAccept = ((NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:kJMUserAcceptAgreement]).boolValue;

    return isAccept;
}

+ (void)setUserAcceptAgreement:(BOOL)isAccept
{
    [[NSUserDefaults standardUserDefaults] setObject:@(isAccept)
                                              forKey:kJMUserAcceptAgreement];
}

#pragma mark - Alerts

+ (void)presentAlertControllerWithError:(NSError *)error completion:(void (^)(void))completion
{
    NSString *sourceString = [[NSThread callStackSymbols] objectAtIndex:1];
    
    NSCharacterSet *separatorSet = [NSCharacterSet characterSetWithCharactersInString:@" -[]+?.,"];
    NSMutableArray *array = [NSMutableArray arrayWithArray:[sourceString  componentsSeparatedByCharactersInSet:separatorSet]];
    [array removeObject:@""];
    
    NSLog(@"Class caller = %@", [array objectAtIndex:3]);
    NSLog(@"Method caller = %@", [array objectAtIndex:4]);
    
    NSString *title = error.domain;
    NSString *message = error.localizedDescription;
//    if (![title isEqualToString:@"dialod.title.error"]) {
//        title = @"error.readingresponse.dialog.msg";
//    }
    if (error.code == JSInvalidCredentialsErrorCode) {
        title = @"error.authenication.dialog.title";
        message = @"error.authenication.dialog.msg";
    }

    UIAlertController *alertController = [UIAlertController alertControllerWithLocalizedTitle:title message:message cancelButtonTitle:@"dialog.button.ok" cancelCompletionHandler:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action) {
        if (completion) {
            completion();
        }
    }];

    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    if (rootViewController.presentedViewController) {
        rootViewController = rootViewController.presentedViewController;
    }
    [rootViewController presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Helpers

+ (BOOL)shouldUseVisualize
{
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kJMDefaultUseVisualize]) {
        [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:kJMDefaultUseVisualize];
    }

    id useVisualizeSettings = [[NSUserDefaults standardUserDefaults] objectForKey:kJMDefaultUseVisualize];
    if (useVisualizeSettings) {
        return [useVisualizeSettings boolValue];
    }
    return YES;
}

+ (BOOL)isSupportVisualize
{
    return [self shouldUseVisualize] && [self isServerVersionUpOrEqual6] && [self isServerProEdition];
}

+ (BOOL)isServerVersionUpOrEqual6
{
    return self.restClient.serverProfile.serverInfo.versionAsFloat >= kJS_SERVER_VERSION_CODE_AMBER_6_0_0;
}

+ (BOOL)isServerAmber2
{
    return self.restClient.serverProfile.serverInfo.versionAsFloat == kJS_SERVER_VERSION_CODE_AMBER_6_1_0;
}

+ (BOOL)isServerAmber2OrHigher
{
    return self.restClient.serverProfile.serverInfo.versionAsFloat >= kJS_SERVER_VERSION_CODE_AMBER_6_1_0;
}

+ (BOOL)isServerProEdition
{
    return [self.restClient.serverProfile.serverInfo.edition isEqualToString: kJS_SERVER_EDITION_PRO];
}

+ (NSString *)localizedStringFromDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    [dateFormatter setLocale:[NSLocale currentLocale]];

    return [dateFormatter stringFromDate:date];
}

+ (NSDateFormatter *)formatterForSimpleDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setLocale:[NSLocale currentLocale]];

    return dateFormatter;
}

+ (NSDateFormatter *)formatterForSimpleTime
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    [dateFormatter setLocale:[NSLocale currentLocale]];

    return dateFormatter;
}

+ (NSDateFormatter *)formatterForSimpleDateTime
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    [dateFormatter setLocale:[NSLocale currentLocale]];

    return dateFormatter;
}

+ (UIStoryboard *)mainStoryBoard
{
    static dispatch_once_t onceToken;
    static UIStoryboard * mainStoryboard;
    dispatch_once(&onceToken, ^{
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *storyboardName = [bundle objectForInfoDictionaryKey:@"UIMainStoryboardFile"];
        mainStoryboard = [UIStoryboard storyboardWithName:storyboardName bundle:bundle];
    });
    return mainStoryboard;
}

+ (UIViewController *)launchScreenViewController
{
    static dispatch_once_t onceToken;
    static UIStoryboard * launchStoryboard;
    dispatch_once(&onceToken, ^{
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *storyboardName = [bundle objectForInfoDictionaryKey:@"UILaunchStoryboardName"];
        launchStoryboard = [UIStoryboard storyboardWithName:storyboardName bundle:bundle];
    });
    return [launchStoryboard instantiateInitialViewController];
}

+ (BOOL)isCompactWidth
{
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    return (rootViewController.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact);
}

+ (BOOL)isCompactHeight
{
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    return (rootViewController.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact);
}

+ (BOOL)isDemoAccount
{
    BOOL isDemoServer = [self.restClient.serverProfile.serverUrl isEqualToString:kJMDemoServerUrl];
    BOOL isDemoUser = [self.restClient.serverProfile.username isEqualToString:kJMDemoServerUsername];
    BOOL isDemoOrganization = [self.restClient.serverProfile.organization isEqualToString:kJMDemoServerOrganization];
    BOOL isDemoAccount = isDemoServer && isDemoUser && isDemoOrganization;
    return isDemoAccount;
}

#pragma mark - Analytics
+ (void)logEventWithInfo:(NSDictionary *)eventInfo
{
#ifndef __RELEASE__
    NSString *version = self.restClient.serverInfo.version;
    NSString *edition = self.restClient.serverInfo.edition;
    if ([JMUtils isDemoAccount]) {
        version = [version stringByAppendingString:@"(Demo)"];
    }
    
    // Crashlytics - Answers
    NSMutableDictionary *extendedEventInfo = [eventInfo mutableCopy];
    extendedEventInfo[kJMAnalyticsServerVersionKey] = version;
    extendedEventInfo[kJMAnalyticsServerEditionKey] = edition;
    [Answers logCustomEventWithName:eventInfo[kJMAnalyticsCategoryKey]
                   customAttributes:extendedEventInfo];

    // Google Analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    GAIDictionaryBuilder *builder = [GAIDictionaryBuilder createEventWithCategory:eventInfo[kJMAnalyticsCategoryKey]                 // Event category (required)
                                                                           action:eventInfo[kJMAnalyticsActionKey]                   // Event action (required)
                                                                            label:eventInfo[kJMAnalyticsLabelKey]                    // Event label
                                                                            value:nil];                                              // Event value
    [tracker set:[GAIFields customDimensionForIndex:kJMAnalyticsCustomDimensionServerVersionIndex]
           value:version];
    [tracker set:[GAIFields customDimensionForIndex:kJMAnalyticsCustomDimensionServerEditionIndex]
           value:edition];

    [tracker send:[builder build]];
#endif
}

+ (void)logLoginSuccess:(BOOL)success additionInfo:(NSDictionary *)additionInfo
{
#ifndef __RELEASE__
    NSString *version = self.restClient.serverInfo.version;
    NSString *edition = self.restClient.serverInfo.edition;
    if ([JMUtils isDemoAccount]) {
        version = [version stringByAppendingString:@"(Demo)"];
    }

    // Crashlytics - Answers
    NSMutableDictionary *extendedEventInfo = [additionInfo mutableCopy];
    extendedEventInfo[kJMAnalyticsServerVersionKey] = version;
    extendedEventInfo[kJMAnalyticsServerEditionKey] = edition;
    [Answers logLoginWithMethod:@"Digits"
                        success:@(success)
               customAttributes:extendedEventInfo];
    
    // Google Analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    GAIDictionaryBuilder *builder = [GAIDictionaryBuilder createEventWithCategory:additionInfo[kJMAnalyticsCategoryKey]                 // Event category (required)
                                                                           action:additionInfo[kJMAnalyticsActionKey]                   // Event action (required)
                                                                            label:additionInfo[kJMAnalyticsLabelKey]                    // Event label
                                                                            value:nil];                                                 // Event value
    [tracker set:[GAIFields customDimensionForIndex:kJMAnalyticsCustomDimensionServerVersionIndex]
           value:version];
    [tracker set:[GAIFields customDimensionForIndex:kJMAnalyticsCustomDimensionServerEditionIndex]
           value:edition];

    [tracker send:[builder build]];
#endif
}

@end
