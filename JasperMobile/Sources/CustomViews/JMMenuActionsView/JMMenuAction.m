/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2015 TIBCO Software, Inc. All rights reserved.
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
            return @"action_title_filter";
        case JMMenuActionsViewAction_Edit:
            return @"action_title_edit";
        case JMMenuActionsViewAction_EditFilters:
            return @"action_title_edit_filters";
        case JMMenuActionsViewAction_Refresh:
            return @"action_title_refresh";
        case JMMenuActionsViewAction_Save:
            return @"action_title_save";
        case JMMenuActionsViewAction_Delete:
            return @"action_title_delete";
        case JMMenuActionsViewAction_Rename:
            return @"action_title_rename";
        case JMMenuActionsViewAction_MakeFavorite:
            return @"action_title_markasfavorite";
        case JMMenuActionsViewAction_MakeUnFavorite:
            return @"action_title_markasunfavorite";
        case JMMenuActionsViewAction_Info:
            return @"action_title_info";
        case JMMenuActionsViewAction_Sort:
            return @"action_title_sort";
        case JMMenuActionsViewAction_SelectAll:
            return @"action_title_selectall";
        case JMMenuActionsViewAction_ClearSelections:
            return @"action_title_clearselections";
        case JMMenuActionsViewAction_Run:
            return @"action_title_run";
        case JMMenuActionsViewAction_Print:
            return @"action_title_print";
        case JMMenuActionsViewAction_OpenIn:
            return @"action_title_openIn";
        case JMMenuActionsViewAction_Schedule:
            return @"action_title_schedule";
        case JMMenuActionsViewAction_Share:
            return @"action_title_share";
        case JMMenuActionsViewAction_Bookmarks:
            return @"action_title_bookmarks";
        case JMMenuActionsViewAction_ShowExternalDisplay:
            return @"action_title_showExternalDisplay";
        case JMMenuActionsViewAction_HideExternalDisplay:
            return @"action_title_hideExternalDisplay";
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
        case JMMenuActionsViewAction_EditFilters:
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
        case JMMenuActionsViewAction_OpenIn:
            return @"open_in_new";
        case JMMenuActionsViewAction_Schedule:
            return @"schedule_action";
        case JMMenuActionsViewAction_Share:
            return @"share_action";
        case JMMenuActionsViewAction_Bookmarks:
            return @"bookmarks_action";
        case JMMenuActionsViewAction_ShowExternalDisplay:
            return @"tv_action";
        case JMMenuActionsViewAction_HideExternalDisplay:
            return @"tv_action";
    }
}


@end