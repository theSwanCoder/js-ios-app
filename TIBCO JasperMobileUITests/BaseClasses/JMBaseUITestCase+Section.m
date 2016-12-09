//
// Created by Aleksandr Dakhno on 9/20/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMBaseUITestCase+Section.h"
#import "JMBaseUITestCase+Helpers.h"
#import "JMBaseUITestCase+ActionsMenu.h"
#import "JMBaseUITestCase+SideMenu.h"


@implementation JMBaseUITestCase (Section)

#pragma mark - View Types
- (void)switchViewFromListToGridInSectionWithTitle:(NSString *)sectionTitle
{
    XCUIElement *navBar = [self waitNavigationBarWithLabel:sectionTitle
                                                   timeout:kUITestsBaseTimeout];
    XCUIElement *gridButton = [self waitElementMatchingType:XCUIElementTypeButton
                                                 identifier:@"grid button"
                                              parentElement:navBar
                                                    timeout:0];
    if (gridButton) {
        [gridButton tap];
    } else {
        XCTFail(@"Grid button wasn't found");
    }
}

- (void)switchViewFromGridToListInSectionWithTitle:(NSString *)sectionTitle
{
    XCUIElement *navBar = [self waitNavigationBarWithLabel:sectionTitle
                                                   timeout:kUITestsBaseTimeout];
    XCUIElement *listButton = [self waitElementMatchingType:XCUIElementTypeButton
                                                 identifier:@"horizontal list button"
                                              parentElement:navBar
                                                    timeout:0];
    if (listButton) {
        [listButton tap];
    } else {
        XCTFail(@"List button wasn't found");
    }
}

#pragma mark - Search
- (void)searchResourceWithName:(NSString *)resourceName
  inSectionWithAccessibilityId:(NSString *)sectionAccessibilityId
{
    XCUIElement *searchResourcesSearchField = [self searchFieldFromSectionWithAccessibilityId:sectionAccessibilityId];
    [searchResourcesSearchField tap];

    XCUIElement *clearTextButton = [self waitElementMatchingType:XCUIElementTypeButton
                                                            text:@"Clear text"
                                                   parentElement:searchResourcesSearchField
                                                         timeout:0];
    if (clearTextButton) {
        [clearTextButton tap];
    }

    [searchResourcesSearchField typeText:resourceName];

    XCUIElement *searchButton = [self waitElementMatchingType:XCUIElementTypeButton
                                                   identifier:@"Search"
                                                      timeout:kUITestsBaseTimeout];
    if (searchButton.exists) {
        [searchButton tap];
    } else {
        XCTFail(@"Search button wasn't found");
    }
}

- (void)searchResourceWithName:(NSString *)resourceName inSectionWithName:(NSString *)sectionName
{
    if ([sectionName isEqualToString:@"Library"]) {
        [self openLibrarySection];
        // TODO: replace with specific element - JMLibraryPageAccessibilityId
        [self searchResourceWithName:resourceName
        inSectionWithAccessibilityId:@"JMBaseCollectionContentViewAccessibilityId"];
    } else if ([sectionName isEqualToString:@"Repository"]) {
        [self openRepositorySection];
        // TODO: replace with specific element - JMRepositoryPageAccessibilityId
        [self searchResourceWithName:resourceName
        inSectionWithAccessibilityId:@"JMBaseCollectionContentViewAccessibilityId"];
    } else if ([sectionName isEqualToString:@"Favorites"]) {
        [self openFavoritesSection];
        // TODO: replace with specific element - JMRepositoryPageAccessibilityId
        [self searchResourceWithName:resourceName
        inSectionWithAccessibilityId:@"JMBaseCollectionContentViewAccessibilityId"];
    } else {
        XCTFail(@"Wrong section for searching test dashboard: %@", sectionName);
    }
}

- (void)clearSearchResultInSectionWithAccessibilityId:(NSString *)sectionAccessibilityId
{
    XCUIElement *searchResourcesSearchField = [self searchFieldFromSectionWithAccessibilityId:sectionAccessibilityId];
    [searchResourcesSearchField tap];

    XCUIElement *clearTextButton = [self waitElementMatchingType:XCUIElementTypeButton
                                                            text:@"Clear text"
                                                   parentElement:searchResourcesSearchField
                                                         timeout:0];
    if (clearTextButton) {
        [clearTextButton tap];
    }

    XCUIElement *cancelButton = [self waitElementMatchingType:XCUIElementTypeButton
                                                   identifier:@"Cancel"
                                                      timeout:kUITestsBaseTimeout];
    [cancelButton tap];
}

- (XCUIElement *)searchFieldFromSectionWithAccessibilityId:(NSString *)accessibilityId
{
    XCUIElement *section = [self waitElementMatchingType:XCUIElementTypeOther
                                              identifier:accessibilityId
                                                 timeout:kUITestsBaseTimeout];
    XCUIElement *searchField = section.searchFields[@"Search resources"];
    [self waitElementReady:searchField
                   timeout:kUITestsBaseTimeout];
    return searchField;
}

#pragma mark - Cells

- (void)givenThatCollectionViewContainsListOfCells
{
    NSInteger countOfListCells = [self countOfListCells];
    if (countOfListCells > 0) {
        return;
    } else {
        [self switchViewFromListToGridInSectionWithTitle:@"Library"];
    }
}

- (NSInteger)countOfGridCells
{
    return [self countCellsWithAccessibilityId:@"JMCollectionViewGridCellAccessibilityId"];
}

- (NSInteger)countOfListCells
{
    return [self countCellsWithAccessibilityId:@"JMCollectionViewListCellAccessibilityId"];
}

- (void)verifyThatCollectionViewContainsListOfCells
{
    // Shold be 'list' cells
    NSInteger countOfListCells = [self countOfListCells];
    XCTAssertTrue(countOfListCells > 0, @"Should be 'List' presentation");

    // Should not be 'grid' cells
    NSInteger countOfGridCells = [self countOfGridCells];
    XCTAssertTrue(countOfGridCells == 0, @"Should be 'Grid' presentation");
}

- (void)verifyThatCollectionViewContainsGridOfCells
{
    // Should be 'grid' cells
    NSInteger countOfGridCells = [self countOfGridCells];
    XCTAssertTrue(countOfGridCells > 0, @"Should be 'Grid' presentation");

    // Shold not be 'list' cells
    NSInteger countOfListCells = [self countOfListCells];
    XCTAssertTrue(countOfListCells == 0, @"Should be 'List' presentation");
}

- (void)verifyThatCollectionViewContainsCells
{
    NSArray *allCells = [self.application.cells allElementsBoundByAccessibilityElement];
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(XCUIElement  * _Nullable cell, NSDictionary<NSString *,id> * _Nullable bindings) {
        return cell.exists == true && cell.isHittable == true;
    }];
    NSInteger filtredResultCount = [allCells filteredArrayUsingPredicate:predicate].count;
    XCTAssertTrue(filtredResultCount > 0, @"Should be some cells");
}

- (void)verifyThatCollectionViewNotContainsCells
{
    // TODO: implement
}

#pragma mark - Helpers - Menu Sort By

- (void)openSortMenuInSectionWithTitle:(NSString *)sectionTitle
{
    BOOL isShareButtonExists = [self isShareButtonExists];
    if (isShareButtonExists) {
        [self openMenuActions];
        [self tryOpenSortMenuFromMenuActions];
    } else {
        [self tryOpenSortMenuFromNavBarWithTitle:sectionTitle];
    }
}

- (void)tryOpenSortMenuFromMenuActions
{
    XCUIElement *menuActionsElement = [self.application.tables elementBoundByIndex:0];
    XCUIElement *sortActionElement = menuActionsElement.staticTexts[@"Sort by"];
    if (sortActionElement.exists) {
        [sortActionElement tap];

        // Wait until sort view appears
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.tables.count == 1"];
        [self expectationForPredicate:predicate
                  evaluatedWithObject:self.application
                              handler:nil];
        [self waitForExpectationsWithTimeout:5 handler:nil];

    } else {
        XCTFail(@"Sort Action isn't visible");
    }
}

- (void)tryOpenSortMenuFromNavBarWithTitle:(NSString *)navBarTitle
{
    XCUIElement *navBar = self.application.navigationBars[navBarTitle];
    if (navBar.exists) {
        XCUIElement *sortButton = navBar.buttons[@"sort action"];
        if (sortButton.exists) {
            [sortButton tap];
        } else {
            XCTFail(@"Sort Button isn't visible");
        }
    } else {
        XCTFail(@"Navigation bar isn't visible");
    }
}

- (void)selectSortBy:(NSString *)sortTypeString inSectionWithTitle:(NSString *)sectionTitle
{
    [self openSortMenuInSectionWithTitle:sectionTitle];
    XCUIElement *sortOptionsViewElement = [self.application.tables elementBoundByIndex:0];
    if (sortOptionsViewElement.exists) {
        XCUIElement *sortOptionElement = sortOptionsViewElement.staticTexts[sortTypeString];
        if (sortOptionElement.exists) {
            [sortOptionElement tap];
        } else {
            XCTFail(@"'%@' Sort Option isn't visible", sortTypeString);
        }
    } else {
        XCTFail(@"Sort Options View isn't visible");
    }
}

#pragma mark - Menu Filter by

- (void)openFilterMenuInSectionWithTitle:(NSString *)sectionTitle
{
    BOOL isShareButtonExists = [self isShareButtonExists];
    if (isShareButtonExists) {
        [self openMenuActions];
        [self tryOpenFilterMenuFromMenuActions];
    } else {
        [self tryOpenFilterMenuFromNavBarWithTitle:sectionTitle];
    }
}

- (void)tryOpenFilterMenuFromMenuActions
{
    XCUIElement *menuActionsElement = [self.application.tables elementBoundByIndex:0];
    XCUIElement *filterActionElement = menuActionsElement.staticTexts[@"Filter by"];
    if (filterActionElement.exists) {
        [filterActionElement tap];

        // Wait until sort view appears
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.tables.count == 1"];
        [self expectationForPredicate:predicate
                  evaluatedWithObject:self.application
                              handler:nil];
        [self waitForExpectationsWithTimeout:5 handler:nil];

    } else {
        XCTFail(@"Sort Action isn't visible");
    }
}

- (void)tryOpenFilterMenuFromNavBarWithTitle:(NSString *)navBarTitle
{
    XCUIElement *navBar = self.application.navigationBars[navBarTitle];
    if (navBar.exists) {
        XCUIElement *filterButton = navBar.buttons[@"filter action"];
        if (filterButton.exists) {
            [filterButton tap];
        } else {
            XCTFail(@"Filter Button isn't visible");
        }
    } else {
        XCTFail(@"Navigation bar isn't visible");
    }
}

- (void)selectFilterBy:(NSString *)filterTypeString
    inSectionWithTitle:(NSString *)sectionTitle
{
    [self openFilterMenuInSectionWithTitle:sectionTitle];

    XCUIElement *filterOptionsViewElement = [self.application.tables elementBoundByIndex:0];
    if (filterOptionsViewElement.exists) {
        XCUIElement *filterOptionElement = filterOptionsViewElement.staticTexts[filterTypeString];
        if (filterOptionElement.exists) {
            [filterOptionElement tap];
        } else {
            XCTFail(@"'%@' Filter Option isn't visible", filterTypeString);
        }
    } else {
        XCTFail(@"Filter Options View isn't visible");
    }
}

#pragma mark - CollectionView

- (XCUIElement *)collectionViewElementFromSectionWithAccessibilityId:(NSString *)accessibilityId
{
    XCUIElement *section = [self waitElementMatchingType:XCUIElementTypeOther
                                              identifier:accessibilityId
                                                 timeout:kUITestsBaseTimeout];
    return section;
}

#pragma mark - Verifying

- (void)verifyThatSectionOnScreenWithTitle:(NSString *)sectionTitle
{
    [self waitNavigationBarWithLabel:sectionTitle
                             timeout:kUITestsBaseTimeout];
}

@end
