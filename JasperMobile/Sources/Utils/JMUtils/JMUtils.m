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
        NSMutableString *invalidCharsString = [NSMutableString string];

        NSInteger subLocation = 0;
        while (subLocation < (reportName.length)) {
            NSString *subString = [reportName substringWithRange:NSMakeRange(subLocation ++, 1)];
            if ([kJMInvalidCharacters rangeOfString:subString].location != NSNotFound) {
                if ([invalidCharsString length]) {
                    [invalidCharsString appendString:@", "];
                }
                [invalidCharsString appendFormat:@"'%@'", subString];
            }

        }
        *errorMessage = [NSString stringWithFormat:JMCustomLocalizedString(@"report.viewer.save.name.errmsg.characters", nil), invalidCharsString];
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
                           [JSConstants sharedInstance].CONTENT_TYPE_HTML,
                           [JSConstants sharedInstance].CONTENT_TYPE_PDF,
                           [JSConstants sharedInstance].CONTENT_TYPE_XLS,
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

    if ([revealViewController.presentedViewController isKindOfClass:[UINavigationController class]] &&
            [((UINavigationController *) revealViewController.presentedViewController).topViewController isKindOfClass:[JMLoginViewController class]]) {
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
    return self.restClient.serverProfile.serverInfo.versionAsFloat >= [JSConstants sharedInstance].SERVER_VERSION_CODE_AMBER_6_0_0;
}

+ (BOOL)isServerAmber2
{
    return self.restClient.serverProfile.serverInfo.versionAsFloat == [JSConstants sharedInstance].SERVER_VERSION_CODE_AMBER_6_1_0;
}

+ (BOOL)isServerAmber2OrHigher
{
    return self.restClient.serverProfile.serverInfo.versionAsFloat >= [JSConstants sharedInstance].SERVER_VERSION_CODE_AMBER_6_1_0;
}

+ (BOOL)isServerProEdition
{
    return [self.restClient.serverProfile.serverInfo.edition isEqualToString: [JSConstants sharedInstance].SERVER_EDITION_PRO];
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
    BOOL isDemoAccount = [self.restClient.serverProfile.serverUrl isEqualToString:[JMServerProfile demoServerProfile].serverUrl];
    return isDemoAccount;
}

#pragma mark - Analytics
+ (void)logEventWithName:(NSString *)eventName additionInfo:(NSDictionary *)additionInfo
{
    // Disable analytics for demo profile
    if ([self isDemoAccount]) {
        return;
    }

    // Crashlytics - Answers
    [Answers logCustomEventWithName:eventName
                   customAttributes:additionInfo];

    // Google Analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:eventName                                           // Event category (required)
                                                          action:[additionInfo allKeys].firstObject                  // Event action (required)
                                                           label:[additionInfo allValues].firstObject                // Event label
                                                           value:nil] build]];                                       // Event value

}

+ (void)logLoginSuccess:(BOOL)success additionInfo:(NSDictionary *)additionInfo
{
    // Disable analytics for demo profile
    if ([self isDemoAccount]) {
        return;
    }

    // Crashlytics - Answers
    [Answers logLoginWithMethod:@"Digits"
                        success:@(success)
               customAttributes:additionInfo];

    // Google Analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    NSString *action = success ? @"Login_Success" : @"Login_Failed";
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:action                                              // Event category (required)
                                                          action:[additionInfo allKeys].firstObject                  // Event action (required)
                                                           label:[additionInfo allValues].firstObject                // Event label
                                                           value:nil] build]];                                       // Event value
}

@end
