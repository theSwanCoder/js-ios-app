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
//  JMMigrateTo_v_2_0.m
//  TIBCO JasperMobile
//

#import "JMMigrateTo_v_2_0.h"
#import "JMFavorites.h"
#import "JMSavedResources.h"


@implementation JMMigrateTo_v_2_0
- (BOOL)createDestinationInstancesForSourceInstance:(NSManagedObject *)sourceInstance
                                      entityMapping:(NSEntityMapping *)mapping
                                            manager:(NSMigrationManager *)manager
                                              error:(NSError **)error
{
    NSArray *sourceKeys = sourceInstance.entity.attributesByName.allKeys;
    NSMutableDictionary *sourceValues = [[sourceInstance dictionaryWithValuesForKeys:sourceKeys] mutableCopy];

    // Create a new object for the model context
    NSManagedObject *destinationInstance = [NSEntityDescription insertNewObjectForEntityForName:[mapping destinationEntityName]
                                                                         inManagedObjectContext:[manager destinationContext]];
    NSArray *destinationKeys = destinationInstance.entity.attributesByName.allKeys;
    
    if ([[sourceInstance entity].name isEqualToString:@"SavedResources"]) {
        sourceValues[@"wsType"] = kJMSavedReportUnit;
    }
    
    if ([[sourceInstance entity].name isEqualToString:@"Favorites"]) {
        JMFavorites *favorite = (JMFavorites *)sourceInstance;
        if ([favorite.wsType isEqualToString:kJS_WS_TYPE_REPORT_UNIT] && [self isSavedItem:favorite]) {
            sourceValues[@"wsType"] = kJMSavedReportUnit;
        }
    }
    
    // set the values for our new object
    for (NSString *key in destinationKeys) {
        id value = [sourceValues valueForKey:key];
        if ([key isEqualToString:@"creationDate"]) {
            value = [self creationDateFromSourceInstance:sourceInstance];
        }
        // Avoid NULL values
        if (value && ![value isEqual:[NSNull null]]) {
            [destinationInstance setValue:value forKey:key];
        }
    }
    
    // do the coupling of old and new
    [manager associateSourceInstance:sourceInstance withDestinationInstance:destinationInstance forEntityMapping:mapping];
    
    return YES;
}

- (NSDate *)creationDateFromSourceInstance:(NSManagedObject *)sInstance
{
    // do our transfer of nsdate to nsstring
    id date = [sInstance valueForKey:@"creationDate"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
    
    return [dateFormatter dateFromString:date] ? : [NSDate date];
}

- (BOOL)isSavedItem:(JMFavorites *)item
{
    // Check request to login and handle it
    NSString *savedReportURIRegex = [NSString stringWithFormat:@"/%@/%@.[A-Z,a-z]{2,10}/%@.[A-Z,a-z]{2,10}", kJMReportsDirectory, item.label, kJMReportFilename];
    NSPredicate *savedReportURIValidator = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", savedReportURIRegex];
    return [savedReportURIValidator evaluateWithObject:item.uri];
}

@end
