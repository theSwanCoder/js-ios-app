/*
 * Copyright ©  2014 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksii Gubariev ogubarie@tibco.com
 @since 1.9
 */

@import UIKit;
#import "JMMenuAction.h"

@class JMMenuActionsView;
@class PopoverView;

@protocol JMMenuActionsViewProtocol <NSObject>
- (JMMenuActionsViewAction)availableActions;
@optional
- (JMMenuActionsViewAction)disabledActions;
@end

@protocol JMMenuActionsViewDelegate <NSObject>
- (void) actionsView:(JMMenuActionsView *)view didSelectAction:(JMMenuActionsViewAction)action;
@end

@interface JMMenuActionsView : UIView
@property (nonatomic, weak) id <JMMenuActionsViewDelegate> delegate;
@property (nonatomic, weak) PopoverView *popoverView;
- (void)setAvailableActions:(JMMenuActionsViewAction)availableActions disabledActions:(JMMenuActionsViewAction)disabledActions;
@end
