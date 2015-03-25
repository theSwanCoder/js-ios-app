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

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>


@implementation JMUtils

#define kJMNameMin 1
#define kJMNameMax 250
#define kJMInvalidCharacters     @"~!#$%^|`@&*()-+={}[]:;\"'<>,?/|\\"

+ (BOOL)validateReportName:(NSString *)reportName extension:(NSString *)extension errorMessage:(NSString **)errorMessage
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
        reportDirectory = [paths objectAtIndex:0];
    }
    return reportDirectory;
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

+ (BOOL)isSystemVersion7
{
    return [UIDevice currentDevice].systemVersion.integerValue < 8;
}

+ (NSManagedObjectContext *)managedObjectContext
{
    JasperMobileAppDelegate *appDelegate = (JasperMobileAppDelegate*) [UIApplication sharedApplication].delegate;
    return appDelegate.managedObjectContext;
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
        [Fabric with:@[CrashlyticsKit]];
    }
}

+ (NSArray *)supportedFormatsForReportSaving
{
    static NSArray *reportFormats;
    if (!reportFormats) {
        reportFormats = @[
                           [JSConstants sharedInstance].CONTENT_TYPE_HTML,
                           [JSConstants sharedInstance].CONTENT_TYPE_PDF,
                           ];
    }
    return reportFormats;
}

+ (NSString *)buildVersion
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle]infoDictionary];
    return infoDictionary[(NSString*)kCFBundleVersionKey];
}


+ (void)showLoginViewAnimated:(BOOL)animated completion:(LoginCompletionBlock)completion
{
    SWRevealViewController *revealViewController = (SWRevealViewController *) [UIApplication sharedApplication].delegate.window.rootViewController;

    UINavigationController *loginNavController = [revealViewController.storyboard instantiateViewControllerWithIdentifier:@"JMLoginNavigationViewController"];
    JMLoginViewController *loginViewController = (JMLoginViewController *)loginNavController.topViewController;
    loginViewController.completion = completion;
    [revealViewController.rearViewController presentViewController:loginNavController animated:animated completion:nil];
}

+ (void)showAlertViewWithError:(NSError *)error
{
    NSString *title = JMCustomLocalizedString(@"error.readingresponse.dialog.msg", nil);
    NSString *message = error.localizedDescription;
    if (error.code == JSInvalidCredentialsErrorCode) {
        title = JMCustomLocalizedString(@"error.authenication.dialog.title", nil);
        message = JMCustomLocalizedString(@"error.authenication.dialog.msg", nil);
    }

    [[[UIAlertView alloc] initWithTitle:title
                                message:message
                               delegate:nil
                      cancelButtonTitle:JMCustomLocalizedString(@"dialog.button.ok", nil)
                      otherButtonTitles: nil] show];
}

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

+ (BOOL)isServerProEdition
{
    return [self.restClient.serverProfile.serverInfo.edition isEqualToString: [JSConstants sharedInstance].SERVER_EDITION_PRO];
}

@end
