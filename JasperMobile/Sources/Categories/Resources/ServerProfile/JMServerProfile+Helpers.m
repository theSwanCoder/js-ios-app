/*
 * Copyright ©  2014 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMServerProfile+Helpers.h"
#import "JMConstants.h"
#import <objc/runtime.h>
#import "JMSessionManager.h"
#import "JMSavedResources+Helpers.h"
#import "JMCoreDataManager.h"
#import "NSObject+Additions.h"

@implementation JMServerProfile (Helpers)
+ (JMServerProfile *)demoServerProfile
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"ServerProfile"];
    NSMutableArray *predicates = [NSMutableArray array];
    [predicates addObject:[NSPredicate predicateWithFormat:@"serverUrl == %@", kJMDemoServerUrl]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"alias == %@", kJMDemoServerAlias]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"organization == %@", kJMDemoServerOrganization]];
    fetchRequest.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
    JMServerProfile *demoServerProfile = [[[JMCoreDataManager sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:nil] firstObject];
    if (!demoServerProfile) {
        demoServerProfile = (JMServerProfile *) [NSEntityDescription insertNewObjectForEntityForName:@"ServerProfile"
                                                                              inManagedObjectContext:[JMCoreDataManager sharedInstance].managedObjectContext];
        demoServerProfile.alias = kJMDemoServerAlias;
        demoServerProfile.organization = kJMDemoServerOrganization;
        demoServerProfile.serverUrl = kJMDemoServerUrl;
        [[JMCoreDataManager sharedInstance] save:nil];
    }
    return demoServerProfile;
}

+ (JMServerProfile *)serverProfileForJSProfile:(JSUserProfile *)profile
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"ServerProfile"];
    
    NSMutableArray *serverUrlPredicates = [NSMutableArray array];
    [serverUrlPredicates addObject:[NSPredicate predicateWithFormat:@"serverUrl == %@", profile.serverUrl]];
    [serverUrlPredicates addObject:[NSPredicate predicateWithFormat:@"serverUrl == %@", [profile.serverUrl stringByAppendingString:@"/"]]];

    NSMutableArray *predicates = [NSMutableArray array];
    [predicates addObject:[NSPredicate predicateWithFormat:@"alias == %@", profile.alias]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"organization == %@", profile.organization]];
    [predicates addObject:[NSCompoundPredicate orPredicateWithSubpredicates:serverUrlPredicates]];
    
    fetchRequest.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
    
    return [[[JMCoreDataManager sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:nil] lastObject];
}

+ (JMServerProfile *) cloneServerProfile:(JMServerProfile *)serverProfile
{
    NSString *entityName = [[serverProfile entity] name];
    
    //create new object in data store
    JMServerProfile *newServerProfile = (JMServerProfile *) [NSEntityDescription insertNewObjectForEntityForName:entityName
                                                                                          inManagedObjectContext:[JMCoreDataManager sharedInstance].managedObjectContext];

    NSInteger cloneNumber = 0;
    NSString *serverName = nil;
    do {
        serverName = (cloneNumber++ > 0) ? [serverProfile.alias stringByAppendingFormat:@" %zd", cloneNumber] : serverProfile.alias;
    } while (![newServerProfile isValidNameForServerProfile:serverName]);
    
    newServerProfile.alias          = serverName;
    newServerProfile.askPassword    = serverProfile.askPassword;
    newServerProfile.keepSession    = serverProfile.keepSession;
    newServerProfile.organization   = serverProfile.organization;
    newServerProfile.serverUrl      = serverProfile.serverUrl;
    return newServerProfile;
}

+ (void) deleteServerProfile:(JMServerProfile *)serverProfile
{
    NSArray *savedReports = [serverProfile.savedResources allObjects];
    for (JMSavedResources *savedResource in savedReports) {
        NSString *fullPath = [JMSavedResources absolutePathToSavedResource:savedResource];
        [[NSFileManager defaultManager] removeItemAtPath:fullPath error:nil];
    }
    [serverProfile.managedObjectContext deleteObject:serverProfile];
    [serverProfile.managedObjectContext save:nil];
}

- (BOOL) isValidNameForServerProfile:(NSString *)name
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"ServerProfile"];
    NSMutableArray *predicates = [NSMutableArray array];
    [predicates addObject:[NSPredicate predicateWithFormat:@"self != %@", [JMServerProfile demoServerProfile]]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"self != %@", self]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"alias == %@", name]];
    fetchRequest.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
    JMServerProfile *profile = [[[JMCoreDataManager sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:nil] lastObject];
    return !profile;
}

- (BOOL) isActiveServerProfile
{
    return (self == [JMUtils activeServerProfile]);
}

@end
