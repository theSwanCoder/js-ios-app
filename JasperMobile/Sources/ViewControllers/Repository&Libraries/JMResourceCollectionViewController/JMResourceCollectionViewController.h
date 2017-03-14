/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksii Gubariev ogubarie@tibco.com
 @since 2.6
 */

#import "JMMenuActionsView.h"
#import "JMSavedResources+Helpers.h"
#import "JMResourcesListLoader.h"
#import "JMBaseViewController.h"

typedef NS_ENUM(NSInteger, JMResourcesRepresentationType) {
    JMResourcesRepresentationType_HorizontalList = 0,
    JMResourcesRepresentationType_Grid = 1
};

static inline JMResourcesRepresentationType JMResourcesRepresentationTypeFirst() { return JMResourcesRepresentationType_HorizontalList; }
static inline JMResourcesRepresentationType JMResourcesRepresentationTypeLast() { return JMResourcesRepresentationType_Grid; }

@interface JMResourceCollectionViewController : JMBaseViewController <JMResourcesListLoaderDelegate>

@property (nonatomic, strong) NSString *noResultString;
@property (nonatomic, strong) NSString *representationTypeKey;
@property (nonatomic, strong) JMResourcesListLoader *resourceListLoader;

@property (nonatomic, assign) BOOL shouldShowButtonForChangingViewPresentation;     // YES by default
@property (nonatomic, assign) BOOL needShowSearchBar;                               // YES by default

@property (nonatomic, assign) JMMenuActionsViewAction availableAction;

@property (nonatomic, copy) void(^actionBlock)(JMResource *);

@end
