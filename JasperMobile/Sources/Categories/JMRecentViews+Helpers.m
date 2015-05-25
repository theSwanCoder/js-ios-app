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
//  JMRecentViews+Helpers.m
//  TIBCO JasperMobile
//

NSString * const kJMRecentViews = @"RecentViews";

#import "JMRecentViews+Helpers.h"
#import "JMServerProfile+Helpers.h"

@implementation JMRecentViews(Helpers)

+ (JMRecentViews *)recentViewsForResourceLookup:(JSResourceLookup *)resource
{
    NSFetchRequest *fetchRequest = [self recentViewFetchRequestWithValuesAndFields:resource.uri, @"uri", nil];
    return [[[JMCoreDataManager sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:nil] lastObject];
}

+ (void) updateCountOfViewsForResourceLookup:(JSResourceLookup *)resource;
{
    JMRecentViews *recentView = [self recentViewsForResourceLookup:resource];
    if (recentView) {
        recentView.countOfViews = @([recentView.countOfViews integerValue] + 1);
    } else {
        JSProfile *sessionServerProfile = [JMSessionManager sharedManager].restClient.serverProfile;
        JMServerProfile *activeServerProfile = [JMServerProfile serverProfileForJSProfile:sessionServerProfile];
        recentView = [NSEntityDescription insertNewObjectForEntityForName:kJMRecentViews inManagedObjectContext:[JMCoreDataManager sharedInstance].managedObjectContext];

        recentView.label = resource.label;
        recentView.uri = resource.uri;
        recentView.resourceDescription = resource.resourceDescription;
        recentView.username = sessionServerProfile.username;
        recentView.wsType = resource.resourceType;
        recentView.version = resource.version;
        recentView.creationDate = resource.creationDate;
        [activeServerProfile addRecentViewsObject:recentView];
    }
    recentView.lastViewDate = [NSDate date];
    [recentView.managedObjectContext save:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kJMRecentViewsDidChangedNotification object:nil];
}

- (JSResourceLookup *)wrapperFromJMRecentViews
{
    JSResourceLookup *resource = [[JSResourceLookup alloc] init];
    resource.uri = self.uri;
    resource.label = self.label;
    resource.resourceType = self.wsType;
    resource.creationDate = self.creationDate;
    resource.resourceDescription = self.resourceDescription;
    resource.version = self.version;
    return resource;
}

#pragma mark - Private

+ (NSFetchRequest *)recentViewFetchRequestWithValuesAndFields:(id)firstValue, ... NS_REQUIRES_NIL_TERMINATION
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:kJMRecentViews];
    NSMutableArray *predicates = [NSMutableArray arrayWithObject:[[JMSessionManager sharedManager] predicateForCurrentServerProfile]];
    
    va_list args;
    va_start(args, firstValue);
    for (NSString *value = firstValue; value != nil; value = va_arg(args, NSString*)) {
        NSString *queryFormat = [NSString stringWithFormat:@"%@ LIKE[cd] ", va_arg(args,NSString*)];
        [predicates addObject:[NSPredicate predicateWithFormat:[queryFormat stringByAppendingString:@"%@"], value]];
    }
    va_end(args);
    
    fetchRequest.predicate = [[NSCompoundPredicate alloc] initWithType:NSAndPredicateType subpredicates:predicates];
    return fetchRequest;
}
@end
