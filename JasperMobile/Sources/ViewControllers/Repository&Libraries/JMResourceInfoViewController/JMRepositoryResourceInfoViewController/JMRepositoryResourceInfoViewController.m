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
//  JMRepositoryResourceInfoViewController.m
//  TIBCO JasperMobile
//


#import "JMRepositoryResourceInfoViewController.h"
#import "JMFavorites+Helpers.h"
#import "JMConstants.h"
#import "JMUtils.h"
#import "JMThemesManager.h"
#import "NSObject+Additions.h"
@interface JMRepositoryResourceInfoViewController ()

@end

@implementation JMRepositoryResourceInfoViewController

#pragma mark - Observers
- (void)addObservers
{
    [super addObservers];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(favoriteMarkDidChanged:) name:kJMFavoritesDidChangedNotification object:nil];
}

- (void)favoriteMarkDidChanged:(id)notification
{
    self.needLayoutUI = YES;
}

#pragma mark - Actions
- (void)favoriteButtonTapped:(id)sender
{
    if ([JMFavorites isResourceInFavorites:self.resource]) {
        [JMFavorites removeFromFavorites:self.resource];
    } else {
        [JMFavorites addToFavorites:self.resource];
    }
}


- (JMMenuActionsViewAction)availableAction
{
    JMMenuActionsViewAction availableAction = [super availableAction];
    if (![self favoriteItemShouldDisplaySeparately]) {
        availableAction |= [self favoriteAction];
    }
    return availableAction;
}

- (JMMenuActionsViewAction)favoriteAction
{
    BOOL isResourceInFavorites = [JMFavorites isResourceInFavorites:self.resource];
    return isResourceInFavorites ? JMMenuActionsViewAction_MakeUnFavorite : JMMenuActionsViewAction_MakeFavorite;
}

- (BOOL) favoriteItemShouldDisplaySeparately
{
    BOOL selfIsModalViewController = [self.navigationController.viewControllers count] == 1;
    return (![JMUtils isCompactWidth] || ([JMUtils isCompactWidth] && [JMUtils isCompactHeight]) || selfIsModalViewController);
}

- (nullable UIBarButtonItem *)additionalBarButtonItem
{
    if ([self favoriteItemShouldDisplaySeparately]) {
        BOOL isResourceInFavorites = [JMFavorites isResourceInFavorites:self.resource];
        NSString *imageName = isResourceInFavorites ? @"favorited_item" : @"make_favorite_item";
        
        UIBarButtonItem *favoriteItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:imageName]
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(favoriteButtonTapped:)];
        if (isResourceInFavorites) {
            [favoriteItem setAccessibility:YES withTextKey:@"action_title_markasunfavorite" identifier:JMMenuActionsViewMarkAsUnFavoriteActionAccessibilityId];
        } else {
            [favoriteItem setAccessibility:YES withTextKey:@"action_title_markasfavorite" identifier:JMMenuActionsViewMarkAsFavoriteActionAccessibilityId];
        }
        
        favoriteItem.tintColor = isResourceInFavorites ? [[JMThemesManager sharedManager] resourceViewResourceFavoriteButtonTintColor] : [[JMThemesManager sharedManager] barItemsColor];
        return favoriteItem;
    }
    return nil;
}

#pragma mark - Accessibility
- (NSString *)accessibilityIdentifier
{
    return JMRepositoryInfoPageAccessibilityID;
}

#pragma mark - JMMenuActionsViewDelegate
- (void)actionsView:(JMMenuActionsView *)view didSelectAction:(JMMenuActionsViewAction)action
{
    switch (action) {
        case JMMenuActionsViewAction_MakeFavorite:
        case JMMenuActionsViewAction_MakeUnFavorite:
            [self favoriteButtonTapped:nil];
            break;
        default:
            break;
    }
    
    [super actionsView:view didSelectAction:action];
}

@end
