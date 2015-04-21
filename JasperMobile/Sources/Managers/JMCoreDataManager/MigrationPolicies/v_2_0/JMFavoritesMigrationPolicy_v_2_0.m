//
//  JMFavoritesMigrationPolicy_v_2_0.m
//  TIBCO JasperMobile
//
//  Created by Oleksii Gubariev on 4/20/15.
//  Copyright (c) 2015 TIBCO JasperMobile. All rights reserved.
//

#import "JMFavoritesMigrationPolicy_v_2_0.h"

@implementation JMFavoritesMigrationPolicy_v_2_0
- (BOOL)createDestinationInstancesForSourceInstance:(NSManagedObject *)sInstance
                                      entityMapping:(NSEntityMapping *)mapping
                                            manager:(NSMigrationManager *)manager
                                              error:(NSError **)error
{
    // Create a new object for the model context
    NSManagedObject *newObject =
    [NSEntityDescription insertNewObjectForEntityForName:[mapping destinationEntityName]
                                  inManagedObjectContext:[manager destinationContext]];
    
    // do our transfer of nsdate to nsstring
    id date = [sInstance valueForKey:@"creationDate"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
    
    // set the value for our new object
    [newObject setValue:[dateFormatter dateFromString:date] forKey:@"creationDate"];
    //    [newObject setValue:[sInstance valueForKey:@"title"] forKey:@"title"];
    
    // do the coupling of old and new
    [manager associateSourceInstance:sInstance withDestinationInstance:newObject forEntityMapping:mapping];
    
    return YES;
}
@end
