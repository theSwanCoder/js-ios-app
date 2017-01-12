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
//  JMSessionManager.m
//  TIBCO JasperMobile
//

#import "JMSessionManager.h"
#import "JMCancelRequestPopup.h"
#import "JMWebViewManager.h"
#import "JMExportManager.h"

#import "JMMenuViewController.h"
#import "SWRevealViewController.h"
#import "JMAnalyticsManager.h"
#import "AFAutoPurgingImageCache.h"
#import "AFImageDownloader.h"
#import "UIKit+AFNetworking.h"
#import "JMConstants.h"
#import "JMUtils.h"

NSString * const kJMSavedSessionKey = @"JMSavedSessionKey";

static JMSessionManager *_sharedManager = nil;

@interface JMSessionManager ()
@property (nonatomic, strong, readwrite) JSRESTBase *restClient;
@property (nonatomic, strong, readwrite) JSUserProfile *serverProfile;

@end

@implementation JMSessionManager

+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [JMSessionManager new];
        [[NSNotificationCenter defaultCenter] addObserver:_sharedManager selector:@selector(saveActiveSessionIfNeeded:) name:kJSSessionDidAuthorizedNotification object:_sharedManager.restClient];
    });

    return _sharedManager;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setRestClient:(JSRESTBase *)restClient
{
    _serverProfile = (JSUserProfile *)restClient.serverProfile;
}

- (void) createSessionWithServerProfile:(JSProfile *)serverProfile completion:(void(^)(NSError *error))completionBlock
{
    self.restClient = [[JSRESTBase alloc] initWithServerProfile:serverProfile];
    [self.restClient deleteCookies];

    [self.restClient verifyIsSessionAuthorizedWithCompletion:^(JSOperationResult * _Nullable result) {
        if (completionBlock) {
            completionBlock(result.error);
        }
    }];
}

- (void) updateSessionServerProfileWith:(JMServerProfile *)changedServerProfile {
    // update current active server profile
    self.restClient.serverProfile.alias = changedServerProfile.alias;
    self.restClient.serverProfile.keepSession = [changedServerProfile.keepSession boolValue];
    [self saveActiveSessionIfNeeded:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:JMServerProfileDidChangeNotification
                                                        object:changedServerProfile];
}

- (void) saveActiveSessionIfNeeded:(id)notification {
    if (self.restClient && self.restClient.serverProfile.keepSession) {
        NSData *archivedSession = [NSKeyedArchiver archivedDataWithRootObject:self.restClient];
        [[NSUserDefaults standardUserDefaults] setObject:archivedSession forKey:kJMSavedSessionKey];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kJMSavedSessionKey];
    }
}

- (void) restoreLastSessionWithCompletion:(void(^)(BOOL isSessionRestored))completion
{
    if (self.restClient && [self.restClient.cookies count]) {
        if (completion) {
            completion(YES);
        }
        return;
    }
    
    if (!self.restClient) { // try restore restClient
        NSData *savedSession = [[NSUserDefaults standardUserDefaults] objectForKey:kJMSavedSessionKey];
        if (savedSession) {
            id unarchivedSession = [NSKeyedUnarchiver unarchiveObjectWithData:savedSession];
            if (unarchivedSession && [unarchivedSession isKindOfClass:[JSRESTBase class]]) {
                self.restClient = unarchivedSession;
            }
        }
    }

    if (self.restClient && self.restClient.serverProfile.keepSession) { // try restore session

        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){

            JMServerProfile *activeServerProfile = [JMUtils activeServerProfile];
            if (activeServerProfile && !activeServerProfile.askPassword.boolValue) {
                [self.restClient verifyIsSessionAuthorizedWithCompletion:^(JSOperationResult * _Nullable result) {
                    dispatch_async(dispatch_get_main_queue(), ^(void){
                        if (completion) {
                            completion(!result.error);
                        }
                    });
                }];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    if (completion) {
                        completion(NO);
                    }
                });
            }
        });
    } else {
        if (completion) {
            completion(NO);
        }
    }
}

- (void) reset
{
    [self.restClient cancelAllRequests];
    [self.restClient deleteCookies];
    
    // Clear webView
    [[JMWebViewManager sharedInstance] reset];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (void)obsoleteSession
{
    JMLog(@"%@ - %@", self.class.description, NSStringFromSelector(_cmd));
    // USE ONLY FOR DEBUG PURPOSES
    NSArray <NSHTTPCookie *>*cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies;
    JMLog(@"Current cookies: %@", cookies);
    NSHTTPCookie *sessionCookie = [self selectSessionCookieFromCookies:cookies];
    NSMutableArray *newCookies = [NSMutableArray arrayWithArray:cookies];
    [newCookies removeObject:sessionCookie];
    JMLog(@"sessionCookie: %@", sessionCookie);
    NSHTTPCookie *newSessionCookie = [self changeValueForCookie:sessionCookie
                                                      withValue:@"SomeNewValue"];
    [newCookies addObject:newSessionCookie];
    [self.restClient updateCookiesWithCookies:newCookies];
    JMLog(@"Updated cookies: %@", newCookies);

    [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:sessionCookie];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:newSessionCookie];
}

- (void)obsoleteSessionInWebView
{
    JMLog(@"%@ - %@", self.class.description, NSStringFromSelector(_cmd));
    // USE ONLY FOR DEBUG PURPOSES
    NSArray <NSHTTPCookie *>*cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies;
    JMLog(@"Current cookies: %@", cookies);
    NSHTTPCookie *sessionCookie = [self selectSessionCookieFromCookies:cookies];
    NSMutableArray *newCookies = [NSMutableArray arrayWithArray:cookies];
    [newCookies removeObject:sessionCookie];
    JMLog(@"sessionCookie: %@", sessionCookie);
    NSHTTPCookie *newSessionCookie = [self changeValueForCookie:sessionCookie
                                                      withValue:@"SomeNewValue"];
    [newCookies addObject:newSessionCookie];
    [[JMWebViewManager sharedInstance] updateCookiesWithCookies:newCookies];
}

- (NSHTTPCookie *)selectSessionCookieFromCookies:(NSArray <NSHTTPCookie *>*)cookies
{
    NSHTTPCookie *sessionCookie;
    for (NSHTTPCookie *cookie in cookies) {
        if ([cookie.name isEqualToString:@"JSESSIONID"]) {
            sessionCookie = cookie;
            break;
        }
    }
    NSAssert(sessionCookie != nil, @"Session cookie was not found");
    return sessionCookie;
}

- (NSHTTPCookie *)changeValueForCookie:(NSHTTPCookie *)cookie withValue:(NSString *)value
{
    NSMutableDictionary <NSHTTPCookiePropertyKey, id> *properties = [cookie.properties mutableCopy];
    properties[NSHTTPCookieValue] = value;
    NSHTTPCookie *newCookie = [NSHTTPCookie cookieWithProperties:properties];
    return newCookie;
}


- (void) logout
{
    [self reset];

    [[JMExportManager sharedInstance] cancelAll];

    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kJMSavedSessionKey];
    self.restClient = nil;

    // Clearing of Images Cache
    AFImageDownloader *downloader = [UIImageView sharedImageDownloader];
    id <AFImageRequestCache> imageCache = downloader.imageCache;
    [imageCache removeAllImages];

    [[JMAnalyticsManager sharedManager] sendAnalyticsEventAboutLogout];
}

- (NSPredicate *)predicateForCurrentServerProfile
{
    NSMutableArray *currentServerProfilepredicates = [NSMutableArray array];
    [currentServerProfilepredicates addObject:[NSPredicate predicateWithFormat:@"serverProfile = %@", [JMUtils activeServerProfile]]];
    [currentServerProfilepredicates addObject:[NSPredicate predicateWithFormat:@"username = %@", [JMSessionManager sharedManager].serverProfile.username]];

    NSMutableArray *nilServerProfilepredicates = [NSMutableArray array];
    [nilServerProfilepredicates addObject:[NSPredicate predicateWithFormat:@"serverProfile = nil"]];
    [nilServerProfilepredicates addObject:[NSPredicate predicateWithFormat:@"username = nil"]];
    
    NSMutableArray *predicates = [NSMutableArray array];
    [predicates addObject:[[NSCompoundPredicate alloc] initWithType:NSAndPredicateType subpredicates:currentServerProfilepredicates]];
    [predicates addObject:[[NSCompoundPredicate alloc] initWithType:NSAndPredicateType subpredicates:nilServerProfilepredicates]];
    
    return [[NSCompoundPredicate alloc] initWithType:NSOrPredicateType subpredicates:predicates];
}

#pragma mark - Tests

- (void)updateRestClientWithClient:(JSRESTBase *)restClient
{
    NSLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    NSLog(@"restClient before: %@", self.restClient);
    self.restClient = restClient;
    NSLog(@"restClient after: %@", self.restClient);
}

@end
