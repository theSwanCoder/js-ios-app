/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
@author Oleksandr Dahno odahno@tibco.com
@since 2.6
*/

@import UIKit;

#import "JMMenuAction.h"

@protocol JMMenuActionsViewDelegate;

@interface JMResourceViewerMenuHelper : NSObject
@property (nonatomic, weak) UIViewController <JMMenuActionsViewDelegate>*controller;
@property (nonatomic, assign, readonly) BOOL isMenuVisible;
- (void)showMenuWithAvailableActions:(JMMenuActionsViewAction)availableActions disabledActions:(JMMenuActionsViewAction)disabledActions;
- (void)hideMenu;
@end
