/*
 * Copyright ©  2014 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMSavedResourcesListLoader.h"
#import "JMServerProfile+Helpers.h"
#import "JMSavedResources+Helpers.h"
#import "JMFavorites+Helpers.h"
#import "JMExportManager.h"
#import "JMResourceLoaderOption.h"
#import "JMConstants.h"
#import "JMCoreDataManager.h"
#import "JMLocalization.h"
#import "JMUtils.h"
#import "JMSessionManager.h"

@implementation JMSavedResourcesListLoader

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(exportedResourceDidLoad:)
                                                     name:kJMExportedResourceDidLoadNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(exportedResourceDidCancel:)
                                                     name:kJMExportedResourceDidCancelNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(setNeedsUpdate)
                                                     name:kJMSavedResourcesDidChangedNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadNextPage {
    NSError *error;
    NSArray *fetchedObjects = [[JMCoreDataManager sharedInstance].managedObjectContext executeFetchRequest:[self fetchRequest]
                                                                                                     error:&error];
    if (error) {
        [self finishLoadingWithError:error];
    } else {
        NSMutableArray *commonResourcesArray = [NSMutableArray array];
        for(JMSavedResources *savedResource in fetchedObjects) {
            [commonResourcesArray addObject:[savedResource wrapperFromSavedResources]];
        }
        
        NSArray *exportedResources = [[[JMExportManager sharedInstance] exportedResources] filteredArrayUsingPredicate:[self predicate]];
        if (exportedResources.count) {
            [commonResourcesArray addObjectsFromArray:exportedResources];
            NSSortDescriptor *sortDescriptor = [self sortDescriptorForResources];
            if (sortDescriptor) {
                commonResourcesArray = [[commonResourcesArray sortedArrayUsingDescriptors:@[sortDescriptor]] mutableCopy];
            }
        }
        [self addResourcesWithResources:commonResourcesArray];

        _needUpdateData = NO;

        [self finishLoadingWithError:nil];
    }
}

- (NSArray <JMResourceLoaderOption *>*)listItemsWithOption:(JMResourcesListLoaderOptionType)optionType
{
    switch (optionType) {
        case JMResourcesListLoaderOptionType_Sort:
            return [super listItemsWithOption:optionType];
        case JMResourcesListLoaderOptionType_Filter: {
            NSMutableArray *filterOptions = [NSMutableArray array];
            
            NSMutableSet *formatsSet = [NSMutableSet setWithArray:[JMUtils supportedFormatsForReportSaving]];
            [formatsSet addObjectsFromArray:[JMUtils supportedFormatsForDashboardSaving]];
            NSArray *formatsArray = formatsSet.allObjects;
            JMResourceLoaderOption *filterByAllOption = [JMResourceLoaderOption optionWithTitle:JMLocalizedString(@"resources_filterby_type_all")
                                                                                          value:formatsArray];
            [filterOptions addObject:filterByAllOption];
            
            for (NSString *format in formatsArray) {
                JMResourceLoaderOption *filterByOption = [JMResourceLoaderOption optionWithTitle:[format uppercaseString]
                                                                                           value:@[format]];
                [filterOptions addObject:filterByOption];
            }
            return filterOptions;
        }
    }
}

- (BOOL)validateResourceFilteringBeforeAdding:(JMResource *)resource
{
    id value = [self parameterForQueryWithOptionType:JMResourcesListLoaderOptionType_Filter];
    NSSet *availableFormats = [value isKindOfClass:[NSArray class]] ? [NSSet setWithArray:value] : [NSSet setWithObject:value];
    
    NSString *resourceFormat;
    if ([resource isKindOfClass:[JMExportResource class]]) {
        resourceFormat = ((JMExportResource *)resource).format;
    } else {
        JMSavedResources *savedResource = [JMSavedResources savedResourceFromResource:resource];
        resourceFormat = savedResource.format;
    }
    return [availableFormats containsObject:resourceFormat];
}

#pragma mark - Utils
- (NSFetchRequest *)fetchRequest
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kJMSavedResources inManagedObjectContext:[JMCoreDataManager sharedInstance].managedObjectContext];
    
    NSSortDescriptor *sortDescriptor = [self sortDescriptor];
    if (sortDescriptor) {
        [fetchRequest setSortDescriptors:@[sortDescriptor]];
    }

    [fetchRequest setEntity:entity];
    NSMutableArray *predicates = [NSMutableArray arrayWithObject:[[JMSessionManager sharedManager] predicateForCurrentServerProfile]];
    [predicates addObject:[self predicate]];
    fetchRequest.predicate = [[NSCompoundPredicate alloc] initWithType:NSAndPredicateType subpredicates:predicates];
    return fetchRequest;
}

- (NSPredicate *)predicate
{
    NSMutableArray *predicates = [NSMutableArray array];
    [predicates addObject:[NSPredicate predicateWithFormat:@"format IN %@", [self parameterForQueryWithOptionType:JMResourcesListLoaderOptionType_Filter]]];
    if (self.searchQuery && self.searchQuery.length) {
        NSMutableArray *queryPredicates = [NSMutableArray array];
        [queryPredicates addObject:[NSPredicate predicateWithFormat:@"label LIKE[cd] %@", [NSString stringWithFormat:@"*%@*", self.searchQuery]]];
        [queryPredicates addObject:[NSPredicate predicateWithFormat:@"resourceDescription LIKE[cd] %@", [NSString stringWithFormat:@"*%@*", self.searchQuery]]];
        [predicates addObject:[[NSCompoundPredicate alloc] initWithType:NSOrPredicateType subpredicates:queryPredicates]];
    }
    return [[NSCompoundPredicate alloc] initWithType:NSAndPredicateType subpredicates:predicates];
}

- (NSSortDescriptor *)sortDescriptor
{
    if ([self parameterForQueryWithOptionType:JMResourcesListLoaderOptionType_Sort]) {
        BOOL ascending = self.sortBySelectedIndex == 0;
        return [[NSSortDescriptor alloc] initWithKey:[self parameterForQueryWithOptionType:JMResourcesListLoaderOptionType_Sort] ascending:ascending];
    }
    return nil;
}

- (NSSortDescriptor *)sortDescriptorForResources
{
    NSString *sortKey = [self parameterForQueryWithOptionType:JMResourcesListLoaderOptionType_Sort];
    if (sortKey) {
        BOOL ascending = self.sortBySelectedIndex == 0;
        sortKey = [NSString stringWithFormat:@"resourceLookup.%@", sortKey];
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:sortKey
                                                                         ascending:ascending];
        return sortDescriptor;
    }
    return nil;
}

#pragma mark - Exported Resource Notifications
- (void)exportedResourceDidLoad:(NSNotification *)notification
{
    [self setNeedsUpdate];
    [self updateIfNeeded];
}

- (void)exportedResourceDidCancel:(NSNotification *)notification
{
    [self setNeedsUpdate];
    [self updateIfNeeded];
}

@end
