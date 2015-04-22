//
//  JMMigrateTo_v_2_0.m
//  TIBCO JasperMobile
//
//  Created by Oleksii Gubariev on 4/22/15.
//  Copyright (c) 2015 TIBCO JasperMobile. All rights reserved.
//

#import "JMMigrateTo_v_2_0.h"

@implementation JMMigrateTo_v_2_0
- (BOOL)createDestinationInstancesForSourceInstance:(NSManagedObject *)sourceInstance
                                      entityMapping:(NSEntityMapping *)mapping
                                            manager:(NSMigrationManager *)manager
                                              error:(NSError **)error
{
    NSArray *sourceKeys = sourceInstance.entity.attributesByName.allKeys;
    NSDictionary *sourceValues = [sourceInstance dictionaryWithValuesForKeys:sourceKeys];

    // Create a new object for the model context
    NSManagedObject *destinationInstance = [NSEntityDescription insertNewObjectForEntityForName:[mapping destinationEntityName]
                                                                         inManagedObjectContext:[manager destinationContext]];
    NSArray *destinationKeys = destinationInstance.entity.attributesByName.allKeys;
    
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

@end
