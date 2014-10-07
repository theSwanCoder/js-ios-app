//
//  JMSavedResourcesListLoader.m
//  JasperMobile
//
//  Created by Oleksii Gubariev on 9/18/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "JMSavedResourcesListLoader.h"

#import "JMServerProfile+Helpers.h"
#import "JMSavedResources+Helpers.h"

@interface JMSavedResourcesListLoader ()
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, readwrite) BOOL isLoadingNow;
@end

@implementation JMSavedResourcesListLoader
objection_requires(@"managedObjectContext")

@synthesize isLoadingNow;

- (id)init
{
    self = [super init];
    if (self) {
        __weak typeof(self) weakSelf = self;
        [[NSNotificationCenter defaultCenter] addObserverForName:kJMSavedResourcesDidChangedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            typeof(self) strongSelf = weakSelf;
            if (strongSelf) {
                [strongSelf setNeedsUpdate];
            }
        }];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) takeParametersFromNotificationUserInfo:(NSDictionary *)userInfo
{
    [super takeParametersFromNotificationUserInfo:userInfo];
    self.filterByTag = [userInfo objectForKey:kJMFilterByTag];
}

- (void)loadNextPage {
    JMServerProfile *activeServerProfile = [JMServerProfile activeServerProfile];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kJMSavedResources inManagedObjectContext:self.managedObjectContext];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:self.sortBy ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchLimit:kJMResourceLimit];
    [fetchRequest setFetchOffset:self.offset];
    
    NSMutableArray *predicates = [NSMutableArray array];
    [predicates addObject:[NSPredicate predicateWithFormat:@"serverProfile == %@", activeServerProfile]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"username == %@", activeServerProfile.username]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"organization == %@", activeServerProfile.organization]];
    
    [predicates addObject:[NSPredicate predicateWithFormat:@"wsType IN %@", self.resourcesTypes]];
    if (self.searchQuery && self.searchQuery.length) {
        [predicates addObject:[NSPredicate predicateWithFormat:@"label LIKE[cd] %@", [NSString stringWithFormat:@"*%@*", self.searchQuery]]];
    }
    
    fetchRequest.predicate = [[NSCompoundPredicate alloc] initWithType:NSAndPredicateType subpredicates:predicates];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    self.isLoadingNow = NO;
    if (fetchedObjects == nil) {
        [self.delegate resourceListDidLoaded:self withError:error];
    } else {
        for(JMSavedResources *resource in fetchedObjects) {
            [self.resources addObject:[resource wrapperFromSavedReports]];
        }
        [self.delegate resourceListDidLoaded:self withError:nil];
    }
}
@end
