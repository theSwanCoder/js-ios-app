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
//  JMMenuItemControllersFactory.m
//  TIBCO JasperMobile
//

#import "JMMenuItemControllersFactory.h"
#import "JMServerOptionsViewController.h"
#import "JMResourceCollectionViewController.h"
#import "JMMainNavigationController.h"
#import "JMSavedResourcesListLoader.h"
#import "JMFavoritesListLoader.h"
#import "JMLibraryListLoader.h"
#import "JMRepositoryListLoader.h"
#import "JMSchedulesListLoader.h"


typedef NS_ENUM(NSInteger, JMMenuButtonState) {
    JMMenuButtonState_Normal,
    JMMenuButtonState_Notification,
};

@implementation JMMenuItemControllersFactory

+ (UIViewController *)viewControllerWithMenuItem:(JMMenuItem *)menuItem
{
    UIViewController *menuItemViewController;
    switch (menuItem.itemType) {
        case JMMenuItemType_Library:{
            JMResourceCollectionViewController *libraryVC = [[JMUtils mainStoryBoard] instantiateViewControllerWithIdentifier:@"JMResourceCollectionViewController"];
            libraryVC.representationTypeKey = @"LibraryRepresentationTypeKey";
            libraryVC.resourceListLoader = [JMLibraryListLoader new];
            libraryVC.resourceListLoader.delegate = libraryVC;
            menuItemViewController = libraryVC;
            break;
        }
        case JMMenuItemType_Repository:{
            JMResourceCollectionViewController *repositoryVC = [[JMUtils mainStoryBoard] instantiateViewControllerWithIdentifier:@"JMResourceCollectionViewController"];
            repositoryVC.representationTypeKey = @"RepositoryRepresentationTypeKey";
            repositoryVC.resourceListLoader = [JMRepositoryListLoader new];
            repositoryVC.resourceListLoader.delegate = repositoryVC;
            menuItemViewController = repositoryVC;
            break;
        }
        case JMMenuItemType_SavedItems:{
            JMResourceCollectionViewController *savedItemsVC = [[JMUtils mainStoryBoard] instantiateViewControllerWithIdentifier:@"JMResourceCollectionViewController"];
            savedItemsVC.noResultStringKey = @"resources_noresults_saveditems_msg";
            savedItemsVC.representationTypeKey = @"SavedItemsRepresentationTypeKey";
            savedItemsVC.resourceListLoader = [JMSavedResourcesListLoader new];
            savedItemsVC.resourceListLoader.delegate = savedItemsVC;
            menuItemViewController = savedItemsVC;
            break;
        }
        case JMMenuItemType_Favorites:{
            JMResourceCollectionViewController *favoriteItemsVC = [[JMUtils mainStoryBoard] instantiateViewControllerWithIdentifier:@"JMResourceCollectionViewController"];
            favoriteItemsVC.noResultStringKey = @"resources_noresults_favorites_msg";
            favoriteItemsVC.representationTypeKey = @"FavoritesRepresentationTypeKey";
            favoriteItemsVC.resourceListLoader = [JMFavoritesListLoader new];
            favoriteItemsVC.resourceListLoader.delegate = favoriteItemsVC;
            menuItemViewController = favoriteItemsVC;
            break;
        }
        case JMMenuItemType_Scheduling: {
            JMResourceCollectionViewController *scheduleVC = [[JMUtils mainStoryBoard] instantiateViewControllerWithIdentifier:@"JMResourceCollectionViewController"];
            scheduleVC.noResultStringKey = @"resources_noresults_schedules_msg";
            scheduleVC.representationTypeKey = @"SchedulesRepresentationTypeKey";
            scheduleVC.resourceListLoader = [JMSchedulesListLoader new];
            scheduleVC.resourceListLoader.delegate = scheduleVC;
            scheduleVC.availableAction = JMMenuActionsViewAction_Schedule;
            scheduleVC.needShowSearchBar = [JMUtils isSupportSearchInSchedules];
            menuItemViewController = scheduleVC;
            break;
        }
        case JMMenuItemType_Settings: {
            JMServerOptionsViewController *settingsVC = [[JMUtils mainStoryBoard] instantiateViewControllerWithIdentifier:@"JMServerOptionsViewController"];
            UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:JMLocalizedString(@"dialog_button_cancel")
                                                                           style:UIBarButtonItemStyleDone
                                                                          target:settingsVC
                                                                          action:@selector(cancel)];
            [cancelItem setAccessibility:YES withTextKey:@"dialog_button_cancel" identifier:JMButtonCancelAccessibilityId];
            settingsVC.navigationItem.leftBarButtonItem = cancelItem;
            
            settingsVC.serverProfile = [JMUtils activeServerProfile];
            __weak __typeof(settingsVC) weakSettingVC = settingsVC;
            settingsVC.exitBlock = ^{
                __typeof(settingsVC) strongSettingVC = weakSettingVC;
                [strongSettingVC dismissViewControllerAnimated:YES completion:nil];
            };
            menuItemViewController = settingsVC;
            break;
        }
        case JMMenuItemType_About: {
            menuItemViewController = [[JMUtils mainStoryBoard] instantiateViewControllerWithIdentifier:@"JMAboutViewController"];
            break;
        }
        case JMMenuItemType_Feedback:
        case JMMenuItemType_Logout:
            break;
    }
    
    NSAssert(menuItemViewController, @"MenuItemViewController not initialized. Item Title: %@", menuItem.itemTitleKey);
    
    menuItemViewController.title = JMLocalizedString(menuItem.itemTitleKey);
    [menuItemViewController.view setAccessibility:NO withTextKey:menuItem.itemTitleKey identifier:menuItem.itemPageAccessibilityId];
    return [[JMMainNavigationController alloc] initWithRootViewController:menuItemViewController];
}

@end
