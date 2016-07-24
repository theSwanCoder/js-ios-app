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
//  JMWebViewManager.h
//  TIBCO JasperMobile
//

#import "JMWebViewManager.h"
#import "JMUtils.h"
#import "JMWebEnvironment.h"
#import "JMVIZWebEnvironment.h"
#import "JMRESTWebEnvironment.h"

NSString *const JMWebviewManagerDidResetWebviewsNotification = @"JMWebviewManagerDidResetWebviewsNotification";

@interface JMWebViewManager()
@property (nonatomic, strong) NSMutableArray *webEnvironments;
@end

@implementation JMWebViewManager

#pragma mark - Handle Memory Warnings
- (void)handleMemoryWarnings
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    self.webEnvironments = [NSMutableArray array];
}

#pragma mark - Lifecycle
- (void)dealloc
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)sharedInstance {
    static JMWebViewManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _webEnvironments = [NSMutableArray array];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleMemoryWarnings)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(cookiesDidChange:)
                                                     name:JSRestClientDidChangeCookies
                                                   object:nil];
    }
    return self;
}

#pragma mark - Custom Accessors
- (NSArray *)cookies
{
    if(!_cookies) {
        _cookies = self.restClient.cookies;
    }
    return _cookies;
}

#pragma mark - Public API
- (JMWebEnvironment * __nonnull)reusableWebEnvironmentWithId:(NSString * __nonnull)identifier
{
    return [self reusableWebEnvironmentWithId:identifier flowType:JMResourceFlowTypeUndefined];
}

- (JMWebEnvironment * __nonnull)reusableWebEnvironmentWithId:(NSString * __nonnull)identifier flowType:(JMResourceFlowType)flowType
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    JMLog(@"identifier: %@", identifier);

    JMWebEnvironment *webEnvironment = [self findWebEnvironmentForId:identifier];
    if (!webEnvironment) {
        webEnvironment = [self createNewWebEnvironmentWithId:identifier flowType:flowType needReuse:YES];
        [self.webEnvironments addObject:webEnvironment];
    }

    return webEnvironment;
}

- (JMWebEnvironment * __nonnull)webEnvironment
{
    return [self webEnvironmentForFlowType:JMResourceFlowTypeUndefined];
}

- (JMWebEnvironment * __nonnull)webEnvironmentForFlowType:(JMResourceFlowType)flowType
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    JMWebEnvironment *webEnvironment = [self createNewWebEnvironmentWithId:nil flowType:flowType needReuse:NO];
    return webEnvironment;
}

#pragma mark - Private API

- (JMWebEnvironment *)createNewWebEnvironmentWithId:(NSString *)identifier flowType:(JMResourceFlowType)flowType needReuse:(BOOL)needReuse
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    JMWebEnvironment *webEnvironment;
    switch (flowType) {
        case JMResourceFlowTypeUndefined: {
            webEnvironment = [JMWebEnvironment webEnvironmentWithId:identifier
                                                         initialCookies:self.cookies];
            break;
        }
        case JMResourceFlowTypeREST: {
            webEnvironment = [JMRESTWebEnvironment webEnvironmentWithId:identifier
                                                         initialCookies:self.cookies];
            break;
        }
        case JMResourceFlowTypeVIZ: {
            webEnvironment = [JMVIZWebEnvironment webEnvironmentWithId:identifier
                                                        initialCookies:self.cookies];
            break;
        }
    }
    webEnvironment.reusable = needReuse;
    webEnvironment.flowType = flowType;
    return webEnvironment;
}

- (void)reset
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    for(JMWebEnvironment *webEnvironment in self.webEnvironments) {
        [webEnvironment.webView removeFromSuperview];
    }
    self.webEnvironments = [NSMutableArray array];
}

#pragma mark - Notifications
- (void)cookiesDidChange:(NSNotification *)notification
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    if ([notification.object isKindOfClass:[JSRESTBase class]]) {
        // We need set cookies from correct restClient
        JSRESTBase *restClient = notification.object;
        self.cookies = restClient.cookies;
        JMLog(@"new cookies: %@", self.cookies);
        // TODO: what need we do if cookies if nil?
        for (JMWebEnvironment *webEnvironment in self.webEnvironments) {
            switch(webEnvironment.cookiesState) {
                case JMWebEnvironmentCookiesStateEmpty: {
                    // TODO: do not change this state
                    break;
                }
                case JMWebEnvironmentCookiesStateValid: {
                    webEnvironment.cookiesState = JMWebEnvironmentCookiesStateNotValid;
                    break;
                }
                case JMWebEnvironmentCookiesStateNotValid: {
                    webEnvironment.cookiesState = JMWebEnvironmentCookiesStateNotValid;
                    break;
                }
                case JMWebEnvironmentCookiesStateNeedUpdate: {
                    // TODO: do not change this state
                    break;
                }
            }
        }
    } else {
        // TODO: need handle this case?
    }
}

#pragma mark - Helpers
- (JMWebEnvironment *)findWebEnvironmentForId:(NSString *)identifier
{
    JMWebEnvironment *webEnvironment;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.identifier == %@", identifier];
    NSArray *filtredWebEnvironments = [self.webEnvironments filteredArrayUsingPredicate:predicate];

    if ( filtredWebEnvironments.count == 0 ) {
        return nil;
    } else if ( filtredWebEnvironments.count > 1 ) {
        return nil;
    } else {
        webEnvironment = [filtredWebEnvironments firstObject];
    }
    return webEnvironment;
}

@end
