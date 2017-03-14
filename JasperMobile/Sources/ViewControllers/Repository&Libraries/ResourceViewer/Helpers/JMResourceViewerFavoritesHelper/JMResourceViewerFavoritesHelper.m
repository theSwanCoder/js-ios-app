/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMResourceViewerFavoritesHelper.h"
#import "JMResourceClientHolder.h"
#import "JMFavorites+Helpers.h"
#import "JMUtils.h"
#import "JMConstants.h"
#import "JMThemesManager.h"

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
    if ([self isResourceInFavorites]) {
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
    BOOL isResourceInFavorites = [self isResourceInFavorites];
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
    BOOL isCompactHeight = [JMUtils isCompactHeight];
    if ( !isCompactWidth || (isCompactWidth && isCompactHeight) ) {
        shouldShowFavoriteButton = YES;
    }
    return shouldShowFavoriteButton;
}

- (BOOL)isResourceInFavorites
{
    return [JMFavorites isResourceInFavorites:self.controller.resource];
}

@end
