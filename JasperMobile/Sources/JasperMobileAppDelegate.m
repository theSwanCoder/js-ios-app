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
//  JasperMobileAppDelegate.m
//  TIBCO JasperMobile
//

#import "JasperMobileAppDelegate.h"
#import "JMAppUpdater.h"
#import "Appirater.h"
#import "JMUtils.h"
#import "JMServerProfile+Helpers.h"
#import "JMSessionManager.h"
#import "JMCancelRequestPopup.h"
#import "JMMenuViewController.h"

static NSString * const kJMProductName = @"JasperMobile";
static NSString * const kGAITrackingID = @"UA-57445224-1";

@interface JasperMobileAppDelegate()
@end

@implementation JasperMobileAppDelegate

@synthesize window = _window;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

#pragma mark - Initialization

- (id)init
{
    if (self = [super init]) {
        _applicationFirstStart = NO;
        if ([JMAppUpdater isRunningForTheFirstTime]) {
            [JMAppUpdater updateAppVersionTo:[JMAppUpdater latestAppVersion]];
            _applicationFirstStart = YES;
            [self coreDataInit];
        } else {
            [JMAppUpdater update];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(resetApplication)
                                                     name:kJMResetApplicationNotification
                                                   object:nil];
        
        // Configure Url Cache
        NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024 diskCapacity:20 * 1024 * 1024 diskPath:nil];
        [NSURLCache setSharedURLCache:URLCache];
    }
    
    return self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    [JMUtils activateCrashReportSendingIfNeeded];

    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // Google Analytics
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [GAI sharedInstance].dispatchInterval = 20;
    //[[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    [[GAI sharedInstance] trackerWithTrackingId:kGAITrackingID];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    SWRevealViewController *revealViewController = (SWRevealViewController *) self.window.rootViewController;
    JMMenuViewController *menuViewController = (JMMenuViewController *) revealViewController.rearViewController;

    void (^loginCompletionBlock)(void) = ^{
        [menuViewController setSelectedItemIndex:0];

        // Configure Appirater
        [Appirater setAppId:@"467317446"];
        [Appirater setDaysUntilPrompt:0];
        [Appirater setUsesUntilPrompt:5];
        [Appirater setTimeBeforeReminding:2];
        [Appirater setDebug:NO];
        [Appirater appLaunched:YES];
    };
    
    if ([[JMSessionManager sharedManager] userIsLoggedIn]) {
        [JMCancelRequestPopup presentWithMessage:@"status.loading" cancelBlock:nil];
        [[JMSessionManager sharedManager] restoreLastSessionWithCompletion:@weakself(^(BOOL success)) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [JMCancelRequestPopup dismiss];
                
                if (success) {
                    self.restClient.timeoutInterval = [[NSUserDefaults standardUserDefaults] integerForKey:kJMDefaultRequestTimeout] ?: 120;
                    if (!menuViewController.selectedItem) {
                        loginCompletionBlock();
                    }
                } else {
                    [JMUtils showLoginViewAnimated:NO completion:@weakself(^(void)) {
                        loginCompletionBlock();
                    } @weakselfend];
                }
            });
        } @weakselfend];
    } else {
        [JMUtils showLoginViewAnimated:NO completion:@weakself(^(void)) {
            loginCompletionBlock();
        } @weakselfend];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:kJMProductName withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:[kJMProductName stringByAppendingPathExtension:@"sqlite"]];

    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    [self addPersistentStoreUrl:storeURL];
    
    return _persistentStoreCoordinator;
}

- (void) addPersistentStoreUrl:(NSURL *)storeURL
{
    NSError *error = nil;
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption : [NSNumber numberWithBool:YES],
                              NSInferMappingModelAutomaticallyOption : [NSNumber numberWithBool:YES]};
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         s
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Private
- (void)coreDataInit
{
    NSString *profilesPath = [[NSBundle mainBundle] pathForResource:@"profiles" ofType:@"json"];
    NSData *profilesData = [NSData dataWithContentsOfFile:profilesPath];
    NSArray *profilesArray = [[NSJSONSerialization JSONObjectWithData:profilesData options:NSJSONReadingAllowFragments error:nil] objectForKey:@"profiles"];
    if (profilesArray && [profilesArray isKindOfClass:[NSArray class]] && profilesArray.count) {
        for (NSDictionary *profileDictionary in profilesArray) {
            JMServerProfile *serverProfile = [NSEntityDescription insertNewObjectForEntityForName:@"ServerProfile" inManagedObjectContext:self.managedObjectContext];
            
            serverProfile.alias = [profileDictionary objectForKey:@"mAlias"];
            serverProfile.organization = [profileDictionary objectForKey:@"mOrganization"];
            serverProfile.serverUrl = [profileDictionary objectForKey:@"mServerUrl"];
            serverProfile.askPassword = [NSNumber numberWithBool:NO];

            [self.managedObjectContext save:nil];
        }
    }
}

// Resets database and defaults
- (void)resetApplication
{
    [[NSUserDefaults standardUserDefaults] setPersistentDomain:[NSDictionary dictionary]
                                                       forName:[[NSBundle mainBundle] bundleIdentifier]];
    NSArray *stores = [self.persistentStoreCoordinator persistentStores];
    for (NSPersistentStore *store in stores) {
        [self.persistentStoreCoordinator removePersistentStore:store error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:store.URL.path error:nil];
    }
    
    for (NSURL *storeURL in stores) {
        [self addPersistentStoreUrl:storeURL];
    }
    
    // Update db with latest app version and demo profile
    [JMAppUpdater updateAppVersionTo:[JMAppUpdater latestAppVersion]];
    [self coreDataInit];
}

@end
