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
#import <SplunkMint-iOS/SplunkMint-iOS.h>

@implementation JMUtils

#define kJMNameMin 1
#define kJMNameMax 250
#define kJMInvalidCharacters @":/"
+ (BOOL)validateReportName:(NSString *)reportName extension:(NSString *)extension errorMessage:(NSString **)errorMessage
{
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:kJMInvalidCharacters];

    if (reportName.length < kJMNameMin) {
        *errorMessage = JMCustomLocalizedString(@"savereport.name.errmsg.empty", nil);
    } else if (reportName.length > kJMNameMax) {
        *errorMessage = [NSString stringWithFormat:JMCustomLocalizedString(@"savereport.name.errmsg.maxlength", nil), kJMNameMax];
    } else if ([reportName rangeOfCharacterFromSet:characterSet].location != NSNotFound) {
        *errorMessage = JMCustomLocalizedString(@"savereport.name.errmsg.characters", nil);
    } else {
        if (![JMSavedResources isAvailableReportName:reportName]) {
            *errorMessage = JMCustomLocalizedString(@"savereport.name.errmsg.notunique", nil);
        }
    }

    return [*errorMessage length] == 0;
}

+ (NSString *)documentsDirectoryPath
{
    static NSString *reportDirectory;
    if (!reportDirectory) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        reportDirectory = [paths objectAtIndex:0];
    }
    return reportDirectory;
}

+ (void)sendChangeServerProfileNotificationWithProfile:(JMServerProfile *)serverProfile withParams:(NSDictionary *)params
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:params];
    if (serverProfile) {
        [userInfo setObject:serverProfile forKey:kJMServerProfileKey];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kJMChangeServerProfileNotification
                                                        object:nil
                                                      userInfo:userInfo];
}

+ (void)showNetworkActivityIndicator
{
    UIApplication *application = [UIApplication sharedApplication];
    if (!application.networkActivityIndicatorVisible) {
        application.networkActivityIndicatorVisible = YES;
    }
}

+ (void)hideNetworkActivityIndicator
{
    UIApplication *application = [UIApplication sharedApplication];
    if (application.networkActivityIndicatorVisible) {
        application.networkActivityIndicatorVisible = NO;
    }
}

+ (BOOL)isIphone
{
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone;

}

+ (NSManagedObjectContext *)managedObjectContext
{
    JSObjectionInjector *injector = [JSObjection defaultInjector];
    return [injector getObject:[NSManagedObjectContext class]];
}

+ (BOOL)crashReportsSendingEnable
{
    id crashReportsSettings = [[NSUserDefaults standardUserDefaults] objectForKey:kJMDefaultSendingCrashReport];
    if (crashReportsSettings) {
        return [crashReportsSettings boolValue];
    }
    return YES;
}

+ (void)activateCrashReportSendingIfNeeded
{
    if ([self crashReportsSendingEnable] && ![Mint sharedInstance].isSessionActive) {
        [[Mint sharedInstance] initAndStartSession:kJMMintSplunkApiKey];
        [[Mint sharedInstance] enableLogging:YES];
    } else if (![self crashReportsSendingEnable]) {
        [[Mint sharedInstance] closeSessionAsyncWithCompletionBlock:nil];
    }
}
@end
