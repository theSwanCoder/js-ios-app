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
//  JMMenuAction.m
//  TIBCO JasperMobile
//

#import "JMMenuAction.h"


@implementation JMMenuAction
- (instancetype)initWithAction:(JMMenuActionsViewAction)action available:(BOOL)available enabled:(BOOL)enabled
{
    self = [super init];
    if (self) {
        _menuAction = action;
        _actionAvailable = available;
        _actionEnabled = enabled;
    }
    return self;
}

+ (instancetype)menuActionWithAction:(JMMenuActionsViewAction)action available:(BOOL)available enabled:(BOOL)enabled
{
    return [[self alloc] initWithAction:action available:available enabled:enabled];
}

- (NSString *)actionTitle
{
    switch (self.menuAction) {
        case JMMenuActionsViewAction_None:
            return nil;
        case JMMenuActionsViewAction_Filter:
            return @"action.title.filter";
        case JMMenuActionsViewAction_Edit:
            return @"action.title.edit";
        case JMMenuActionsViewAction_Refresh:
            return @"action.title.refresh";
        case JMMenuActionsViewAction_Save:
            return @"action.title.save";
        case JMMenuActionsViewAction_Delete:
            return @"action.title.delete";
        case JMMenuActionsViewAction_Rename:
            return @"action.title.rename";
        case JMMenuActionsViewAction_MakeFavorite:
            return @"action.title.markasfavorite";
        case JMMenuActionsViewAction_MakeUnFavorite:
            return @"action.title.markasunfavorite";
        case JMMenuActionsViewAction_Info:
            return @"action.title.info";
        case JMMenuActionsViewAction_Sort:
            return @"action.title.sort";
        case JMMenuActionsViewAction_SelectAll:
            return @"action.title.selectall";
        case JMMenuActionsViewAction_ClearSelections:
            return @"action.title.clearselections";
        case JMMenuActionsViewAction_Run:
            return @"action.title.run";
        case JMMenuActionsViewAction_Print:
            return @"action.title.print";
    }
}

- (NSString *)actionImageName
{
    switch (self.menuAction) {
        case JMMenuActionsViewAction_None:
            return nil;
        case JMMenuActionsViewAction_Filter:
            return @"filter_action";
        case JMMenuActionsViewAction_Edit:
            return @"filter_action";
        case JMMenuActionsViewAction_Refresh:
            return @"refresh_action";
        case JMMenuActionsViewAction_Save:
            return @"save_action";
        case JMMenuActionsViewAction_Delete:
            return @"delete_action";
        case JMMenuActionsViewAction_Rename:
            return @"edit_action";
        case JMMenuActionsViewAction_MakeFavorite:
            return @"make_favorite_item";
        case JMMenuActionsViewAction_MakeUnFavorite:
            return @"favorited_item";
        case JMMenuActionsViewAction_Info:
            return @"info_item";
        case JMMenuActionsViewAction_Sort:
            return @"sort_action";
        case JMMenuActionsViewAction_SelectAll:
            return @"select_all_action";
        case JMMenuActionsViewAction_ClearSelections:
            return @"clear_selection_action";
        case JMMenuActionsViewAction_Run:
            return @"run_action";
        case JMMenuActionsViewAction_Print:
            return @"print_action";
    }
}


@end