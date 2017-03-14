/*
 * Copyright ©  2014 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksii Gubariev ogubarie@tibco.com
 @since 1.9
 */

#import "JMResourcesListLoader.h"

typedef NS_ENUM(NSInteger, JMLibraryListLoaderFilterIndex) {
    JMLibraryListLoaderFilterIndexByUndefined = -1,
    JMLibraryListLoaderFilterIndexByAll       = 0,
    JMLibraryListLoaderFilterIndexByReport    = 1,
    JMLibraryListLoaderFilterIndexByDashboard = 2,
};

typedef NS_ENUM(NSInteger, JMLibraryListLoaderSortIndex) {
    JMLibraryListLoaderSortIndexByUndefined    = -1,
    JMLibraryListLoaderSortIndexByName         = 0,
    JMLibraryListLoaderSortIndexByCreationDate = 1,
    JMLibraryListLoaderSortIndexByModifiedDate = 2,
};

@interface JMLibraryListLoader : JMResourcesListLoader

@end
