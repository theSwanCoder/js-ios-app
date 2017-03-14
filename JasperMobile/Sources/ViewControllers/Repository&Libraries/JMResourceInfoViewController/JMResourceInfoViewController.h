/*
 * Copyright ©  2014 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksii Gubariev ogubarie@tibco.com
 @since 1.9
 */

#import "JMResourceClientHolder.h"
#import "JMMenuActionsView.h"

extern NSString * __nonnull const kJMShowResourceInfoSegue;

@interface JMResourceInfoViewController : JMBaseViewController <JMResourceClientHolder, JMMenuActionsViewDelegate>
@property (nonatomic, strong, nullable) NSArray *resourceProperties;
@property (nonatomic, copy, nullable) void(^exitBlock)(void);

@property (nonatomic, assign) BOOL needLayoutUI;

- (void)resetResourceProperties NS_REQUIRES_SUPER;

- (void)addObservers NS_REQUIRES_SUPER;

- (JMMenuActionsViewAction)availableAction NS_REQUIRES_SUPER;

- (nullable UIBarButtonItem *)additionalBarButtonItem;

@end
