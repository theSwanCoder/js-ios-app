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
//  JasperMobileAppDelegate.h
//  Jaspersoft Corporation
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <jaspersoft-sdk/JaspersoftSDK.h>
#import "JSFavoritesHelper.h"
#import "ServerProfile+Helpers.h"
#import "UITabBarController+RotationIn_IOS6.h"

/**
 @author Giulio Toffoli giulio@jaspersoft.com
 @author Vlad Zavadskii vzavadskii@jaspersoft.com
 @since 1.0
 */
@interface JasperMobileAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
    UIWindow *window;
    UINavigationController *navigationController;
    UINavigationController *searchController;
	UINavigationController *settingsController;
    UINavigationController *favoritesController;
    UINavigationController *libraryController;
    UITabBarController *tabBarController;
    
	// This is a list configured servers. Each server is an instance of JSClient...
	NSMutableArray *servers;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) IBOutlet UINavigationController *searchController;
@property (nonatomic, retain) IBOutlet UINavigationController *settingsController;
@property (nonatomic, retain) IBOutlet UINavigationController *favoritesController;
@property (nonatomic, retain) IBOutlet UINavigationController *libraryController;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, readonly) NSMutableArray *servers;
@property (nonatomic, retain) JSRESTResource *resourceClient;
@property (nonatomic, retain) JSRESTReport *reportClient;
@property (nonatomic, retain) JSFavoritesHelper *favorites;

// Core data
@property (readonly, retain, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, retain, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, retain, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (IBAction)configureServersDone:(id)sender;
+ (JasperMobileAppDelegate *)sharedInstance;
- (void)initProfileForRESTClient:(ServerProfile *)profile;
- (void)disableTabBar;
- (void)enableTabBar;
- (void)refreshApplication;
- (void)resetDatabase;
- (NSURL *)applicationDocumentsDirectory;

@end

