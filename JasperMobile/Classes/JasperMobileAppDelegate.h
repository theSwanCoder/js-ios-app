//
//  JaspersoftAppDelegate.h
//  Jaspersoft
//
//  Created by Giulio Toffoli on 4/9/11.
//  Copyright 2011 Jaspersoft Corp.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <jasperserver-mobile-sdk-ios/JSClient.h>

@interface JasperMobileAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
    UINavigationController *searchController;
	UINavigationController *settingsController;
    UINavigationController *samplesController;
    
    UITabBarController *tabBarController;
	// This is a list configured servers. Each server is an instance of JSClient...
	NSMutableArray *servers;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) IBOutlet UINavigationController *searchController;
@property (nonatomic, retain) IBOutlet UINavigationController *settingsController;
@property (nonatomic, retain) IBOutlet UINavigationController *samplesController;

@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@property (nonatomic, readonly) NSMutableArray *servers;
@property (nonatomic, retain) JSClient *client;
@property (nonatomic) NSInteger activeServerIndex;

- (IBAction)configureServersDone:(id)sender;

+ (JasperMobileAppDelegate *)sharedInstance;
-(void)loadServers;
-(void)saveServers;

@end

