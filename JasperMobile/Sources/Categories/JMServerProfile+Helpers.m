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
//  JMServerProfile+Helpers.m
//  TIBCO JasperMobile
//

#import "JMServerProfile+Helpers.h"
#import "JMConstants.h"
#import <objc/runtime.h>
#import "JMSessionManager.h"


@implementation JMServerProfile (Helpers)

+ (float) minSupportedServerVersion
{
    return [JSConstants sharedInstance].SERVER_VERSION_CODE_EMERALD_5_6_0;
}

+ (JMServerProfile *)serverProfileForname:(NSString *)serverName
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"ServerProfile"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"%K == %@", @"alias", serverName]];
    return [[[self managedObjectContext] executeFetchRequest:fetchRequest error:nil] lastObject];
}

+ (void) cloneServerProfile:(JMServerProfile *)serverProfile
{
    NSString *entityName = [[serverProfile entity] name];
    
    //create new object in data store
    JMServerProfile *newServerProfile = [NSEntityDescription
                                         insertNewObjectForEntityForName:entityName
                                         inManagedObjectContext:[self managedObjectContext]];

    NSInteger cloneNumber = 0;
    NSString *serverName = nil;
    do {
        serverName = (cloneNumber++ > 0) ? [serverProfile.alias stringByAppendingFormat:@" %zd", cloneNumber] : serverProfile.alias;
    } while ([self serverProfileForname:serverName]);
    
    newServerProfile.alias          = serverName;
    newServerProfile.askPassword    = serverProfile.askPassword;
    newServerProfile.organization   = serverProfile.organization;
    newServerProfile.serverUrl      = serverProfile.serverUrl;
    [[self managedObjectContext] save:nil];
}

- (void) checkServerProfileWithCompletionBlock:(void(^)(NSError *error))completionBlock
{
    JSProfile *profile = [[JSProfile alloc] initWithAlias:self.alias
                                                serverUrl:self.serverUrl
                                             organization:self.organization
                                                 username:nil
                                                 password:nil];
    
    __block JSRESTBase *restBase = [[JSRESTBase alloc] init];
    restBase.serverProfile = profile;
    


    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        float serverVersion = restBase.serverInfo.versionAsFloat;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                if (serverVersion >= [JMServerProfile minSupportedServerVersion]) {
                    completionBlock(nil);
                } else {
                    NSString *title = [NSString stringWithFormat:JMCustomLocalizedString(@"error.server.notsupported.title", nil), serverVersion];
                    NSString *message = [NSString stringWithFormat:JMCustomLocalizedString(@"error.server.notsupported.msg", nil), [JMServerProfile minSupportedServerVersion]];

                    if (!restBase.serverInfo) {
                        title = JMCustomLocalizedString(@"error.unknownhost.dialog.title", nil);
                        message = JMCustomLocalizedString(@"error.unknownhost.dialog.msg", nil);
                    }
                    completionBlock([NSError errorWithDomain:title code:NSNotFound userInfo:@{NSLocalizedDescriptionKey : message}]);
                }
            }
        });
    });
}

#pragma mark - Private

+ (NSManagedObjectContext *)managedObjectContext
{
    return [JMUtils managedObjectContext];
}

@end
