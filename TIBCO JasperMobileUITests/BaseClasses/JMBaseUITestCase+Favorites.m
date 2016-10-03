//
// Created by Aleksandr Dakhno on 10/3/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMBaseUITestCase+Favorites.h"
#import "JMBaseUITestCase+SideMenu.h"
#import "JMBaseUITestCase+Section.h"
#import "JMBaseUITestCase+Helpers.h"
#import "JMBaseUITestCase+Resource.h"
#import "JMBaseUITestCase+ActionsMenu.h"


@implementation JMBaseUITestCase (Favorites)

- (void)givenThatFavoritesSectionIsEmpty
{
    [self openFavoritesSection];
    [self switchViewFromGridToListInSectionWithTitle:@"Favorites"];
    [self unmarkAllFavoritesResourcesIfNeed];
    [self openLibrarySection];
}

- (void)unmarkAllFavoritesResourcesIfNeed
{
    NSInteger countOfSavedItems = [self countCellsWithAccessibilityId:@"JMCollectionViewListCellAccessibilityId"];
    if (countOfSavedItems > 0) {
        [self unmarkFirstResource];
    }
}

#pragma mark - Helpers

- (void)unmarkFirstResource
{
    XCUIElement *firstItem = [self cellWithAccessibilityId:@"JMCollectionViewListCellAccessibilityId"
                                                  forIndex:0];
    [self unmarkItem:firstItem];

    [self unmarkAllFavoritesResourcesIfNeed];
}

- (void)unmarkItem:(XCUIElement *)favoriteItem
{
    [self openInfoPageForResource:favoriteItem];
    [self verifyInfoPageOnScreenForPageWithAccessibilityId:@"JMReportInfoViewControllerAccessibilityId"];

    [self openMenuActions];
    [self selectActionWithName:@"Remove From Favorites"];
    [self closeInfoPageWithBackButton];
}

@end
