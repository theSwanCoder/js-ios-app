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
#import "SSKeychain.h"
#import "JSProfile+Helpers.h"
#import "JSAppUpdater.h"

@implementation JasperMobileAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize settingsController;
@synthesize searchController;
@synthesize favoritesController;
@synthesize libraryController;
@synthesize tabBarController;
@synthesize servers;
@synthesize reportClient = _reportClient;
@synthesize resourceClient = _resourceClient;
@synthesize activeServerIndex;
@synthesize favorites;

static JasperMobileAppDelegate *sharedInstance = nil;
static NSString * const keychainServiceName = @"JasperMobilePasswordStorage";

// Private time out properties
static const int defaultRequestTimeoutSeconds = 120;
static const int defaultReportRequestTimeoutSeconds = 180;
static NSString * const keyDefaultRequestTimeoutSeconds = @"defaultRequestTimeoutSeconds";
static NSString * const keyReportRequestTimeoutSeconds = @"reportRequestTimeoutSeconds";

+ (JasperMobileAppDelegate *)sharedInstance {
    return sharedInstance;
}

+ (NSString *)keychainServiceName {
    return keychainServiceName;
}

- (IBAction)configureServersDone:(id)sender {
    [self setResourceClientForControllers:self.resourceClient];
    [tabBarController setSelectedIndex:0];
}

- (void)setResourceClientForControllers:(JSRESTResource *)resourceClient {
    [navigationController popToRootViewControllerAnimated:NO];
    [(JSUIBaseRepositoryViewController *)navigationController.topViewController clear];
    [(JSUIBaseRepositoryViewController *)navigationController.topViewController setResourceClient:resourceClient];
    if ([searchController.topViewController respondsToSelector:@selector(clear)])
    {
        [searchController.topViewController performSelector:@selector(clear)];
    }
    [(JSUIBaseRepositoryViewController *)libraryController.topViewController setResourceClient:resourceClient];
    [(JSUIBaseRepositoryViewController *)libraryController.topViewController clear];
    [(JSUIBaseRepositoryViewController *)searchController.topViewController setResourceClient: resourceClient];    
}


-(void)loadServers {
	
	if (servers == nil)
	{
		servers = [[NSMutableArray alloc] initWithCapacity:1];
	}
    
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];	
    NSInteger count = [prefs integerForKey:@"jaspersoft.server.count"];	
    NSInteger firstRun = [prefs integerForKey:@"jaspersoft.mobile.firstRun"];
    
    if (count == 0) {
        // If this is the first time we are using this application, we should load a special demo configuration
        
        if (firstRun == 0) {

            JSProfile *profile = [[JSProfile alloc] initWithAlias:@"Jaspersoft Mobile Demo" 
                                                         username:@"phoneuser"
                                                         password:@"phoneuser"
                                                     organization:@"organization_1" 
                                                        serverUrl:@"http://mobiledemo.jaspersoft.com/jasperserver-pro"];                    
            [servers addObject: profile];
        }
    } else if (count > 0) {
        for (NSInteger i = 0; i < count; ++i) {
            NSString *alias = [prefs objectForKey:[NSString stringWithFormat: @"jaspersoft.server.alias.%d", i]];
            NSString *username = [prefs objectForKey:[NSString stringWithFormat: @"jaspersoft.server.username.%d", i]];
            NSString *organization = [prefs objectForKey:[NSString stringWithFormat: @"jaspersoft.server.organization.%d", i]];
            NSString *profUrl = [prefs objectForKey:[NSString stringWithFormat: @"jaspersoft.server.baseUrl.%d",i]];
            NSString *profID = [JSProfile profileIDByServerURL:profUrl username:username organization:organization];
            NSNumber *askPassword = [prefs objectForKey:[NSString stringWithFormat: @"jaspersoft.server.alwaysAskPassword.%d", i]] ?: [NSNumber numberWithBool:NO];
            NSString *password = nil;
            NSString *tempPassword = [SSKeychain passwordForService:[self.class keychainServiceName] account:profID];
            
            if (!askPassword.boolValue) {
                password = tempPassword;
            }
            
            JSProfile *profile = [[JSProfile alloc] initWithAlias:alias
                                                         username:username 
                                                         password:password
                                                     organization:organization
                                                        serverUrl:profUrl];
            profile.alwaysAskPassword = askPassword;
            profile.tempPassword = tempPassword;
            [servers addObject:profile];
        }
        
        self.resourceClient = [[JSRESTResource alloc] initWithProfile:(JSProfile *)[servers objectAtIndex:self.activeServerIndex]];
        self.reportClient = [[JSRESTReport alloc] initWithProfile:(JSProfile *)[servers objectAtIndex:self.activeServerIndex]];
        [self setProfile:[servers objectAtIndex:self.activeServerIndex]];        
        self.activeServerIndex = [prefs integerForKey:@"jaspersoft.server.active"];
        if (self.activeServerIndex < 0 || self.activeServerIndex >= count) { 
            self.activeServerIndex = 0;
        }
    }
}

- (void)setProfile:(JSProfile *)profile {
    if (profile == nil) {
        self.resourceClient = nil;
        self.reportClient = nil;
    } else {    
        if (!self.resourceClient) { self.resourceClient = [[JSRESTResource alloc] init]; }
        if (!self.reportClient) { self.reportClient = [[JSRESTReport alloc] init]; }
        self.resourceClient.serverProfile = profile;
        self.reportClient.serverProfile = profile;
    }
    
    [self setResourceClientForControllers:self.resourceClient];
    
    NSInteger index = [servers indexOfObject:profile];
    
	if (index >= 0) {
        [self.favorites synchronizeWithUserDefaults];
        self.favorites = [[JSFavoritesHelper alloc] initWithServerIndex:index andProfile:profile];
		NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
		[prefs setInteger:index forKey:@"jaspersoft.server.active"];
        self.activeServerIndex = index;
	}    
}

- (void)saveServers {
	if (servers) {	
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        	
        for (NSInteger i = 0; i < servers.count; ++i) {
            JSProfile *profile = [servers objectAtIndex:i];
    
            [prefs setObject:profile.alias forKey:[NSString stringWithFormat: @"jaspersoft.server.alias.%d", i]];
            [prefs setObject:profile.serverUrl forKey:[NSString stringWithFormat: @"jaspersoft.server.baseUrl.%d", i]];
            [prefs setObject:profile.organization forKey:[NSString stringWithFormat: @"jaspersoft.server.organization.%d", i]];
            [prefs setObject:profile.alwaysAskPassword forKey:[NSString stringWithFormat: @"jaspersoft.server.alwaysAskPassword.%d", i]];
            
            // TODO: make store of password safe using SFHF
            [prefs setObject:profile.username forKey:[NSString stringWithFormat: @"jaspersoft.server.username.%d", i]];
            
            // Save password inside keychain storage by profile ID (hashed as SHA1)
            [SSKeychain setPassword:profile.password forService:[self.class keychainServiceName] account:[profile profileID]];
            
            if (profile.alwaysAskPassword.boolValue) {
                profile.password = nil;
            }
        }
        [prefs setInteger: servers.count forKey: @"jaspersoft.server.count"];
        [prefs synchronize];
        
    }
}


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [JSAppUpdater update];
    
    // Override point for customization after application launch.
    sharedInstance = self;
        
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSInteger firstRun = [prefs  integerForKey:@"jaspersoft.mobile.firstRun"];    
	[self loadServers];

    if (self.reportClient != nil) {
        self.reportClient.timeoutInterval = [prefs integerForKey:keyReportRequestTimeoutSeconds] ?: defaultReportRequestTimeoutSeconds;        
    }
    
    if (self.resourceClient != nil) {
        self.resourceClient.timeoutInterval = [prefs integerForKey:keyDefaultRequestTimeoutSeconds] ?: defaultRequestTimeoutSeconds;        
        [(JSUIBaseRepositoryViewController *)(navigationController.topViewController) setResourceClient:self.resourceClient];
        [(JSUIBaseRepositoryViewController *)(searchController.topViewController) setResourceClient:self.resourceClient];
        [(JSUIBaseRepositoryViewController *)(favoritesController.topViewController) setResourceClient:self.resourceClient];
        [(JSUIBaseRepositoryViewController *)(libraryController.topViewController) setResourceClient:self.resourceClient];
        
        navigationController.title = NSLocalizedString(@"view.repository",@"");
        favoritesController.title = NSLocalizedString(@"view.favorites",@"");
        searchController.title = NSLocalizedString(@"view.search",@"");
        settingsController.title = NSLocalizedString(@"view.servers",@"");
        libraryController.title = NSLocalizedString(@"view.library",@"");
    }
	
    NSArray *controllers = [NSArray arrayWithObjects:libraryController, navigationController, favoritesController, searchController, settingsController, nil];
    tabBarController.viewControllers = controllers;
    tabBarController.delegate = self;
    
    [self.window addSubview:tabBarController.view];
    
    if (firstRun == 0 || [servers count] == 0 || (self.resourceClient.serverProfile.alwaysAskPassword.boolValue &&
                                                  self.resourceClient.serverProfile.password == nil)) {
        [tabBarController setSelectedIndex:4];
        
        if (firstRun == 0) {
            [self saveServers];
            [prefs setInteger:1 forKey:@"jaspersoft.mobile.firstRun"];
            [prefs synchronize];
        } else if (self.resourceClient.serverProfile.alwaysAskPassword.boolValue &&
                   self.resourceClient.serverProfile.password == nil) {
            [self disableTabBar];
        }
    } else {
        [tabBarController setSelectedIndex:0];
	}

    return YES;
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

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [self.favorites synchronizeWithUserDefaults];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    // Re-set timeouts from project settings (if setting was changed)
    self.resourceClient.timeoutInterval = [prefs integerForKey:keyDefaultRequestTimeoutSeconds] ?: defaultRequestTimeoutSeconds;
    self.reportClient.timeoutInterval = [prefs integerForKey:keyReportRequestTimeoutSeconds] ?: defaultReportRequestTimeoutSeconds;
}


- (void)applicationWillTerminate:(UIApplication *)application {    
    [self.favorites synchronizeWithUserDefaults];
}

#pragma mark - 
#pragma mark TabBarController delegate methods

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    
    // Go to root controller for favorites navigation
    if (self.favoritesController == viewController) {
        [self.favoritesController popToRootViewControllerAnimated:YES];
    }
    
    if (self.libraryController == viewController) {
        [(JSUIBaseRepositoryViewController *)self.libraryController.topViewController clear];
    } else if (self.navigationController == viewController) {
        [(JSUIBaseRepositoryViewController *)self.navigationController.topViewController clear];
    }
}

//- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
//    if (self.resourceClient.serverProfile.alwaysAskPassword.boolValue &&
//        self.resourceClient.serverProfile.password == nil && self.settingsController != viewController) {
//        return NO;
//    }
//    return YES;
//}

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	NSLog(@"Memory warning!!!");
}

@end

