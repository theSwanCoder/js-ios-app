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
//  JasperMobileAppDelegate.m
//  Jaspersoft Corporation
//

#import "JasperMobileAppDelegate.h"
#import "JSUIBaseRepositoryViewController.h"
#import "JSProfile.h"
#import "JSAppUpdater.h"

@interface JasperMobileAppDelegate()

@property (nonatomic, assign) NSInteger requestTimeoutSeconds;
@property (nonatomic, assign) NSInteger reportRequestTimeoutSeconds;
@property (nonatomic, retain) id lastSelectedViewController;

@end

@implementation JasperMobileAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize settingsController;
@synthesize searchController;
@synthesize favoritesController;
@synthesize libraryController;
@synthesize tabBarController;
@synthesize servers;
@synthesize reportClient;
@synthesize resourceClient;
@synthesize favorites;
@synthesize reportOptions;
@synthesize requestTimeoutSeconds;
@synthesize reportRequestTimeoutSeconds;
@synthesize lastSelectedViewController;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

static JasperMobileAppDelegate *sharedInstance = nil;
static NSString * const keyDefaultRequestTimeoutSeconds = @"defaultRequestTimeoutSeconds";
static NSString * const keyReportRequestTimeoutSeconds = @"reportRequestTimeoutSeconds";
static NSString * const productName = @"JasperMobile";
static ServerProfile * currentActiveServerProfile;

+ (JasperMobileAppDelegate *)sharedInstance {
    return sharedInstance;
}

+ (ServerProfile *)currentActiveServerProfile {
    return currentActiveServerProfile;
}

- (IBAction)configureServersDone:(id)sender {
    [self setResourceClientForControllers:self.resourceClient];
    [tabBarController setSelectedIndex:0];
}

- (void)setResourceClientForControllers:(JSRESTResource *)resClient {
    [navigationController popToRootViewControllerAnimated:NO];
    [searchController popToRootViewControllerAnimated:NO];
    [libraryController popToRootViewControllerAnimated:NO];
    [(JSUIBaseRepositoryViewController *)navigationController.topViewController clear];
    [(JSUIBaseRepositoryViewController *)navigationController.topViewController setResourceClient:resClient];
    if ([searchController.topViewController respondsToSelector:@selector(clear)])
    {
        [searchController.topViewController performSelector:@selector(clear)];
    }
    [(JSUIBaseRepositoryViewController *)libraryController.topViewController setResourceClient:resClient];
    [(JSUIBaseRepositoryViewController *)libraryController.topViewController clear];
    [(JSUIBaseRepositoryViewController *)searchController.topViewController setResourceClient: resClient];    
}

- (void)loadServers:(NSInteger)notFirstRun {
    if (servers == nil) {
		servers = [[NSMutableArray alloc] initWithCapacity:1];
	}
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    // Get all ServerProfile instances
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"ServerProfile"];
    fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"alias" ascending:YES]];
    NSUInteger count = [[self managedObjectContext] countForFetchRequest:fetchRequest error:nil];
    
    if (count == 0 && notFirstRun == NO) {
        ServerProfile *serverProfile = [NSEntityDescription insertNewObjectForEntityForName:@"ServerProfile" inManagedObjectContext:[self managedObjectContext]];
        
        serverProfile.alias = @"Jaspersoft Mobile Demo";
        serverProfile.username = @"phoneuser";
        serverProfile.password = @"phoneuser";
        serverProfile.organization = @"organization_1";
        serverProfile.serverUrl = @"http://mobiledemo.jaspersoft.com/jasperserver-pro";
        serverProfile.askPassword = [NSNumber numberWithBool:NO];
        
        [[self managedObjectContext] save:nil];
        [servers addObject: serverProfile];
        [ServerProfile storePasswordInKeychain:serverProfile.password profileID:[serverProfile profileID]];
    } else if (count > 0) {
        NSArray *serverProfiles = [[self managedObjectContext] executeFetchRequest:fetchRequest error:nil];
        ServerProfile *activeServerProfile;
        
        NSManagedObjectID *activeServerID = [[self persistentStoreCoordinator] managedObjectIDForURIRepresentation:[prefs URLForKey:@"jaspersoft.server.active"]];
        if (!activeServerID) {
            activeServerID = [[serverProfiles objectAtIndex:0] objectID];
        }
        
        for (ServerProfile *serverProfile in serverProfiles) {
            serverProfile.password = [ServerProfile passwordFromKeychain:[serverProfile profileID]];
            [servers addObject:serverProfile];
            
            if ([activeServerID isEqual:serverProfile.objectID]) {
                activeServerProfile = serverProfile;
            }
        }
        
        [self initProfileForRESTClient:activeServerProfile];
    }
}

- (void)initProfileForRESTClient:(ServerProfile *)serverProfile {
    currentActiveServerProfile = serverProfile;
    
    if (serverProfile == nil) {
        self.resourceClient = nil;
        self.reportClient = nil;
    } else {
        if (!self.resourceClient) {
            self.resourceClient = [[JSRESTResource alloc] init];
            self.reportClient = [[JSRESTReport alloc] init];
        }

        JSProfile *profile = [[JSProfile alloc] initWithAlias:serverProfile.alias
                                username:serverProfile.username
                                password:serverProfile.password
                            organization:serverProfile.organization
                               serverUrl:serverProfile.serverUrl];;
        self.resourceClient.serverProfile = profile;
        // Forces to refresh server info
        [self.resourceClient serverInfo];
        self.reportClient.serverProfile = self.resourceClient.serverProfile;
        self.resourceClient.timeoutInterval = self.requestTimeoutSeconds;
        self.reportClient.timeoutInterval = self.reportRequestTimeoutSeconds;
        self.resourceClient.timeoutInterval = self.requestTimeoutSeconds;
        self.reportClient.timeoutInterval = self.reportRequestTimeoutSeconds;
        [self setResourceClientForControllers:self.resourceClient];
        self.favorites = [[JSFavoritesHelper alloc] initWithServerProfile:serverProfile];
        self.reportOptions = [[JSReportOptionsHelper alloc] initWithServerProfile:serverProfile];
        
        if (![self.resourceClient.serverProfile.alias isEqual:serverProfile.alias]) {
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            [prefs setURL:[[serverProfile objectID] URIRepresentation] forKey:@"jaspersoft.server.active"];
            [prefs synchronize];
        }
    }
}

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    sharedInstance = self;
    
    ///~ @TODO: show some user friendy window instead blank screen
    [JSAppUpdater update];
    if (![JSAppUpdater hasErrors]) {
        [self refreshApplication];
    }
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)refreshApplication {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSInteger notFirstRun = [prefs integerForKey:@"jaspersoft.mobile.notFirstRun"];
    
    if (![JSAppUpdater currentAppVersion]) {
        [JSAppUpdater updateAppVersionTo:[JSAppUpdater latestAppVersion]];
    }
    
    [self updateTimeouts];
	[self loadServers:notFirstRun];
    
    if (self.reportClient != nil) {
        self.reportClient.timeoutInterval = self.requestTimeoutSeconds;
    }
    
    if (self.resourceClient != nil) {
        self.resourceClient.timeoutInterval = self.reportRequestTimeoutSeconds;
        [(JSUIBaseRepositoryViewController *)(navigationController.topViewController) setResourceClient:self.resourceClient];
        [(JSUIBaseRepositoryViewController *)(searchController.topViewController) setResourceClient:self.resourceClient];
        [(JSUIBaseRepositoryViewController *)(favoritesController.topViewController) setResourceClient:self.resourceClient];
        [(JSUIBaseRepositoryViewController *)(libraryController.topViewController) setResourceClient:self.resourceClient];
        
        navigationController.title = NSLocalizedString(@"view.repository", nil);
        favoritesController.title = NSLocalizedString(@"view.favorites", nil);
        searchController.title = NSLocalizedString(@"view.search", nil);
        settingsController.title = NSLocalizedString(@"view.servers", nil);
        libraryController.title = NSLocalizedString(@"view.library", nil);
    }
	
    NSArray *controllers = [NSArray arrayWithObjects:navigationController, libraryController, favoritesController, searchController, settingsController, nil];
    tabBarController.viewControllers = controllers;
    tabBarController.delegate = self;
    
    [self.window setRootViewController:tabBarController];
    
    if (notFirstRun == NO || [servers count] == 0 || currentActiveServerProfile.askPassword.boolValue) {
        [tabBarController setSelectedIndex:4];
        [self disableTabBar];
        
        if (notFirstRun == NO) {
            [prefs setInteger:1 forKey:@"jaspersoft.mobile.notFirstRun"];
            [prefs synchronize];
        }
    } else {
        self.lastSelectedViewController = self.navigationController;
        [tabBarController setSelectedIndex:0];
	}
    
    [self.window makeKeyAndVisible];
}

- (void)disableTabBar {
    for (UITabBarItem *item in self.tabBarController.tabBar.items) {
        if (![item.title isEqualToString: NSLocalizedString(@"view.servers", nil)]) {
            [item setEnabled:NO];
        }
    }
}

- (void)enableTabBar {
    for (UITabBarItem *item in self.tabBarController.tabBar.items) {
        [item setEnabled:YES];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {    
    // Re-set timeouts from project settings (if setting was changed)
    [self updateTimeouts];
    self.resourceClient.timeoutInterval = self.requestTimeoutSeconds;
    self.reportClient.timeoutInterval = self.reportRequestTimeoutSeconds;
}

// Loads timeout for report / other type of requests from project settings
// (defined in Settings.bundle)
- (void)updateTimeouts {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    self.requestTimeoutSeconds = [prefs integerForKey:keyReportRequestTimeoutSeconds] ?: 120;
    self.reportRequestTimeoutSeconds = [prefs integerForKey:keyDefaultRequestTimeoutSeconds] ?: 180;
}

// Resets whole database for (sqlite + NSUserDefaults)
- (void)resetDatabase {
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

#pragma mark - 
#pragma mark TabBarController delegate methods

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    // Go to root controller for favorites navigation
    if (self.favoritesController == viewController) {
        [self.favoritesController popToRootViewControllerAnimated:YES];
    }

    if (self.libraryController == viewController) {
        [self.libraryController popToRootViewControllerAnimated:NO];
        [(JSUIBaseRepositoryViewController *)self.libraryController.topViewController clear];
        if (self.lastSelectedViewController == self.libraryController) {
            [(JSUIBaseRepositoryViewController *)self.libraryController.topViewController updateTableContent];
        }
    } else if (self.navigationController == viewController) {
        [self.navigationController popToRootViewControllerAnimated:NO];
        [(JSUIBaseRepositoryViewController *)self.navigationController.topViewController clear];
        if (self.lastSelectedViewController == self.navigationController) {
            [(JSUIBaseRepositoryViewController *)self.navigationController.topViewController updateTableContent];
        }
    }
    
    self.lastSelectedViewController = viewController;
}

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	NSLog(@"Memory warning!!!");
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext {
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
- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:productName withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
        
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:[productName stringByAppendingPathExtension:@"sqlite"]];
    
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
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end

