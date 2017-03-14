/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMMenuItemControllersFactory.h"
#import "JMServerOptionsViewController.h"
#import "JMResourceCollectionViewController.h"
#import "JMMainNavigationController.h"
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
            savedItemsVC.noResultString = JMLocalizedString(@"resources_noresults_saveditems_msg");
            savedItemsVC.representationTypeKey = @"SavedItemsRepresentationTypeKey";
            savedItemsVC.resourceListLoader = [JMSavedResourcesListLoader new];
            savedItemsVC.resourceListLoader.delegate = savedItemsVC;
            menuItemViewController = savedItemsVC;
            break;
        }
        case JMMenuItemType_Favorites:{
            JMResourceCollectionViewController *favoriteItemsVC = [[JMUtils mainStoryBoard] instantiateViewControllerWithIdentifier:@"JMResourceCollectionViewController"];
            favoriteItemsVC.noResultString = JMLocalizedString(@"resources_noresults_favorites_msg");
            favoriteItemsVC.representationTypeKey = @"FavoritesRepresentationTypeKey";
            favoriteItemsVC.resourceListLoader = [JMFavoritesListLoader new];
            favoriteItemsVC.resourceListLoader.delegate = favoriteItemsVC;
            menuItemViewController = favoriteItemsVC;
            break;
        }
        case JMMenuItemType_Scheduling: {
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
        case JMMenuItemType_Settings: {
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
        case JMMenuItemType_About: {
            menuItemViewController = [[JMUtils mainStoryBoard] instantiateViewControllerWithIdentifier:@"JMAboutViewController"];
            break;
        }
        case JMMenuItemType_Feedback:
        case JMMenuItemType_Logout:
            break;
    }
    
    NSAssert(menuItemViewController, @"MenuItemViewController not initialized. Item Title: %@", menuItem.itemTitle);
    
    menuItemViewController.title = menuItem.itemTitle;
    return [[JMMainNavigationController alloc] initWithRootViewController:menuItemViewController];
}

@end
