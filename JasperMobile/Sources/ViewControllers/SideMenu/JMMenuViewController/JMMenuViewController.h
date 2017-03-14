/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @author Oleksii Gubariev ogubarie@tibco.com
 @since 2.0
 */

#import "JMBaseViewController.h"
#import "JMMenuItem.h"

@interface JMMenuViewController : JMBaseViewController

@property (nonatomic, readonly) JMMenuItem *selectedItem;

+ (NSInteger)defaultItemIndex;

- (void)reset;

- (void)setSelectedItemIndex:(NSUInteger)itemIndex;
- (void)openCurrentSection;

@end
