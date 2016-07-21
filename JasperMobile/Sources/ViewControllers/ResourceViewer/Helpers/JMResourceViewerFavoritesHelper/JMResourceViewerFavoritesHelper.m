/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2016 TIBCO Software, Inc. All rights reserved.
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
//  JMResourceViewerFavoritesHelper.h
//  TIBCO JasperMobile
//

#import "JMResourceViewerFavoritesHelper.h"
#import "JMResourceClientHolder.h"
#import "JMFavorites+Helpers.h"

@implementation JMResourceViewerFavoritesHelper

#pragma mark - Life Cycle
- (void)dealloc
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    [self removeObservers];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addObservers];
    }
    return self;
}

#pragma mark - Notifications

- (void)addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeFavoriteStatus)
                                                 name:kJMFavoritesDidChangedNotification
                                               object:nil];
}

- (void)removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notifications Helpers

- (void)changeFavoriteStatus
{
    UIBarButtonItem *barButtonItem = [self findFavoriteBarButton];
    [self decorateFavoriteBarButton:barButtonItem];
}

#pragma mark - Public API

- (void)updateAppearence
{
    UIBarButtonItem *favoriteButton = [self findFavoriteBarButton];
    if ([self shouldShowFavoriteBarButton]) {
        if (!favoriteButton) {
            [self addFavoriteBarButton];
        }
    } else {
        if (favoriteButton) {
            [self removeFavoriteBarButton:favoriteButton];
        }
    }
}

- (void)updateFavoriteState
{
    [self favoriteAction];
}

- (void)removeFavoriteBarButton
{
    UIBarButtonItem *barButtonItem = [self findFavoriteBarButton];
    [self removeFavoriteBarButton:barButtonItem];
}

#pragma mark - Actions

- (void)favoriteAction
{
    if ([JMFavorites isResourceInFavorites:self.controller.resource]) {
        [JMFavorites removeFromFavorites:self.controller.resource];
    } else {
        [JMFavorites addToFavorites:self.controller.resource];
    }
}

#pragma mark - Helpers

- (void)addFavoriteBarButton
{
    UIBarButtonItem *favoriteBarButton = [self favoriteBarButton];
    NSMutableArray *rightBarButtonItems = [self.controller.navigationItem.rightBarButtonItems mutableCopy];
    [rightBarButtonItems addObject:favoriteBarButton];
    self.controller.navigationItem.rightBarButtonItems = rightBarButtonItems;
}

- (void)removeFavoriteBarButton:(UIBarButtonItem *)favoriteButton
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
    if (!favoriteButton) {
        return;
    }
    NSMutableArray *rightBarButtonItems = [self.controller.navigationItem.rightBarButtonItems mutableCopy];
    [rightBarButtonItems removeObject:favoriteButton];
    self.controller.navigationItem.rightBarButtonItems = rightBarButtonItems;
}

- (UIBarButtonItem *)favoriteBarButton
{
    UIBarButtonItem *item;
    item = [[UIBarButtonItem alloc] initWithImage:nil
                                            style:UIBarButtonItemStylePlain
                                           target:self
                                           action:@selector(favoriteAction)];
    [self decorateFavoriteBarButton:item];
    return item;
}

- (void)decorateFavoriteBarButton:(UIBarButtonItem *)favoriteButton
{
    BOOL isResourceInFavorites = [JMFavorites isResourceInFavorites:self.controller.resource];
    NSString *imageName = isResourceInFavorites ? @"favorited_item" : @"make_favorite_item";
    favoriteButton.image = [UIImage imageNamed:imageName];
    favoriteButton.tintColor = isResourceInFavorites ? [[JMThemesManager sharedManager] resourceViewResourceFavoriteButtonTintColor] : [[JMThemesManager sharedManager] barItemsColor];
}

- (UIBarButtonItem *)findFavoriteBarButton
{
    UIBarButtonItem *favoriteItem;
    for (UIBarButtonItem *item in self.controller.navigationItem.rightBarButtonItems) {
        if (item.action == @selector(favoriteAction)) {
            favoriteItem = item;
            break;
        }
    }
    return favoriteItem;
}

- (BOOL)shouldShowFavoriteBarButton
{
    BOOL shouldShowFavoriteButton = NO;
    BOOL isCompactWidth = [JMUtils isCompactWidth];
    BOOL isRegularWidth = !isCompactWidth;
    BOOL isCompactHeight = [JMUtils isCompactHeight];
    BOOL isRegularHeight = !isCompactHeight;
    if ( (isCompactWidth && isCompactHeight) || (isRegularWidth && isRegularHeight) ) {
        shouldShowFavoriteButton = YES;
    }
    return shouldShowFavoriteButton;
}

@end