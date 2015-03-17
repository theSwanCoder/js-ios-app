/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2014 TIBCO Software, Inc. All rights reserved.
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
#import "JMServerProfile+Helpers.h"

NSString * const kJMSavedSessionKey = @"JMSavedSessionKey";

static JMSessionManager *_sharedManager = nil;

@interface JMSessionManager ()
@property (nonatomic, strong, readwrite) JSRESTBase *restClient;

@end

@implementation JMSessionManager

+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [JMSessionManager new];
    });
    
    return _sharedManager;
}

- (void) createSessionWithServerProfile:(JSProfile *)serverProfile keepLogged:(BOOL)keepLogged completion:(void(^)(BOOL success))completionBlock
{
    self.restClient = [[JSRESTBase alloc] initWithServerProfile:serverProfile keepLogged:keepLogged];
    if ([self.restClient isSessionAuthorized] && self.restClient.serverInfo) {
        [self saveActiveSessionIfNeeded];
        if (completionBlock) {
            completionBlock(YES);
        }
    } else if (completionBlock) {
        completionBlock(NO);
    }
}

- (void) saveActiveSessionIfNeeded {
    if (self.restClient && self.restClient.keepSession) {
        NSData *archivedSession = [NSKeyedArchiver archivedDataWithRootObject:self.restClient];
        [[NSUserDefaults standardUserDefaults] setObject:archivedSession forKey:kJMSavedSessionKey];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kJMSavedSessionKey];
    }
}

- (void) restoreLastSessionWithCompletion:(void(^)(BOOL success))completionBlock
{
    if (!self.restClient) {
        NSData *savedSession = [[NSUserDefaults standardUserDefaults] objectForKey:kJMSavedSessionKey];
        if (savedSession) {
            id unarchivedSession = [NSKeyedUnarchiver unarchiveObjectWithData:savedSession];
            if (unarchivedSession && [unarchivedSession isKindOfClass:[JSRESTBase class]]) {
                self.restClient = unarchivedSession;
            }
        }
    }
    if (completionBlock) {
        if (self.restClient && self.restClient.keepSession) {
            completionBlock([self.restClient isSessionAuthorized] && self.restClient.serverInfo);
        } else {
            completionBlock(NO);
        }
    }
}

- (BOOL) userIsLoggedIn
{
    return !![[NSUserDefaults standardUserDefaults] objectForKey:kJMSavedSessionKey];
}

- (void) logout
{
    [self.restClient deleteCookies];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kJMSavedSessionKey];
    [self.restClient cancelAllRequests];
    self.restClient = nil;
}

- (NSPredicate *)predicateForCurrentServerProfile
{
    JMServerProfile *activaServerProfile = [JMServerProfile serverProfileForname:self.restClient.serverProfile.alias];
    NSMutableArray *predicates = [NSMutableArray array];
    [predicates addObject:[NSPredicate predicateWithFormat:@"serverProfile == %@", activaServerProfile]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"username == %@", self.restClient.serverProfile.username]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"organization == %@", self.restClient.serverProfile.organization]];
    
    return [[NSCompoundPredicate alloc] initWithType:NSAndPredicateType subpredicates:predicates];
}

@end
