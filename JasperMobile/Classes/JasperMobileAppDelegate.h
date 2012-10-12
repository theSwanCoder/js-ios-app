//
//  JaspersoftAppDelegate.h
//  Jaspersoft
//
//  Created by Giulio Toffoli on 4/9/11.
//  Copyright 2011 Jaspersoft Corp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <jaspersoft-sdk/JaspersoftSDK.h>
#import "JSFavoritesHelper.h"

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
@property (nonatomic) NSInteger activeServerIndex;

- (IBAction)configureServersDone:(id)sender;
+ (JasperMobileAppDelegate *)sharedInstance;
+ (NSString *)keychainServiceName;
- (void)loadServers;
- (void)saveServers;
- (void)setProfile:(JSProfile *)profile;
- (void)disableTabBar;
- (void)enableTabBar;

@end

