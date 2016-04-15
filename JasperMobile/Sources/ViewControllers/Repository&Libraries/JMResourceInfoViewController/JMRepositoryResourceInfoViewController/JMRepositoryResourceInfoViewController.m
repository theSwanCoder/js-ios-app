//
//  JMRepositoryResourceInfoViewController.m
//  TIBCO JasperMobile
//
//  Created by Oleksii Gubariev on 4/15/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMRepositoryResourceInfoViewController.h"
#import "JMFavorites+Helpers.h"

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
        favoriteItem.tintColor = isResourceInFavorites ? [[JMThemesManager sharedManager] resourceViewResourceFavoriteButtonTintColor] : [[JMThemesManager sharedManager] barItemsColor];
        return favoriteItem;
    }
    return nil;
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
