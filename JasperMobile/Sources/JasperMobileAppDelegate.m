/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2015 TIBCO Software, Inc. All rights reserved.
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
#import "JMOnboardIntroViewController.h"
#import "UIImage+Additions.h"


static NSString * const kGAITrackingID = @"UA-57445224-1";
static const NSInteger kSplashViewTag = 100;

@implementation JasperMobileAppDelegate

@synthesize window = _window;

#pragma mark - Initialization

- (id)init
{
    if (self = [super init]) {
        if ([JMAppUpdater isRunningForTheFirstTime]) {
            [self coreDataInit];
        } else {
            [JMAppUpdater update];
        }
        [JMAppUpdater updateAppVersionTo:[JMAppUpdater latestAppVersion]];

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

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [self removeSplashView];

    [[JMThemesManager sharedManager] applyCurrentTheme];
    [[JMSessionManager sharedManager] restoreLastSessionWithCompletion:^(BOOL isSessionRestored) {

        SWRevealViewController *revealViewController = (SWRevealViewController *) self.window.rootViewController;
        JMMenuViewController *menuViewController = (JMMenuViewController *) revealViewController.rearViewController;

        LoginCompletionBlock loginCompletionBlock = ^{
            [menuViewController setSelectedItemIndex:[JMMenuViewController defaultItemIndex]];

            // Configure Appirater
            [Appirater setAppId:@"467317446"];
            [Appirater setDaysUntilPrompt:0];
            [Appirater setUsesUntilPrompt:5];
            [Appirater setTimeBeforeReminding:2];
            [Appirater setDebug:NO];
            [Appirater appLaunched:YES];

            [self showOnboardIntroIfNeeded];
        };

        if (isSessionRestored) {
            self.restClient.timeoutInterval = [[NSUserDefaults standardUserDefaults] integerForKey:kJMDefaultRequestTimeout] ?: 120;

            if (!menuViewController.selectedItem) {
                loginCompletionBlock();
            }
        } else {
            JMServerProfile *activeServerProfile = [JMServerProfile serverProfileForJSProfile:self.restClient.serverProfile];
            if (activeServerProfile && activeServerProfile.askPassword.boolValue) {
                [JMUtils showLoginViewForRestoreSessionWithCompletion:loginCompletionBlock];
            } else {
                [JMUtils showLoginViewAnimated:NO
                                    completion:nil
                               loginCompletion:loginCompletionBlock];
            }
        }
    }];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self addSplashView];
}

- (BOOL)application:(UIApplication *)application shouldAllowExtensionPointIdentifier:(NSString *)extensionPointIdentifier {
    return ![extensionPointIdentifier isEqualToString: UIApplicationKeyboardExtensionPointIdentifier];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

#pragma mark - Private
- (void)coreDataInit
{
#ifndef __RELEASE__
    NSString *profilesPath = [[NSBundle mainBundle] pathForResource:@"profiles" ofType:@"json"];
    NSData *profilesData = [NSData dataWithContentsOfFile:profilesPath];
    NSArray *profilesArray = [[NSJSONSerialization JSONObjectWithData:profilesData options:NSJSONReadingAllowFragments error:nil] objectForKey:@"profiles"];
    if (profilesArray && profilesArray.count) {
        for (NSDictionary *profileDictionary in profilesArray) {
            JMServerProfile *serverProfile = (JMServerProfile *) [NSEntityDescription insertNewObjectForEntityForName:@"ServerProfile" inManagedObjectContext:[JMCoreDataManager sharedInstance].managedObjectContext];
            serverProfile.alias = profileDictionary[@"mAlias"];
            serverProfile.organization = profileDictionary[@"mOrganization"];
            serverProfile.serverUrl = profileDictionary[@"mServerUrl"];
            [[JMCoreDataManager sharedInstance] save:nil];
        }
    }
#endif
    
}

// Resets database and defaults
- (void)resetApplication
{
    [[JMCoreDataManager sharedInstance] resetPersistentStore];
    
    [[NSUserDefaults standardUserDefaults] setPersistentDomain:[NSDictionary dictionary]
                                                       forName:[[NSBundle mainBundle] bundleIdentifier]];
    
    // Update db with latest app version and demo profile
    [JMAppUpdater updateAppVersionTo:[JMAppUpdater latestAppVersion]];
    [self coreDataInit];
}

- (void)showOnboardIntroIfNeeded
{
    BOOL shouldDisplayIntro = ![[NSUserDefaults standardUserDefaults] objectForKey:kJMDefaultsIntroDidApear];
    if (shouldDisplayIntro) {
        SWRevealViewController *revealViewController = (SWRevealViewController *) self.window.rootViewController;
        JMOnboardIntroViewController *introViewController = (JMOnboardIntroViewController *) [revealViewController.storyboard instantiateViewControllerWithIdentifier:@"JMOnboardIntroViewController"];
        [revealViewController presentViewController:introViewController animated:YES completion:nil];
    }
}

#pragma mark - Splash View
- (void)addSplashView
{
    // TODO: replace this approach for getting right splash image
    NSString *splashImageName = [UIImage splashImageNameForOrientation:[UIApplication sharedApplication].statusBarOrientation];
    UIImage *splashImage = [UIImage imageNamed:splashImageName];
    UIImageView *splashView = [[UIImageView alloc] initWithImage:splashImage];
    splashView.tag = kSplashViewTag;
    [self.window addSubview:splashView];
}

- (void)removeSplashView
{
    for (UIView *subView in self.window.subviews) {
        if (subView.tag == kSplashViewTag) {
            [subView removeFromSuperview];
        }
    }
}


@end
