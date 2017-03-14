/*
 * Copyright ©  2014 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMSchedulesListLoader.h"
#import "JMResource.h"
#import "JMSchedule.h"
#import "NSObject+Additions.h"
#import "JMUtils.h"
#import "JMConstants.h"

@interface JMSchedulesListLoader()
@property (nonatomic, assign) NSInteger totalCount;
@end

@implementation JMSchedulesListLoader

- (void)loadNextPage
{
    _needUpdateData = NO;

    JSScheduleSearchParameters *parameters = [JSScheduleSearchParameters new];
    parameters.label = self.searchQuery;
    parameters.startIndex = @(self.offset);
    parameters.numberOfRows = @([self limitOfLoadingResources]);
    parameters.sortType = JSScheduleSearchSortTypeJobName;

    __weak typeof(self)weakSelf = self;
    [self.restClient fetchSchedulesWithSearchParameters:parameters
                                             completion:^(JSOperationResult *result) {
                                                 __strong typeof(self)strongSelf = weakSelf;
                                                 if (result.error) {
                                                     if (result.error.code == JSSessionExpiredErrorCode) {
                                                         [JMUtils showLoginViewAnimated:YES completion:nil];
                                                     } else {
                                                         [strongSelf finishLoadingWithError:result.error];
                                                     }
                                                 } else {
                                                     for (id scheduleLookup in result.objects) {
                                                         if ([scheduleLookup isKindOfClass:[JSScheduleLookup class]]) {
                                                             JSResourceLookup *resourceLookup = [strongSelf resourceLookupFromScheduleLookup:scheduleLookup];
                                                             JMSchedule *resource = [JMSchedule scheduleWithResourceLookup:resourceLookup scheduleLookup:scheduleLookup];
                                                             [strongSelf addResourcesWithResource:resource];
                                                         }
                                                     }

                                                     strongSelf.offset += kJMResourceLimit;
                                                     if (!strongSelf.totalCount) {
                                                         strongSelf.totalCount = result.objects.count;
                                                     }
                                                     strongSelf.hasNextPage = strongSelf.offset < strongSelf.totalCount;

                                                     [strongSelf finishLoadingWithError:nil];
                                                 }
                                             }];
}

- (NSArray <JMResourceLoaderOption *>*)listItemsWithOption:(JMResourcesListLoaderOptionType)optionType
{
    switch (optionType) {
        case JMResourcesListLoaderOptionType_Sort: {
            // TODO: Here we can add new sort parameters
            return nil;
        }
        case JMResourcesListLoaderOptionType_Filter: {
            return nil;
        }
    }
}

- (JSResourceLookup *)resourceLookupFromScheduleLookup:(JSScheduleLookup *)scheduleLookup
{
    JSResourceLookup *resourceLookup = [JSResourceLookup new];
    resourceLookup.uri = scheduleLookup.reportUnitURI;
    resourceLookup.label = scheduleLookup.label;
    resourceLookup.resourceType = kJMScheduleUnit;
    NSString *nextFireDateString = [self dateStringFromDate:scheduleLookup.state.nextFireTime];
    NSString *description = [NSString stringWithFormat:@"Status:%@\nNext Fire: %@", scheduleLookup.state.value, nextFireDateString];
    resourceLookup.resourceDescription = description;
    resourceLookup.version = @(scheduleLookup.version);
    return resourceLookup;
}

- (NSString *)dateStringFromDate:(NSDate *)date
{
    NSDateFormatter *formatter = [[JSDateFormatterFactory sharedFactory] formatterWithPattern:@"yyyy-MM-dd HH:mm"];

    NSString *dateString = [formatter stringFromDate:date];
    return dateString;
}

@end
