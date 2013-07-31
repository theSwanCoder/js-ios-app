//
//  JasperMobileAppDelegate.m
//  JasperMobile
//
//  Created by Vlad on 5/22/13.
//  Copyright (c) 2013 com.jaspersoft. All rights reserved.
//

#import "JasperMobileAppDelegate.h"
#import "JMAppUpdater.h"
#import "JMAskPasswordDialog.h"
#import "JMConstants.h"
#import "JMPadModule.h"
#import "JMPhoneModule.h"
#import "JMReportClientHolder.h"
#import "JMResourceClientHolder.h"
#import "JMServerProfile+Helpers.h"
#import "JMUtils.h"
#import <jaspersoft-sdk/JaspersoftSDK.h>
#import <Objection-iOS/Objection.h>

static NSString * const kJMProductName = @"JasperMobile";
static NSString * const kJMDefaultRequestTimeout = @"defaultRequestTimeout";
static NSString * const kJMReportRequestTimeout = @"reportRequestTimeout";

@interface JasperMobileAppDelegate() <JMResourceClientHolder, JMReportClientHolder>
@end

@implementation JasperMobileAppDelegate

@synthesize reportClient = _reportClient;
@synthesize resourceClient = _resourceClient;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

#pragma mark - Initialization

- (id)init
{
    if (self == [super init]) {
        [self initObjectionModules];
        
        // Check if app is running for the first time
        if (![JMAppUpdater currentAppVersion]) {
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
    }
    
    return self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    JMServerProfile *serverProfile = [self activeServerProfile];
    
    if (serverProfile.askPassword.boolValue) {
        [[JMAskPasswordDialog askPasswordDialogForServerProfile:serverProfile] show];
        // Setting server profile to "nil" indicates that application menu should be disabled (except Servers tab)
        serverProfile = nil;
    }
    
    [JMUtils sendChangeServerProfileNotificationWithProfile:serverProfile];
    
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
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
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

- (void)changeServerProfile:(NSNotification *)notification {
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
        
        // Forces to refresh server info
        [self.resourceClient serverInfo];
        
        // Update timeouts
        [self updateTimeouts];
        
        // TODO: favorites implementation needed
        //        self.favorites = [[JSFavoritesHelper alloc] initWithServerProfile:serverProfile];
        //        self.reportOptions = [[JSReportOptionsHelper alloc] initWithServerProfile:serverProfile];
        
        [defaults setURL:[serverProfile.objectID URIRepresentation] forKey:kJMDefaultsActiveServer];
    }
    
    [defaults synchronize];
}

// Loads timeout for report / other type of requests from project settings
// (defined in Settings.bundle)
- (void)updateTimeouts
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    self.resourceClient.timeoutInterval = [prefs integerForKey:kJMDefaultRequestTimeout] ?: 30;
    self.reportClient.timeoutInterval = [prefs integerForKey:kJMReportRequestTimeout] ?: 90;
}

// Resets whole database for (sqlite + NSUserDefaults)
- (void)resetDatabase
{
    [[NSUserDefaults standardUserDefaults] setPersistentDomain:[NSDictionary dictionary] forName:[[NSBundle mainBundle] bundleIdentifier]];
    NSArray *stores = [self.persistentStoreCoordinator persistentStores];
    
    for (NSPersistentStore *store in stores) {
        [self.persistentStoreCoordinator removePersistentStore:store error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:store.URL.path error:nil];
    }
    
    // This will forces app to recreate db
    _managedObjectModel = nil;
    _managedObjectContext = nil;
    _persistentStoreCoordinator = nil;
}

- (JMServerProfile *)activeServerProfile
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSManagedObjectID *activeServerID = [[self persistentStoreCoordinator] managedObjectIDForURIRepresentation:[defaults URLForKey:kJMDefaultsActiveServer]];
    
    if (activeServerID) {
        JMServerProfile *serverProfile = (JMServerProfile *)[self.managedObjectContext existingObjectWithID:activeServerID error:nil];
        if (serverProfile) {
            serverProfile.password = [JMServerProfile passwordFromKeychain:serverProfile.profileID];
        }
        
        return serverProfile;
    }
    
    return nil;
}

@end
