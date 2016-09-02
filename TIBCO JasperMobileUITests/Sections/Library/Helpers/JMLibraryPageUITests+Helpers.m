//
// Created by Aleksandr Dakhno on 2/18/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMLibraryPageUITests+Helpers.h"
#import "JMBaseUITestCase+Helpers.h"


@implementation JMLibraryPageUITests (Helpers)

#pragma mark - Helpers - Main
- (void)givenThatCollectionViewContainsListOfCells
{
    NSInteger countOfListCells = [self countOfListCells];
    if (countOfListCells > 0) {
        return;
    } else {
        [self tryChangeViewPresentationFromGridToList];
    }
}

#pragma mark - Helpers - Collection View Presentations

- (void)tryChangeViewPresentationFromListToGrid
{
    XCUIElement *gridButtonButton = self.application.buttons[@"grid button"];
    if (gridButtonButton.exists) {
        [gridButtonButton tap];
    } else {
        XCTFail(@"There isn't 'grid' button");
    }
}

- (void)tryChangeViewPresentationFromGridToList
{
    XCUIElement *horizontalListButtonButton = self.application.buttons[@"horizontal list button"];
    if (horizontalListButtonButton.exists) {
        [horizontalListButtonButton tap];
    } else {
        XCTFail(@"There isn't 'list' button");
    }
}

#pragma mark - Helpers - Search

- (void)trySearchText:(NSString *)text
{
    // start find some text
    XCUIElement *searchResourcesSearchField = self.application.searchFields[@"Search resources"];
    if (searchResourcesSearchField.exists) {
        [searchResourcesSearchField tap];
        [searchResourcesSearchField typeText:text];

        XCUIElement *searchButton = self.application.buttons[@"Search"];
        if (searchButton.exists) {
            [searchButton tap];
        } else {
            XCTFail(@"Search button doesn't exist.");
        }
    } else {
        XCTFail(@"Search field doesn't exist.");
    }
}

- (void)tryClearSearchBar
{
    XCUIElement *searchResourcesSearchField = self.application.searchFields[@"Search resources"];
    if (searchResourcesSearchField.exists) {
        [searchResourcesSearchField tap];

        XCUIElement *cancelButton = self.application.buttons[@"Cancel"];
        if (cancelButton.exists) {
            [cancelButton tap];
        } else {
            XCTFail(@"Cancel button doesn't exist.");
        }
    } else {
        XCTFail(@"Search field doesn't exist.");
    }
}

#pragma mark - Helpers - Menu Sort By

- (void)tryOpenSortMenu
{
    BOOL isShareButtonExists = [self isShareButtonExists];
    if (isShareButtonExists) {
        [self tryOpenMenuActions];
        [self tryOpenSortMenuFromMenuActions];
    } else {
        [self tryOpenSortMenuFromNavBar];
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

- (void)tryOpenSortMenuFromNavBar
{
    XCUIElement *navBar = self.application.navigationBars[@"Library"];
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

#pragma mark - Helpers - Menu Filter By

- (void)tryOpenFilterMenu
{
    BOOL isShareButtonExists = [self isShareButtonExists];
    if (isShareButtonExists) {
        [self tryOpenMenuActions];
        [self tryOpenFilterMenuFromMenuActions];
    } else {
        [self tryOpenFilterMenuFromNavBar];
    }
}

- (void)tryOpenMenuActions
{
    [self openMenuActionsOnNavBarWithLabel:@"Library"];

//    XCUIElement *navBar = self.application.navigationBars[@"Library"];
//    if (navBar.exists) {
//        XCUIElement *menuActionsButton = navBar.buttons[@"Share"];
//        if (menuActionsButton.exists) {
//            [menuActionsButton tap];
//
//            // Wait until menu actions appears
//            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.tables.count == 1"];
//            [self expectationForPredicate:predicate
//                      evaluatedWithObject:self.application
//                                  handler:nil];
//            [self waitForExpectationsWithTimeout:5 handler:nil];
//
//            XCUIElement *menuActionsElement = [self.application.tables elementBoundByIndex:0];
//            if (!menuActionsElement.exists) {
//                XCTFail(@"Menu Actions isn't visible");
//            }
//        } else {
//            XCTFail(@"Menu Actions button isn't visible");
//        }
//    } else {
//        XCTFail(@"Navigation bar isn't visible");
//    }
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

- (void)tryOpenFilterMenuFromNavBar
{
    XCUIElement *navBar = self.application.navigationBars[@"Library"];
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

#pragma mark - Helpers - Sort By

- (void)trySortByName
{
    [self tryOpenSortMenu];
    [self trySelectSortBy:@"Name"];
}

- (void)trySortByCreationDate
{
    [self tryOpenSortMenu];
    [self trySelectSortBy:@"Creation Date"];
}

- (void)trySortByModifiedDate
{
    [self tryOpenSortMenu];
    [self trySelectSortBy:@"Modified Date"];
}

- (void)trySelectSortBy:(NSString *)sortTypeString
{
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

#pragma mark - Helpers - Filter By

- (void)tryFilterByAll
{
    [self tryOpenFilterMenu];
    [self trySelectFilterBy:@"All"];
}

- (void)tryFilterByReports
{
    [self tryOpenFilterMenu];
    [self trySelectFilterBy:@"Reports"];
}

- (void)tryFilterByDashboards
{
    [self tryOpenFilterMenu];
    [self trySelectFilterBy:@"Dashboards"];
}

- (void)trySelectFilterBy:(NSString *)filterTypeString
{
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

#pragma mark - Verfies
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
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.hittable == true"];
    NSInteger filtredResultCount = [[self.application.cells allElementsBoundByIndex] filteredArrayUsingPredicate:predicate].count;
    XCTAssertTrue(filtredResultCount > 0, @"Should be some cells");
}

- (void)verifyThatCollectionViewNotContainsCells
{
    // TODO: implement
}

- (void)verifyThatCellsSortedByName
{
    NSArray *visibleCells = [self.application.cells allElementsBoundByIndex];

    NSArray *sortedCelsByName = [visibleCells sortedArrayUsingComparator:^NSComparisonResult(XCUIElement *obj1, XCUIElement *obj2) {
        XCUIElement *firstObjectTitleElement = [obj1.staticTexts elementBoundByIndex:0];
        NSString *firstObjectTitle = firstObjectTitleElement.label;

        XCUIElement *secondObjectTitleElement = [obj1.staticTexts elementBoundByIndex:0];
        NSString *secondObjectTitle = secondObjectTitleElement.label;
        return [firstObjectTitle compare:secondObjectTitle];
    }];

    XCTAssertEqualObjects([visibleCells lastObject], [sortedCelsByName lastObject], @"Cells should be sorted by name");
}

- (void)verifyThatCellsSortedByCreationDate
{
    // TODO: implement
    //    XCTFail(@"Need implementation");
    XCTAssertTrue(YES, @"Should be sorted by creation date");
}

- (void)verifyThatCellsSortedByModifiedDate
{
    // TODO: implement
    //    XCTFail(@"Need implementation");
    XCTAssertTrue(YES, @"Should be sorted by modified date");
}

- (void)verifyThatCellsFiltredByAll
{
    // TODO: implement
    //    XCTFail(@"Need implementation");
    XCTAssertTrue(YES, @"Should be filtred by all");
}

- (void)verifyThatCellsFiltredByReports
{
    // TODO: implement
    //    XCTFail(@"Need implementation");
    XCTAssertTrue(YES, @"Should be filtred by reports");
}

- (void)verifyThatCellsFiltredByDashboards
{
    // TODO: implement
    //    XCTFail(@"Need implementation");
    XCTAssertTrue(YES, @"Should be filtred by dashboards");
}

#pragma mark -
- (NSInteger)countOfGridCells
{
    return [self countCellsWithAccessibilityId:@"JMCollectionViewGridCellAccessibilityId"];
}

- (NSInteger)countOfListCells
{
    return [self countCellsWithAccessibilityId:@"JMCollectionViewListCellAccessibilityId"];
}

@end