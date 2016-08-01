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
#import "JMExportManager.h"
#import "JMConstants.h"
#import "GAI.h"
#import "SWRevealViewController.h"
#import "JMThemesManager.h"
#import "NSObject+Additions.h"
#import "JMCoreDataManager.h"

NSString *const JMAppDelegateWillDestroyExternalWindowNotification = @"JMAppDelegateWillDestroyExternalWindowNotification";

static NSString * const kGAITrackingID      = @"UA-57445224-1";
static NSString * const kGAITrackingDebugID = @"UA-76950527-1";
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
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelError];

#ifndef __RELEASE__
    [[GAI sharedInstance] trackerWithTrackingId:kGAITrackingDebugID];
#else
    [[GAI sharedInstance] trackerWithTrackingId:kGAITrackingID];
#endif

    SWRevealViewController *revealViewController = (SWRevealViewController *) self.window.rootViewController;
    revealViewController.frontViewController = [JMUtils launchScreenViewController];
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    if ([self isExternalScreenAvailable]) {
        UIScreen *externalScreen = [UIScreen screens][1];
        self.externalWindow = [self createWindowWithScreen:externalScreen];
    }
    [self setupScreenConnectionNotifications];
    [self removeSplashView];

    [[JMThemesManager sharedManager] applyCurrentTheme];
    [[JMSessionManager sharedManager] restoreLastSessionWithCompletion:^(BOOL isSessionRestored) {

        LoginCompletionBlock loginCompletionBlock = ^{
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
            loginCompletionBlock();

            JMServerProfile *activeServerProfile = [JMServerProfile serverProfileForJSProfile:self.restClient.serverProfile];
            if (activeServerProfile && activeServerProfile.askPassword.boolValue) {
                [JMUtils showLoginViewForRestoreSessionWithCompletion:loginCompletionBlock];
            } else {
                // TODO: remove reseting of session's 'environment'
                SWRevealViewController *revealViewController = (SWRevealViewController *) [UIApplication sharedApplication].delegate.window.rootViewController;
                JMMenuViewController *menuViewController = (JMMenuViewController *) revealViewController.rearViewController;
                [menuViewController openCurrentSection];
            }

        } else {
            [JMUtils showLoginViewAnimated:NO
                                completion:nil
                           loginCompletion:loginCompletionBlock];
        }
    }];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self discardScreenConnectionNotifications];
    [self destroyExternalWindow];
    [self addSplashView];
    [[JMExportManager sharedInstance] cancelAll];
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
    UITraitCollection *currentTraitCollection = self.window.rootViewController.traitCollection;
    
    shouldDisplayIntro &= !(currentTraitCollection.userInterfaceIdiom == UIUserInterfaceIdiomPad && currentTraitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact);
    
    if (shouldDisplayIntro) {
        SWRevealViewController *revealViewController = (SWRevealViewController *) self.window.rootViewController;
        JMOnboardIntroViewController *introViewController = (JMOnboardIntroViewController *) [revealViewController.storyboard instantiateViewControllerWithIdentifier:@"JMOnboardIntroViewController"];
        [revealViewController presentViewController:introViewController animated:YES completion:nil];
    }
}

#pragma mark - Splash View
- (void)addSplashView
{
    UIView *splashView = [JMUtils launchScreenViewController].view;
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

#pragma mark - Work with external window

- (BOOL)isExternalScreenAvailable
{
    // TODO: investigate a case when count more than 2
    return [UIScreen screens].count == 2;
}

- (UIWindow *)createWindowWithScreen:(UIScreen *)screen
{
    JMLog(@"%@", NSStringFromSelector(_cmd));
    UIWindow *window = [UIWindow new];
    window.clipsToBounds = YES;
    window.backgroundColor = [UIColor whiteColor];

    UIScreenMode *desiredMode = screen.availableModes.firstObject;
    CGRect rect = CGRectZero;
    rect.size = desiredMode.size;
    window.frame = rect;
    window.screen = screen;
    return window;
}

- (void)destroyExternalWindow
{
    JMLog(@"%@", NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] postNotificationName:JMAppDelegateWillDestroyExternalWindowNotification
                                                        object:nil];
    self.externalWindow = nil;
}

#pragma mark - Notifications
- (void)setupScreenConnectionNotifications
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

    [center addObserver:self
               selector:@selector(handleScreenDidConnectNotification:)
                   name:UIScreenDidConnectNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(handleScreenDidDisconnectNotification:)
                   name:UIScreenDidDisconnectNotification
                 object:nil];
}

- (void)discardScreenConnectionNotifications
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self
                      name:UIScreenDidConnectNotification
                    object:nil];
    [center removeObserver:self
                      name:UIScreenDidDisconnectNotification
                    object:nil];
}

- (void)handleScreenDidConnectNotification:(NSNotification *)notification
{
    UIScreen *screen = notification.object;
    if (!self.externalWindow) {
        self.externalWindow = [self createWindowWithScreen:screen];
    } else {
        // TODO: how handle this case?
        JMLog(@"external window already exists");
    }
}

- (void)handleScreenDidDisconnectNotification:(NSNotification *)notification
{
    UIScreen *screen = notification.object;
    if (screen == self.externalWindow.screen) {
        [self destroyExternalWindow];
    }
}

@end
