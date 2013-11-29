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
//  JasperMobileAppDelegate.m
//  Jaspersoft Corporation
//

#import "JasperMobileAppDelegate.h"
#import "JMAppUpdater.h"
#import "JMAskPasswordDialog.h"
#import "JMConstants.h"
#import "JMFavoritesUtil.h"
#import "JMPadModule.h"
#import "JMPhoneModule.h"
#import "JMReportClientHolder.h"
#import "JMReportOptionsUtil.h"
#import "JMResourceClientHolder.h"
#import "JMUtils.h"

static NSString * const kJMProductName = @"JasperMobile";
static NSString * const kJMDefaultRequestTimeout = @"defaultRequestTimeout";
static NSString * const kJMReportRequestTimeout = @"reportRequestTimeout";

@interface JasperMobileAppDelegate() <JMResourceClientHolder, JMReportClientHolder>
@property (nonatomic, strong) JMFavoritesUtil *favoritesUtil;
@property (nonatomic, strong) JMReportOptionsUtil *reportOptionsUtil;
@end

@implementation JasperMobileAppDelegate

@synthesize window = _window;
@synthesize reportClient = _reportClient;
@synthesize resourceClient = _resourceClient;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

#pragma mark - Initialization

- (id)init
{
    if (self = [super init]) {
        [self initObjectionModules];
        
        if ([JMAppUpdater isRunningForTheFirstTime]) {
            [JMAppUpdater updateAppVersionTo:[JMAppUpdater latestAppVersion]];
            [self coreDataInit];
        } else {
            [JMAppUpdater update];
        }
        
        // Add notification to track selecting of the another server profile
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(changeServerProfile:)
                                                     name:kJMChangeServerProfileNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(resetApplication)
                                                     name:kJMResetApplicationNotification
                                                   object:nil];
        
        NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0 diskPath:nil];
        [NSURLCache setSharedURLCache:sharedCache];
    }
    
    return self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    JMServerProfile *serverProfile = [self activeServerProfile];
    
    if (serverProfile.askPassword.boolValue) {
        // Using performSelector to fix warning: "Applications are expected to have a root view controller at the end of application launch"
        [[JMAskPasswordDialog askPasswordDialogForServerProfile:serverProfile] performSelector:@selector(show) withObject:nil afterDelay:0.0];
    } else {
        [JMUtils sendChangeServerProfileNotificationWithProfile:serverProfile];
    }
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [self updateTimeouts];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
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
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
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
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Private

- (void)initObjectionModules
{
    JMBaseModule *module;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        module = [[JMPadModule alloc] init];
    } else {
        module = [[JMPhoneModule alloc] init];
    }
    
    module.managedObjectContext = self.managedObjectContext;
    
    JSObjectionInjector *injector = [JSObjection createInjector:module];
    [JSObjection setDefaultInjector:injector];
    
    // Inject resource and report clients
    self.resourceClient = [injector getObject:[JSRESTResource class]];
    self.reportClient = [injector getObject:[JSRESTReport class]];
    self.favoritesUtil = [injector getObject:[JMFavoritesUtil class]];
    self.reportOptionsUtil = [injector getObject:[JMReportOptionsUtil class]];
}

- (void)coreDataInit
{
    JMServerProfile *serverProfile = [NSEntityDescription insertNewObjectForEntityForName:@"ServerProfile" inManagedObjectContext:self.managedObjectContext];
    
    serverProfile.alias = @"Jaspersoft Mobile Demo";
    serverProfile.username = @"phoneuser";
    serverProfile.password = @"phoneuser";
    serverProfile.organization = @"organization_1";
    serverProfile.serverUrl = @"http://mobiledemo.jaspersoft.com/jasperserver-pro";
    serverProfile.askPassword = [NSNumber numberWithBool:NO];
    
    [self.managedObjectContext save:nil];
    [JMServerProfile storePasswordInKeychain:serverProfile.password profileID:serverProfile.profileID];
}

- (void)changeServerProfile:(NSNotification *)notification
{
    JMServerProfile *serverProfile = [[notification userInfo] objectForKey:kJMServerProfileKey];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (serverProfile == nil) {
        [defaults removeObjectForKey:kJMDefaultsActiveServer];
    } else {
        JSProfile *profile = [[JSProfile alloc] initWithAlias:serverProfile.alias
                                                     username:serverProfile.username
                                                     password:serverProfile.password
                                                 organization:serverProfile.organization
                                                    serverUrl:serverProfile.serverUrl];
        // Set connection details
        self.reportClient.serverProfile = profile;
        self.resourceClient.serverProfile = profile;

        // Update report options with active server profile
        self.reportOptionsUtil.serverProfile = serverProfile;
        
        // Update favorites with active server profile
        self.favoritesUtil.serverProfile = serverProfile;

        // Update timeouts
        [self updateTimeouts];
        
        [defaults setURL:[serverProfile.objectID URIRepresentation] forKey:kJMDefaultsActiveServer];
    }
    
    [defaults synchronize];
}

// Loads timeout for report / other type of requests from project settings
// (defined in Settings.bundle)
- (void)updateTimeouts
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.resourceClient.timeoutInterval = [defaults integerForKey:kJMDefaultRequestTimeout] ?: 120;
    self.reportClient.timeoutInterval = [defaults integerForKey:kJMReportRequestTimeout] ?: 120;
}

// Resets database and defaults
- (void)resetApplication
{
    [[NSUserDefaults standardUserDefaults] setPersistentDomain:[NSDictionary dictionary]
                                                       forName:[[NSBundle mainBundle] bundleIdentifier]];
    NSArray *stores = [self.persistentStoreCoordinator persistentStores];
    NSMutableArray *storesURLs = [NSMutableArray array];
    
    for (NSPersistentStore *store in stores) {
        [storesURLs addObject:store.URL];
        [self.persistentStoreCoordinator removePersistentStore:store error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:store.URL.path error:nil];
    }
    
    for (NSURL *storeURL in storesURLs) {
        [self.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:nil];
    }
    
    // Update db with latest app version and demo profile
    [JMAppUpdater updateAppVersionTo:[JMAppUpdater latestAppVersion]];
    [self coreDataInit];
}

- (JMServerProfile *)activeServerProfile
{
    NSManagedObjectID *activeServerID = [JMServerProfile activeServerID];
    
    if (activeServerID) {
        JMServerProfile *serverProfile = (JMServerProfile *) [self.managedObjectContext existingObjectWithID:activeServerID error:nil];
        if (serverProfile) {
            [serverProfile setPasswordAsPrimitive:[JMServerProfile passwordFromKeychain:serverProfile.profileID]];
        }
        
        return serverProfile;
    }
    
    return nil;
}

@end
