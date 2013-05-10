/*
 * JasperMobile for iOS
 * Copyright (C) 2005 - 2012 Jaspersoft Corporation. All rights reserved.
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
//  JSAppUpdater.m
//  Jaspersoft Corporation
//

#import "JSAppUpdater.h"
#import "JasperMobileAppDelegate.h"
#import "ServerProfile+Helpers.h"
#import "Favorites.h"
#import "JSLocalization.h"
#import "UIAlertView+LocalizedAlert.h"

// Contains version:method structure. Method updates specific part of application for specific app version
static NSDictionary *versionsToUpdate = nil;

// NSUserDefaults keys
static NSString * const keyJaspersoftMobileUpdatedVersions = @"jaspersoft.mobile.updated.versions";
static NSString * const keyJaspersoftMobileCurrentVersion = @"jaspersoft.mobile.current.version";
static NSString * const keyJaspersoftMobileFirstRun = @"jaspersoft.mobile.firstRun";
static NSString * const keyJaspersoftMobileNotFirstRun = @"jaspersoft.mobile.notFirstRun";
static NSString * const keyJaspersoftServerCount = @"jaspersoft.server.count";
static NSString * const keyJaspersoftServerActive = @"jaspersoft.server.active";
static NSString * const keyJaspersoftServerFavorites = @"jaspersoft.server.favorites.%d";
static NSString * const keyJaspersoftServerAlias = @"jaspersoft.server.alias.%d";
static NSString * const keyJaspersoftServerUsername = @"jaspersoft.server.username.%d";
static NSString * const keyJaspersoftServerOrganization = @"jaspersoft.server.organization.%d";
static NSString * const keyJaspersoftServerBaseUrl = @"jaspersoft.server.baseUrl.%d";
static NSString * const keyJaspersoftServerPassword = @"jaspersoft.server.password.%d";
static NSString * const keyJaspersoftServerAlwaysAskPassword = @"jaspersoft.server.alwaysAskPassword.%d";

// Key for app version
static NSString * const keyApplicaitonVersion = @"CFBundleShortVersionString";

// Error message
static NSString * errorMessage = nil;

@implementation JSAppUpdater

// Fill migrations with update methods for different versions
+ (void)initialize {
    NSMutableDictionary *temp = [[NSMutableDictionary alloc] init];
    
    // Add update methods
    [temp setObject:NSStringFromSelector(@selector(update_1_2)) forKey:[NSNumber numberWithDouble:1.2]];
    [temp setObject:NSStringFromSelector(@selector(update_1_5)) forKey:[NSNumber numberWithDouble:1.5]];
    
    versionsToUpdate = temp;
}

#pragma mark - Helper methods

+ (NSNumber *)latestAppVersion {
    NSString *appVersion = [[NSBundle mainBundle].infoDictionary objectForKey:keyApplicaitonVersion];
    return [NSNumber numberWithDouble:[appVersion doubleValue]];
}

+ (NSNumber *)currentAppVersion {
    return [[NSUserDefaults standardUserDefaults] objectForKey:keyJaspersoftMobileCurrentVersion];
}

+ (void)updateAppVersionTo:(NSNumber *)appVersion {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:appVersion forKey:keyJaspersoftMobileCurrentVersion];
    [prefs synchronize];
}

+ (void)update {
    NSNumber *latestAppVersion = [self latestAppVersion];
    NSNumber *currentAppVersion = [self currentAppVersion];
    
    if (currentAppVersion == nil || [currentAppVersion compare:latestAppVersion] == 0) {
        return;
    }
    
    for (NSNumber *version in versionsToUpdate.allKeys) {
        if ([currentAppVersion compare:version] == -1 &&
            (BOOL)[self performSelector:NSSelectorFromString([versionsToUpdate objectForKey:version]) withObject:self]) {
            // Update app version for each migratin. This allows us tracking which migration was failed 
            [self updateAppVersionTo:version];
            errorMessage = nil;
        }
    }

    if ([self hasErrors]) {
        [self showErrors];
    }
}

+ (BOOL)hasErrors {
    return errorMessage != nil;
}

+ (void)showErrors {
    [[UIAlertView localizedAlert:@"error.update.to.1_5.title"
                        message:errorMessage
                       delegate:self
              cancelButtonTitle:@"dialog.button.cancel"
              otherButtonTitles:@"dialog.button.retry", @"dialog.button.applyUpdate", nil] show];
}

#pragma mark - Migration methods

// Moves password for profiles from NSUserDefaults to keychain
+ (BOOL)update_1_2 {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSInteger count = [prefs integerForKey:keyJaspersoftServerCount];
    
    for (int i = 0; i < count; i++) {
        NSString *serverUrl = [prefs objectForKey:[NSString stringWithFormat:keyJaspersoftServerBaseUrl, i]];
        NSString *username = [prefs objectForKey:[NSString stringWithFormat:keyJaspersoftServerUsername, i]];
        NSString *organization = [prefs objectForKey:[NSString stringWithFormat:keyJaspersoftServerOrganization, i]];
        NSString *password = [prefs objectForKey:[NSString stringWithFormat:keyJaspersoftServerPassword, i]];
        NSString *profileID = [ServerProfile profileIDByServerURL:serverUrl username:username organization:organization];
        [ServerProfile storePasswordInKeychain:password profileID:profileID];
        [prefs removeObjectForKey:[NSString stringWithFormat:keyJaspersoftServerPassword, i]];
    }
    
    return [prefs synchronize];
}

// Moves all data from NSUserDefaults persistent Map to SQLite database
+ (BOOL)update_1_5 {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    // Get number of stored profiles
    NSInteger count = [prefs integerForKey:keyJaspersoftServerCount];
    // Get current active server (if exists)
    NSInteger activeServerIndex = [prefs integerForKey:keyJaspersoftServerActive];
    NSManagedObjectContext *managedObectContext = [[JasperMobileAppDelegate sharedInstance] managedObjectContext];
    // Keys which will be removed from NSUserDefaults (clear defaults from unnecessary data)
    NSMutableSet *keysToRemove = [[NSMutableSet alloc] init];
    // Active server profile
    ServerProfile *activeServeProfile = nil;
    
    for (int i = 0; i < count; i++) {
        // Create keys for profile's fields stored in NSUserDefaults (persistent Map)
        // In NSUserDefauls profile's data looks like: {
        //      "jaspersoft.server.alias.0" : "Alias 0",
        //      "jaspersoft.server.username.0" : "Username 0",
        //      ...
        // }
        // Wheres 0 - profile position (or "id" as in relation databases)
        NSString *keyAlias = [NSString stringWithFormat:keyJaspersoftServerAlias, i];
        NSString *keyServerBaseUrl = [NSString stringWithFormat:keyJaspersoftServerBaseUrl, i];
        NSString *keyUsername = [NSString stringWithFormat:keyJaspersoftServerUsername, i];
        NSString *keyOrganization = [NSString stringWithFormat:keyJaspersoftServerOrganization, i];
        NSString *keyAlwaysAskPassword = [NSString stringWithFormat:keyJaspersoftServerAlwaysAskPassword, i];
        NSString *keyFavorites = [NSString stringWithFormat:keyJaspersoftServerFavorites, i];
        
        // Create and configure ServerProfile instance (not saved to database yet, only in-memory changes)
        ServerProfile *serverProfile = [NSEntityDescription insertNewObjectForEntityForName:@"ServerProfile" inManagedObjectContext:managedObectContext];
        serverProfile.alias = [prefs objectForKey:keyAlias];
        serverProfile.serverUrl = [prefs objectForKey:keyServerBaseUrl];
        serverProfile.username = [prefs objectForKey:keyUsername];
        serverProfile.organization = [prefs objectForKey:keyOrganization];
        serverProfile.askPassword = [prefs objectForKey:keyAlwaysAskPassword] ?: [NSNumber numberWithBool:NO];
        
        if (activeServerIndex == i) {
            activeServeProfile = serverProfile;
        }
        
        // Get all favorites from user defaults structured by "username|organization" or "username" key patterns
        NSDictionary *oldFavorites = [prefs objectForKey:keyFavorites];
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
                Favorites *favorites = [NSEntityDescription insertNewObjectForEntityForName:@"Favorites" inManagedObjectContext:managedObectContext];
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
    if ([managedObectContext hasChanges]) {
        [managedObectContext save:&error];
    }
    
    if (error != nil) {
        errorMessage = [NSString stringWithFormat:@"%@: %@\n%@",
                             JSCustomLocalizedString(@"error.update.to.1_5.msg", nil),
                             [error localizedDescription],
                             JSCustomLocalizedString(@"error.update.retry", nil)];
        return NO;
    } else {
        // Change location for firstRun value and delete unnecessary data
        NSInteger firstRun = [prefs integerForKey:keyJaspersoftMobileFirstRun];
        [prefs setInteger:firstRun forKey:keyJaspersoftMobileNotFirstRun];
        [prefs removeObjectForKey:keyJaspersoftMobileFirstRun];
        [prefs removeObjectForKey:keyJaspersoftMobileUpdatedVersions];
        [prefs removeObjectForKey:keyJaspersoftServerCount];
        
        for (NSString *keyToRemove in [keysToRemove allObjects]) {
            [prefs removeObjectForKey:keyToRemove];
        }
        
        if (activeServeProfile) {
            // After moving to sqlite database we need to change @"jaspersoft.server.active" key representation.
            // Idea is to store object id as url (as there are no other primary key and adding a new "active" field to database is not so clean solution also).
            // We need to get object id after object was saved
            NSURL *activeObjectIDURIRepresentation = [[activeServeProfile objectID] URIRepresentation];
            [prefs setURL:activeObjectIDURIRepresentation forKey:keyJaspersoftServerActive];
        }
        return [prefs synchronize];
    }
}

#pragma mark - Alert view delegate methods

+ (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self update];
    } else if (buttonIndex == 2) {
        JasperMobileAppDelegate *app = [JasperMobileAppDelegate sharedInstance];
        [app resetDatabase];
        [app refreshApplication];
    } else {
        ///~ @TODO: change to smt more user friendly
        abort();
    }
}

@end
