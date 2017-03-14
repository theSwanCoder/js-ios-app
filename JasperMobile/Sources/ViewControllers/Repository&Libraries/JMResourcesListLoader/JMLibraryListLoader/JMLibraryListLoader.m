/*
 * Copyright ©  2014 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMLibraryListLoader.h"
#import "JMResourceLoaderOption.h"
#import "JMLocalization.h"
#import "JMUtils.h"

@implementation JMLibraryListLoader
- (NSArray <JMResourceLoaderOption *>*)listItemsWithOption:(JMResourcesListLoaderOptionType)optionType
{
    switch (optionType) {
        case JMResourcesListLoaderOptionType_Sort: {
            NSMutableArray *allOptions = [[super listItemsWithOption:optionType] mutableCopy];
            if ([JMUtils isServerProEdition]) {
                [allOptions addObject:[JMResourceLoaderOption optionWithTitle:JMLocalizedString(@"resources_sortby_accessTime")
                                                                        value:@"accessTime"]];
            }
            return allOptions;
        }
        case JMResourcesListLoaderOptionType_Filter:{
            return [super listItemsWithOption:optionType];
        }
    }
}
@end
