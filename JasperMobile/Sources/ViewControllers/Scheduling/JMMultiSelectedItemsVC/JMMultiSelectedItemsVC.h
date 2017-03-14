/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.5
 */

#import "JMBaseViewController.h"
@class JMSelectedItem;

@interface JMMultiSelectedItemsVC : JMBaseViewController
@property (nonatomic, copy) NSArray <JMSelectedItem *>*availableItems;
@property (nonatomic, copy) void(^exitBlock)(NSArray <JMSelectedItem *>*selectedItems);
@end
