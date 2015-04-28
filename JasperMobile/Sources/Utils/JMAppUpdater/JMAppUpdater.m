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
//  JMAppUpdater.m
//  TIBCO JasperMobile
//

#import "JMAppUpdater.h"
#import "JMConstants.h"
#import "JMFavorites.h"
#import "JMServerProfile+Helpers.h"
#import "JMSavedResources+Helpers.h"

// Key for app version
static NSString * const kJMApplicationVersion = @"CFBundleShortVersionString";

// Error message
static NSString * errorMessage = nil;

// Old constants used in previous versions of application
static NSString * const kJMDefaultsUpdatedVersions = @"jaspersoft.mobile.updated.versions";

@implementation JMAppUpdater

// Fill migrations with update methods for different versions

#pragma mark - Class methods

+ (void)update
{
    if ([[JMCoreDataManager sharedInstance] isMigrationNeeded]) {
        [[JMCoreDataManager sharedInstance] migrate:nil];
    }
    NSNumber *latestAppVersion = [self latestAppVersion];
    NSNumber *currentAppVersion = [self currentAppVersion];
    if (currentAppVersion != nil && [currentAppVersion compare:latestAppVersion] == NSOrderedSame) return;
    
    NSMutableDictionary *versionsToUpdate = [NSMutableDictionary dictionary];
    
    // Add update methods
    [versionsToUpdate setObject:[NSValue valueWithPointer:@selector(update_1_9)] forKey:@1.9];

    for (NSNumber *version in versionsToUpdate.allKeys) {
        if (version.doubleValue <= currentAppVersion.doubleValue) continue;
        
        SEL selector = [versionsToUpdate[version] pointerValue];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:selector]];
        invocation.selector = selector;
        invocation.target = self;
        [invocation invoke];
        
        BOOL *updateResult;
        [invocation getReturnValue:&updateResult];
        
        if (updateResult) {
            // Update app version for each migration. This allows to track which migration was failed
            [self updateAppVersionTo:version];
            errorMessage = nil;
        }
    }

    if ([self hasErrors]) {
        [self showErrors];
    }
}

+ (void)updateAppVersionTo:(NSNumber *)appVersion
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:appVersion forKey:kJMDefaultsCurrentVersion];
    [defaults synchronize];
}

+ (NSNumber *)latestAppVersion
{
    NSString *appVersion = [self latestAppVersionAsString];
    return [NSNumber numberWithDouble:[appVersion doubleValue]];
}

+ (NSString *)latestAppVersionAsString
{
    return [[NSBundle mainBundle].infoDictionary objectForKey:kJMApplicationVersion];
}

+ (NSNumber *)currentAppVersion
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kJMDefaultsCurrentVersion];
}

+ (BOOL)hasErrors
{
    return errorMessage.length != 0;
}

+ (BOOL)isRunningForTheFirstTime
{
    return (![self currentAppVersion]);
}

#pragma mark - Migration methods

// Add saved report to CoreData
+ (BOOL)update_1_9
{
    NSString *reportsDirectory = [[JMUtils applicationDocumentsDirectory] stringByAppendingPathComponent:kJMReportsDirectory];
    NSMutableArray *reports = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:reportsDirectory error:nil] mutableCopy];
    [reports removeObject:@".DS_Store"];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    for (NSString *report in reports) {
        BOOL isReportDirectory = NO;
        if ([fileManager fileExistsAtPath:[reportsDirectory stringByAppendingPathComponent:report] isDirectory:&isReportDirectory] && isReportDirectory) {
            NSRange reportExtensionRange = [report rangeOfString:@"." options:NSBackwardsSearch];
            NSString *reportExtension = [report substringFromIndex:reportExtensionRange.location];
            NSString *reportName = [report stringByReplacingOccurrencesOfString:reportExtension withString:@""];
            
            JSResourceLookup *resource = [JSResourceLookup new];
            resource.resourceType = [JSConstants sharedInstance].WS_TYPE_REPORT_UNIT;
            
            [JMSavedResources addReport:resource withName:reportName format:[reportExtension stringByReplacingOccurrencesOfString:@"." withString:@""]];
        }
    }

    return YES;
}

#pragma mark - Alert view delegate methods

+ (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [JMAppUpdater update];
    } else if (buttonIndex == 2) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kJMResetApplicationNotification
                                                            object:nil];
    } else {
        abort();
    }
}

#pragma mark - Private

+ (void)showErrors
{
    [[UIAlertView localizedAlertWithTitle:@"error.upgrade.data.title"
                                  message:errorMessage
                                 delegate:JMAppUpdater.class
                        cancelButtonTitle:@"dialog.button.cancel"
                        otherButtonTitles:@"dialog.button.retry", @"dialog.button.applyUpdate", nil] show];
    errorMessage = nil;
}

@end
