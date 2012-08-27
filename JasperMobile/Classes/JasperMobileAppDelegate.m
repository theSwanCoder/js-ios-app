//
//  JaspersoftAppDelegate.m
//  Jaspersoft
//
//  Created by Giulio Toffoli on 4/9/11.
//  Copyright 2011 Jaspersoft Corp.. All rights reserved.
//

#import "JasperMobileAppDelegate.h"
#import "JSUIBaseRepositoryViewController.h"

@implementation JasperMobileAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize settingsController;
@synthesize searchController;
@synthesize favoritesController;
@synthesize tabBarController;
@synthesize servers;
@synthesize client = _client; // the active client
@synthesize activeServerIndex;
@synthesize favorites;

static JasperMobileAppDelegate *sharedInstance = nil;

// Private time out properties
static const int defaultRequestTimeoutSeconds = 10;
static const int defaultReportRequestTimeoutSeconds = 30;
static NSString * const keyDefaultRequestTimeoutSeconds = @"defaultRequestTimeoutSeconds";
static NSString * const keyReportRequestTimeoutSeconds = @"reportRequestTimeoutSeconds";
static NSString * const reportFileMethod = @"reportFile";
static NSString * const reportRunMethod = @"reportRun";


+ (JasperMobileAppDelegate *)sharedInstance {
    return sharedInstance;
}

- (IBAction)configureServersDone:(id)sender {
	

	[navigationController popToRootViewControllerAnimated:NO];
    [(JSUIBaseRepositoryViewController *)navigationController.topViewController clear];
    [(JSUIBaseRepositoryViewController *)navigationController.topViewController setClient: self.client];
    if ([searchController.topViewController respondsToSelector:@selector(clear)])
    {
        [searchController.topViewController performSelector:@selector(clear)];
    }
    [(JSUIBaseRepositoryViewController *)searchController.topViewController setClient: self.client];
    
    
    [tabBarController setSelectedIndex:0];
    
    [navigationController.topViewController performSelector:@selector(updateTableContent) withObject:nil afterDelay:0.0];
	
}


-(void)loadServers {
	
	if (servers == nil)
	{
		servers = [[NSMutableArray alloc] initWithCapacity:1];
	}
    
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	
    NSInteger count = [prefs  integerForKey:@"jaspersoft.server.count"];
	
    NSInteger firstRun = [prefs  integerForKey:@"jaspersoft.mobile.firstRun"];
    
    if (count == 0)
    {
        //If this is the first time we are using this application, we should load a special demo configuration...
        if (firstRun == 0) // First run has never been set...
        {
            JSServerProfile *jsServerProfile = [[JSServerProfile alloc] initWithAlias: @"Jaspersoft Mobile Demo"
                                                                             Username: @"phoneuser"
                                                                             Password: @"phoneuser"
                                                                         Organization: @"organization_1"
                                                                                  Url: @"http://mobiledemo.jaspersoft.com/jasperserver-pro"];
            
            JSClient *tmpClient = [[JSClient alloc] initWithJSServerProfile: jsServerProfile];
            
            [servers addObject: tmpClient];
            [jsServerProfile release];
            [tmpClient release];
        }
    }
    
    
	for (NSInteger i=0; i<count; ++i) {
		
        JSServerProfile *jsServerProfile = [[JSServerProfile alloc] initWithAlias: [prefs objectForKey:[NSString stringWithFormat: @"jaspersoft.server.alias.%d",i]]
                      Username: [prefs objectForKey:[NSString stringWithFormat: @"jaspersoft.server.username.%d",i]]
                      Password: [prefs objectForKey:[NSString stringWithFormat: @"jaspersoft.server.password.%d",i]]
                      Organization: [prefs objectForKey:[NSString stringWithFormat: @"jaspersoft.server.organization.%d",i]]
                      Url: [prefs objectForKey:[NSString stringWithFormat: @"jaspersoft.server.baseUrl.%d",i]]];
        JSClient *tmpClient = [[JSClient alloc] initWithJSServerProfile: jsServerProfile];
        
		[servers addObject: tmpClient];
        [jsServerProfile release];
		[tmpClient release];
	}
	
	if (count > 0)
	{
        self.client = (JSClient *)[servers objectAtIndex:self.activeServerIndex];
        self.activeServerIndex = [prefs integerForKey:@"jaspersoft.server.active"];
		if (self.activeServerIndex < 0 || self.activeServerIndex >= count) self.activeServerIndex = 0;
	}
    
}

- (void)setClient:(JSClient *)client 
{
    _client = client;
	NSInteger index = [servers indexOfObject:client];
	
	if (index >= 0)
	{
        [self.favorites synchronizeWithUserDefaults];
        self.favorites = [[[JSFavoritesHelper alloc] initWithServerIndex:index andClient:client] autorelease];
		NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
		[prefs setInteger:index forKey:@"jaspersoft.server.active"];
        self.activeServerIndex = index;
	}
}


-(void)saveServers {
	if (servers == nil) return;
	
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	
	for (NSInteger i=0; i< [servers count]; ++i)
	{
		JSClient *tmpClient = [servers objectAtIndex:i];
		
	    [prefs setObject: [[tmpClient jsServerProfile] alias] forKey:[NSString stringWithFormat: @"jaspersoft.server.alias.%d",i]];
		[prefs setObject: [[tmpClient jsServerProfile] baseUrl] forKey:[NSString stringWithFormat: @"jaspersoft.server.baseUrl.%d",i]];
		[prefs setObject: [[tmpClient jsServerProfile] organization] forKey:[NSString stringWithFormat: @"jaspersoft.server.organization.%d",i]];
		
		// TODO: make store of password safe using SFHF....
		[prefs setObject: [[tmpClient jsServerProfile] username] forKey:[NSString stringWithFormat: @"jaspersoft.server.username.%d",i]];
		[prefs setObject: [[tmpClient jsServerProfile] password] forKey:[NSString stringWithFormat: @"jaspersoft.server.password.%d",i]];
	}
	[prefs setInteger: [servers count] forKey: @"jaspersoft.server.count"];
	[prefs synchronize];
	
	
}


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.
    sharedInstance = self;
        
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSInteger firstRun = [prefs  integerForKey:@"jaspersoft.mobile.firstRun"];
    NSArray *reportMethods = [NSArray arrayWithObjects:reportFileMethod, reportRunMethod, nil];    
    
	[self loadServers];
    
    if (self.client != nil)
    {
        // Set timeouts for JSClient from project settings
        self.client.timeOut = [prefs integerForKey:keyDefaultRequestTimeoutSeconds] ?: defaultRequestTimeoutSeconds;
        for(NSString *reportMethod in reportMethods) {
            [self.client setTimeOut:([prefs integerForKey:keyReportRequestTimeoutSeconds] ?: defaultRequestTimeoutSeconds) forMethod:reportMethod];
        }
        
        // Set the client to the repository view...
        [(JSUIBaseRepositoryViewController *)(navigationController.topViewController) setClient: self.client];
        [(JSUIBaseRepositoryViewController *)(searchController.topViewController) setClient: self.client];
        [(JSUIBaseRepositoryViewController *)(favoritesController.topViewController) setClient: self.client];
    }
	
    NSArray* controllers = [NSArray arrayWithObjects:navigationController, favoritesController, searchController, settingsController, nil];
    tabBarController.viewControllers = controllers;
    tabBarController.delegate = self;
    
    
    [self.window addSubview:tabBarController.view];
    
    if (firstRun == 0 || [servers count] == 0)
	{
        [tabBarController setSelectedIndex:3];
        
        if (firstRun == 0)
        {
            [self saveServers];
            [prefs setInteger:1 forKey:@"jaspersoft.mobile.firstRun"];
            [prefs synchronize];
        }
    }
	else
	{
        [tabBarController setSelectedIndex:0];
		
		[navigationController.topViewController performSelector:@selector(updateTableContent) withObject:nil afterDelay:0.0];
		
	}
    
    // Add the navigation controller's view to the window and display.
    

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
    [self.favorites synchronizeWithUserDefaults];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSArray *reportMethods = [NSArray arrayWithObjects:reportFileMethod, reportRunMethod, nil];    
    
    // Re-set timeouts for JSClient from project settings (if setting was changed)
    self.client.timeOut = [prefs integerForKey: keyDefaultRequestTimeoutSeconds] ?: defaultRequestTimeoutSeconds;
    for(NSString *reportMethod in reportMethods) {
        [self.client setTimeOut:([prefs integerForKey:keyReportRequestTimeoutSeconds] ?: defaultRequestTimeoutSeconds) forMethod:reportMethod];
    }
}


- (void)applicationWillTerminate:(UIApplication *)application {    
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
    [self.favorites synchronizeWithUserDefaults];
}

#pragma mark - 
#pragma mark TabBarController delegate methods

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    // Go to root controller for favorites navigation
    if (self.favoritesController == viewController) {
        [self.favoritesController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
	
	NSLog(@"Memory warning!!!");
}


- (void)dealloc {
    [tabBarController release];
	[navigationController release];
    [searchController release];
	[settingsController release];
    [favoritesController release];
    [favorites release];
	[window release];
	[super dealloc];
}


@end

