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
#import "JMRecentViewsListLoader.h"
#import "JMSavedResourcesListLoader.h"
#import "JMFavoritesListLoader.h"
#import "JMLibraryListLoader.h"
#import "JMRepositoryListLoader.h"
#import "JMSchedulesListLoader.h"

#import "JMLocalization.h"
#import "JMConstants.h"
#import "JMUtils.h"


typedef NS_ENUM(NSInteger, JMMenuButtonState) {
    JMMenuButtonState_Normal,
    JMMenuButtonState_Notification,
};

@implementation JMMenuItemControllersFactory

+ (UIViewController *)viewControllerWithMenuItem:(JMMenuItem *)menuItem
{
    UIViewController *menuItemViewController;
    switch (menuItem.sectionType) {
        case JMSectionTypeLibrary:{
            JMResourceCollectionViewController *libraryVC = [[JMUtils mainStoryBoard] instantiateViewControllerWithIdentifier:@"JMResourceCollectionViewController"];
            libraryVC.representationTypeKey = @"LibraryRepresentationTypeKey";
            libraryVC.resourceListLoader = [JMLibraryListLoader new];
            libraryVC.resourceListLoader.delegate = libraryVC;
            menuItemViewController = libraryVC;
            break;
        }
        case JMSectionTypeRepository:{
            JMResourceCollectionViewController *repositoryVC = [[JMUtils mainStoryBoard] instantiateViewControllerWithIdentifier:@"JMResourceCollectionViewController"];
            repositoryVC.representationTypeKey = @"RepositoryRepresentationTypeKey";
            repositoryVC.resourceListLoader = [JMRepositoryListLoader new];
            repositoryVC.resourceListLoader.delegate = repositoryVC;
            menuItemViewController = repositoryVC;
            break;
        }
        case JMSectionTypeRecentViews:{
            JMResourceCollectionViewController *recentViewsVC = [[JMUtils mainStoryBoard] instantiateViewControllerWithIdentifier:@"JMResourceCollectionViewController"];
            recentViewsVC.representationTypeKey = @"RecentViewsRepresentationTypeKey";
            recentViewsVC.resourceListLoader = [JMRecentViewsListLoader new];
            recentViewsVC.resourceListLoader.delegate = recentViewsVC;
            menuItemViewController = recentViewsVC;
            break;
        }
        case JMSectionTypeSavedItems:{
            JMResourceCollectionViewController *savedItemsVC = [[JMUtils mainStoryBoard] instantiateViewControllerWithIdentifier:@"JMResourceCollectionViewController"];
            savedItemsVC.noResultString = JMLocalizedString(@"resources_noresults_saveditems_msg");
            savedItemsVC.representationTypeKey = @"SavedItemsRepresentationTypeKey";
            savedItemsVC.resourceListLoader = [JMSavedResourcesListLoader new];
            savedItemsVC.resourceListLoader.delegate = savedItemsVC;
            menuItemViewController = savedItemsVC;
            break;
        }
        case JMSectionTypeFavorites:{
            JMResourceCollectionViewController *favoriteItemsVC = [[JMUtils mainStoryBoard] instantiateViewControllerWithIdentifier:@"JMResourceCollectionViewController"];
            favoriteItemsVC.noResultString = JMLocalizedString(@"resources_noresults_favorites_msg");
            favoriteItemsVC.representationTypeKey = @"FavoritesRepresentationTypeKey";
            favoriteItemsVC.resourceListLoader = [JMFavoritesListLoader new];
            favoriteItemsVC.resourceListLoader.delegate = favoriteItemsVC;
            menuItemViewController = favoriteItemsVC;
            break;
        }
        case JMSectionTypeScheduling: {
            JMResourceCollectionViewController *scheduleVC = [[JMUtils mainStoryBoard] instantiateViewControllerWithIdentifier:@"JMResourceCollectionViewController"];
            scheduleVC.noResultString = JMLocalizedString(@"resources_noresults_schedules_msg");
            scheduleVC.representationTypeKey = @"SchedulesRepresentationTypeKey";
            scheduleVC.resourceListLoader = [JMSchedulesListLoader new];
            scheduleVC.resourceListLoader.delegate = scheduleVC;
            scheduleVC.availableAction = JMMenuActionsViewAction_Schedule;
            scheduleVC.shouldShowButtonForChangingViewPresentation = NO;
            scheduleVC.needShowSearchBar = [JMUtils isSupportSearchInSchedules];
            menuItemViewController = scheduleVC;
            break;
        }
        case JMSectionTypeSettings: {
            JMServerOptionsViewController *settingsVC = [[JMUtils mainStoryBoard] instantiateViewControllerWithIdentifier:@"JMServerOptionsViewController"];
            settingsVC.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:JMLocalizedString(@"dialog_button_cancel")
                                                                                            style:UIBarButtonItemStyleDone
                                                                                           target:settingsVC
                                                                                           action:@selector(cancel)];
            settingsVC.serverProfile = [JMUtils activeServerProfile];
            __weak __typeof(settingsVC) weakSettingVC = settingsVC;
            settingsVC.exitBlock = ^{
                __typeof(settingsVC) strongSettingVC = weakSettingVC;
                [strongSettingVC dismissViewControllerAnimated:YES completion:nil];
            };
            menuItemViewController = settingsVC;
            break;
        }
        case JMSectionTypeAbout: {
            menuItemViewController = [[JMUtils mainStoryBoard] instantiateViewControllerWithIdentifier:@"JMAboutViewController"];
            break;
        }
        default:
            break;
    }
    
    if (menuItemViewController) {
        menuItemViewController.title = menuItem.itemTitle;
        return [[JMMainNavigationController alloc] initWithRootViewController:menuItemViewController];
    }
    return [JMUtils launchScreenViewController];
}

@end
