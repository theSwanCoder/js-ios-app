/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2014 TIBCO Software, Inc. All rights reserved.
 * http://community.jaspersoft.com/project/jaspermobile-ios
 *
 * Unless you have purchased a commercial license agreement from Jaspersoft,
 * the following license terms apply:
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/lgpl>.
 */


//
//  JMMenuActionsView.h
//  TIBCO JasperMobile
//

/**
 @author Alexey Gubarev ogubarie@tibco.com
 @since 1.9
 */

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSInteger, JMMenuActionsViewAction) {
    JMMenuActionsViewAction_None            = 0,
    JMMenuActionsViewAction_MakeFavorite    = 1 << 0,
    JMMenuActionsViewAction_MakeUnFavorite  = 1 << 1,
    JMMenuActionsViewAction_Refresh         = 1 << 2,
    JMMenuActionsViewAction_Filter          = 1 << 3,
    JMMenuActionsViewAction_Edit            = 1 << 4,
    JMMenuActionsViewAction_Sort            = 1 << 5,
    JMMenuActionsViewAction_Save            = 1 << 6,
    JMMenuActionsViewAction_Delete          = 1 << 7,
    JMMenuActionsViewAction_Rename          = 1 << 8,
    JMMenuActionsViewAction_Info            = 1 << 9,
    JMMenuActionsViewAction_SelectAll       = 1 << 10,
    JMMenuActionsViewAction_ClearSelections = 1 << 11
};

static inline JMMenuActionsViewAction JMMenuActionsViewActionFirst() { return JMMenuActionsViewAction_MakeFavorite; }
static inline JMMenuActionsViewAction JMMenuActionsViewActionLast() { return JMMenuActionsViewAction_ClearSelections; }

@class JMMenuActionsView;

@protocol JMMenuActionsViewDelegate <NSObject>
@required
- (void) actionsView:(JMMenuActionsView *)view didSelectAction:(JMMenuActionsViewAction)action;

@end

@interface JMMenuActionsView : UIView
@property (nonatomic, weak) id <JMMenuActionsViewDelegate> delegate;
@property (nonatomic, assign) JMMenuActionsViewAction availableActions;

@end
