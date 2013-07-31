/*
 * JasperMobile for iOS
 * Copyright (C) 2011 - 2013 Jaspersoft Corporation. All rights reserved.
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
//  Jaspersoft Corporation
//

#import "JMAppUpdater.h"
#import "JMConstants.h"
#import "JMFavorites.h"
#import "JMLocalization.h"
#import "JMServerProfile+Helpers.h"
#import "UIAlertView+LocalizedAlert.h"
#import <Objection-iOS/Objection.h>

// Contains version:method structure. Method updates specific part of application for specific app version
static NSDictionary *versionsToUpdate = nil;

// Key for app version
static NSString * const kJMApplicationVersion = @"CFBundleShortVersionString";

// Error message
static NSString * errorMessage = nil;

// Delegate for UIAlertView
static JMAppUpdater *delegate;

// Context to work with database
static NSManagedObjectContext * managedObjectContext;

@implementation JMAppUpdater

// Fill migrations with update methods for different versions
+ (void)initialize
{
    NSMutableDictionary *temp = [NSMutableDictionary dictionary];
    
    // Add update methods
    [temp setObject:[NSValue valueWithPointer:@selector(update_1_2)] forKey:@1.2];
    [temp setObject:[NSValue valueWithPointer:@selector(update_1_5)] forKey:@1.5];
    
    versionsToUpdate = temp;
    managedObjectContext = [[JSObjection defaultInjector] getObject:[NSManagedObjectContext class]];
}

#pragma mark - Class methods

// TODO: test!!!
+ (void)update
{
    NSNumber *latestAppVersion = [self latestAppVersion];
    NSNumber *currentAppVersion = [self currentAppVersion];
    
    if (currentAppVersion == nil || [currentAppVersion compare:latestAppVersion] == 0) {
        return;
    }
    
    for (NSNumber *version in versionsToUpdate.allKeys) {
        SEL selector = [[versionsToUpdate objectForKey:version] pointerValue];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:selector]];
        invocation.selector = selector;
        invocation.target = self;
        [invocation invoke];
        
        BOOL *updateResult;
        [invocation getReturnValue:&updateResult];
        
        if ([currentAppVersion compare:version] == -1 && updateResult) {
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
    NSString *appVersion = [[NSBundle mainBundle].infoDictionary objectForKey:kJMApplicationVersion];
    return [NSNumber numberWithDouble:[appVersion doubleValue]];
}

+ (NSNumber *)currentAppVersion
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kJMDefaultsCurrentVersion];
}

+ (BOOL)hasErrors
{
    return errorMessage != nil;
}

#pragma mark - Migration methods

// Moves password for profiles from NSUserDefaults to keychain
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
+ (BOOL)update_1_2
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger count = [defaults integerForKey:kJMDefaultsCount];
    
    for (int i = 0; i < count; i++) {
        NSString *serverUrl = [defaults objectForKey:[NSString stringWithFormat:kJMDefaultsServerBaseUrl, i]];
        NSString *username = [defaults objectForKey:[NSString stringWithFormat:kJMDefaultsServerUsername, i]];
        NSString *organization = [defaults objectForKey:[NSString stringWithFormat:kJMDefaultsServerOrganization, i]];
        NSString *password = [defaults objectForKey:[NSString stringWithFormat:kJMDefaultsServerPassword, i]];
        NSString *profileID = [JMServerProfile profileIDByServerURL:serverUrl username:username organization:organization];
        [JMServerProfile storePasswordInKeychain:password profileID:profileID];
        [defaults removeObjectForKey:[NSString stringWithFormat:kJMDefaultsServerPassword, i]];
    }
    
    return [defaults synchronize];
}

// Moves all data from NSUserDefaults persistent Map to SQLite database
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
+ (BOOL)update_1_5 
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // Get number of stored profiles
    NSInteger count = [defaults integerForKey:kJMDefaultsCount];
    // Get current active server (if exists)
    NSInteger activeServerIndex = [defaults integerForKey:kJMDefaultsActiveServer];
    // Keys which will be removed from NSUserDefaults (clear defaults from unnecessary data)
    NSMutableSet *keysToRemove = [[NSMutableSet alloc] init];
    // Active server profile
    JMServerProfile *activeServeProfile = nil;
    
    for (int i = 0; i < count; i++) {
        // Create keys for profile's fields stored in NSUserDefaults (persistent Map)
        // In NSUserDefauls profile's data looks like: {
        //      "jaspersoft.server.alias.0" : "Alias 0",
        //      "jaspersoft.server.username.0" : "Username 0",
        //      ...
        // }
        // Wheres 0 - profile position (or "id" as in relation databases)
        NSString *keyAlias = [NSString stringWithFormat:kJMDefaultsServerAlias, i];
        NSString *keyServerBaseUrl = [NSString stringWithFormat:kJMDefaultsServerBaseUrl, i];
        NSString *keyUsername = [NSString stringWithFormat:kJMDefaultsServerUsername, i];
        NSString *keyOrganization = [NSString stringWithFormat:kJMDefaultsServerOrganization, i];
        NSString *keyAlwaysAskPassword = [NSString stringWithFormat:kJMDefaultsServerAlwaysAskPassword, i];
        NSString *keyFavorites = [NSString stringWithFormat:kJMDefaultsFavorites, i];
        
        // Create and configure ServerProfile instance (not saved to database yet, only in-memory changes)
        JMServerProfile *serverProfile = [NSEntityDescription insertNewObjectForEntityForName:@"ServerProfile" inManagedObjectContext:managedObjectContext];
        serverProfile.alias = [defaults objectForKey:keyAlias];
        serverProfile.serverUrl = [defaults objectForKey:keyServerBaseUrl];
        serverProfile.username = [defaults objectForKey:keyUsername];
        serverProfile.organization = [defaults objectForKey:keyOrganization];
        serverProfile.askPassword = [defaults objectForKey:keyAlwaysAskPassword] ?: [NSNumber numberWithBool:NO];
        
        if (activeServerIndex == i) {
            activeServeProfile = serverProfile;
        }
        
        // Get all favorites from user defaults structured by "username|organization" or "username" key patterns
        NSDictionary *oldFavorites = [defaults objectForKey:keyFavorites];
        NSArray *usenameWithOrganizationValues = [oldFavorites allKeys];
        for (NSString *usernameWithOrganizationValue in usenameWithOrganizationValues) {
            // Get all favorites for UserWithOrg key
            NSDictionary *oldFavoritesForUserWithOrgValue = [oldFavorites objectForKey:usernameWithOrganizationValue];
            
            // Get separately username and organization
            NSArray *components = [usernameWithOrganizationValue componentsSeparatedByString:@"|"];
            NSString *username = [components objectAtIndex:0];
            NSString *organization = [components count] > 1 ? [components objectAtIndex:1] : @"";
            
            NSArray *uriList = [oldFavoritesForUserWithOrgValue allKeys];
            for (NSString *uri in uriList) {
                NSDictionary *oldFavoriteForUserWithOrgValue = [oldFavoritesForUserWithOrgValue objectForKey:uri];
                // Creating and configuring Favorites instance
                JMFavorites *favorites = [NSEntityDescription insertNewObjectForEntityForName:@"Favorites" inManagedObjectContext:managedObjectContext];
                favorites.uri = uri;
                favorites.label = [oldFavoriteForUserWithOrgValue objectForKey:@"label"];
                favorites.wsType = [oldFavoriteForUserWithOrgValue objectForKey:@"wsType"];
                favorites.username = username;
                favorites.organization = organization;
                [serverProfile addFavoritesObject:favorites];
            }
        }
        
        [keysToRemove addObject:keyAlias];
        [keysToRemove addObject:keyServerBaseUrl];
        [keysToRemove addObject:keyUsername];
        [keysToRemove addObject:keyOrganization];
        [keysToRemove addObject:keyAlwaysAskPassword];
        [keysToRemove addObject:keyFavorites];
    }
    
    NSError *error = nil;
    if ([managedObjectContext hasChanges]) {
        [managedObjectContext save:&error];
    }
    
    if (error != nil) {
        errorMessage = JMCustomLocalizedString(@"error.upgrade.data.msg", nil);
        return NO;
    } else {
        // Change location for firstRun value and delete unnecessary data
        NSInteger firstRun = [defaults integerForKey:kJMDefaultsFirstRun];
        [defaults setInteger:firstRun forKey:kJMDefaultsNotFirstRun];
        [defaults removeObjectForKey:kJMDefaultsFirstRun];
        [defaults removeObjectForKey:kJMDefaultsUpdatedVersions];
        [defaults removeObjectForKey:kJMDefaultsCount];
        
        for (NSString *keyToRemove in [keysToRemove allObjects]) {
            [defaults removeObjectForKey:keyToRemove];
        }
        
        if (activeServeProfile) {
            // After moving to sqlite database we need to change @"jaspersoft.server.active" key representation.
            // Idea is to store object id as url (as there are no other primary key and adding a new "active" field to database is not so clean solution also).
            // We need to get object id after object was saved
            NSURL *activeObjectIDURIRepresentation = [[activeServeProfile objectID] URIRepresentation];
            [defaults setURL:activeObjectIDURIRepresentation forKey:kJMDefaultsActiveServer];
        }
        
        return [defaults synchronize];
    }
}

+ (BOOL)update_1_6
{
    // TODO: remove unnecessary keys
    return YES;
}

#pragma mark - Alert view delegate methods

+ (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [JMAppUpdater update];
    } else if (buttonIndex == 2) {
//        JasperMobileAppDelegate *app = [JasperMobileAppDelegate sharedInstance];
//        [app resetDatabase];
//        [app refreshApplication];
    } else {
        // TODO: change to smt more user friendly
        abort();
    }
}

#pragma makr - Private

+ (void)showErrors
{
    delegate = [[JMAppUpdater alloc] init];
    [[UIAlertView localizedAlertWithTitle:@"error.upgrade.data.title"
                                  message:errorMessage
                                 delegate:self
                        cancelButtonTitle:@"dialog.button.cancel"
                        otherButtonTitles:@"dialog.button.retry", @"dialog.button.applyUpdate", nil] show];
}

@end
