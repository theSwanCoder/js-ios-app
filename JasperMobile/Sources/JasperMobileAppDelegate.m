/*
 * Tibco JasperMobile for iOS
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
//  Tibco JasperMobile
//

#import "JasperMobileAppDelegate.h"
#import "JMAppUpdater.h"
#import "JMAskPasswordDialog.h"
#import "JMConstants.h"
#import "JMBaseModule.h"
#import "JMReportClientHolder.h"
#import "JMResourceClientHolder.h"
#import "JMUtils.h"


static NSString * const kJMProductName = @"JasperMobile";

@interface JasperMobileAppDelegate() <JMResourceClientHolder, JMReportClientHolder>
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
    [JMUtils activateCrashReportSendingIfNeeded];
    
    JMServerProfile *serverProfile = [JMServerProfile activeServerProfile];
    
    if (serverProfile.askPassword.boolValue) {
        // Using performSelector to fix warning: "Applications are expected to have a root view controller at the end of application launch"
        [[JMAskPasswordDialog askPasswordDialogForServerProfile:serverProfile] performSelector:@selector(show) withObject:nil afterDelay:0.0];
    } else {
        [JMUtils sendChangeServerProfileNotificationWithProfile:serverProfile withParams:nil];
    }
    
    [application setStatusBarStyle:UIStatusBarStyleLightContent];

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    if (self.resourceClient.serverProfile.serverInfo.versionAsFloat == 0) {
        self.resourceClient.serverProfile.serverInfo = nil;
    }
    
    if (self.reportClient.serverProfile.serverInfo.versionAsFloat == 0) {
        self.reportClient.serverProfile.serverInfo = nil;
    }
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

- (void)initObjectionModules
{
    JMBaseModule *module = [[JMBaseModule alloc] init];
    module.managedObjectContext = self.managedObjectContext;
    
    JSObjectionInjector *injector = [JSObjection createInjector:module];
    [JSObjection setDefaultInjector:injector];
    
    // Inject resource and report clients
    self.resourceClient = [injector getObject:[JSRESTResource class]];
    self.reportClient = [injector getObject:[JSRESTReport class]];
}

- (void)coreDataInit
{
    JMServerProfile *serverProfile = [NSEntityDescription insertNewObjectForEntityForName:@"ServerProfile" inManagedObjectContext:self.managedObjectContext];
    
    serverProfile.alias = @"Jaspersoft Mobile Demo";
    serverProfile.username = @"jasperadmin";
    serverProfile.password = @"jasperadmin";
    serverProfile.organization = @"organization_1";
    serverProfile.serverUrl = @"http://mobiledemo.jaspersoft.com/jasperserver-pro";
    serverProfile.askPassword = [NSNumber numberWithBool:NO];
    
    [self.managedObjectContext save:nil];
    [JMServerProfile storePasswordInKeychain:serverProfile.password profileID:serverProfile.profileID];
    
    [serverProfile setServerProfileIsActive:YES];
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
