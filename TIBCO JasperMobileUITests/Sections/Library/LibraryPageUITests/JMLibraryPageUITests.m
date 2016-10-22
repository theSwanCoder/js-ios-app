//
//  JMLibraryUITests.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 2/11/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMLibraryPageUITests.h"
#import "JMLibraryPageUITests+Helpers.h"
#import "JMBaseUITestCase+Helpers.h"
#import "JMBaseUITestCase+SideMenu.h"
#import "JMBaseUITestCase+Section.h"

@implementation JMLibraryPageUITests

- (void)setUp
{
    [super setUp];

    [self givenThatLibraryPageOnScreen];
    [self givenThatCellsAreVisible];
}

#pragma mark - Test 'Main' features

- (void)testThatLibraryPageHasCorrectTitle
{
    XCUIElement *libraryController = [self waitElementWithAccessibilityId:JMLibraryPageAccessibilityId timeout:kUITestsBaseTimeout];
    NSString *libraryTitle = libraryController.label;
    if (![libraryTitle isEqualToString:JMLocalizedString(@"menuitem_library_label")]) {
        XCTFail(@"Library title doesn't correct");
    }
}

- (void)testThatLibraryContainsListOfCells
{
    [self givenThatListCellsAreVisible];
    NSInteger allCountOfCells = self.application.cells.count;
    NSInteger countOfListCells = [self countOfListCells];
    
    XCTAssertTrue(allCountOfCells == countOfListCells, @"There are other cells in list");
}

- (void)testMenuButton
{
    [self showSideMenuInSectionWithAccessibilityId:JMLibraryPageAccessibilityId];
    [self hideSideMenuInSectionWithAccessibilityId:JMLibraryPageAccessibilityId];
}

- (void)testThatUserCanPullDownToRefresh
{
    XCUIElement *collectionViewElement = [self.application.collectionViews elementBoundByIndex:0];
    XCUIElement *firstCellElement = [collectionViewElement.cells elementBoundByIndex:0];
    XCUIElement *secondCellElement = [collectionViewElement.cells elementBoundByIndex:4];
    
    [firstCellElement pressForDuration:1 thenDragToElement:secondCellElement];
    
    [self verifyThatCollectionViewNotContainsCells];
    [self verifyThatCollectionViewContainsCells];
}

- (void)testThatUserCanScrollDown
{
    XCUIElement *collectionViewElement = [self.application.collectionViews elementBoundByIndex:0];
    XCUIElement *cellElement = [collectionViewElement.cells elementBoundByIndex:2];
    [cellElement swipeUp];
    
    [self verifyThatCollectionViewContainsCells];
}

#pragma mark - Test 'Search' feature

- (void)testThatSearchWorkWithCorrectWords
{
    // start find some text
    [self trySearchText:kJMTestLibrarySearchTextExample];
    
    // verify result
    NSInteger cellsCount = [self countOfListCells];
    XCTAssertTrue(cellsCount == 1, @"Should be only one result");
    
    // Reset search
    [self tryClearSearchBar];
    // verify result
    [self verifyThatCollectionViewContainsCells];
}

- (void)testThatSearchShowsNoResults
{
    // start find wrong text
    [self trySearchText:@"ababababababababa"];

    // verify result
    NSInteger cellsCount = [self countOfListCells];
    cellsCount += [self countOfGridCells];
    XCTAssertTrue(cellsCount == 0, @"Should be only one result");

    // Reset search
    [self tryClearSearchBar];
    // verify result
    [self verifyThatCollectionViewContainsCells];
}

#pragma mark - Test 'Changing View Presentation' feature

- (void)testThatViewTypeButtonChangeViewPresentation
{
    [self givenThatListCellsAreVisible];
    [self switchViewFromListToGridInSectionWithAccessibilityId:JMLibraryPageAccessibilityId];
    [self verifyThatCollectionViewContainsGridOfCells];
    
    [self switchViewFromGridToListInSectionWithAccessibilityId:JMLibraryPageAccessibilityId];
    [self verifyThatCollectionViewContainsListOfCells];
}

- (void)testThatViewPresentationNotChangeAfterChangingPages
{
    [self givenThatListCellsAreVisible];
    [self switchViewFromListToGridInSectionWithAccessibilityId:JMLibraryPageAccessibilityId];
    [self verifyThatCollectionViewContainsGridOfCells];
        
    // Change Page to Repository
    [self openRepositorySection];
    [self givenThatRepositoryPageOnScreen];
    
    // Change Page to Library
    [self openLibrarySection];
    [self givenThatLibraryPageOnScreen];
    [self givenThatCellsAreVisible];
    [self verifyThatCollectionViewContainsGridOfCells];
}

- (void)testThatViewPresentationNotChangeWhenUserUseSearch
{
    [self givenThatListCellsAreVisible];

    [self switchViewFromListToGridInSectionWithAccessibilityId:JMLibraryPageAccessibilityId];
    [self verifyThatCollectionViewContainsGridOfCells];
    
    // start find some text
    [self trySearchText:kJMTestLibrarySearchTextExample];
    [self verifyThatCollectionViewContainsGridOfCells];
    
    [self tryClearSearchBar];
}

#pragma mark - Test 'Sort' feature
- (void)testThatUserCanSortListItemsByName
{
    [self selectSortBy:JMResourceLoaderSortByNamePageAccessibilityId inSectionWithAccessibilityId:JMLibraryPageAccessibilityId];
    [self givenThatCellsAreVisible];
    [self verifyThatCellsSortedByName];
}

- (void)testThatUserCanSortListItemsByCreationDate
{
    [self selectSortBy:JMResourceLoaderSortByCreationDatePageAccessibilityId inSectionWithAccessibilityId:JMLibraryPageAccessibilityId];
    [self givenThatCellsAreVisible];
    [self verifyThatCellsSortedByCreationDate];
}

- (void)testThatUserCanSortListItemsByModifiedDate
{
    [self selectSortBy:JMResourceLoaderSortByModifiedDatePageAccessibilityId inSectionWithAccessibilityId:JMLibraryPageAccessibilityId];
    [self givenThatCellsAreVisible];
    [self verifyThatCellsSortedByModifiedDate];
}

#pragma mark - Test 'Filter' feature
- (void)testThatUserCanFilterByAllItems
{
    [self selectFilterBy:JMResourceLoaderFilterByAllPageAccessibilityId inSectionWithAccessibilityId:JMLibraryPageAccessibilityId];
    [self givenThatCellsAreVisible];
    [self verifyThatCellsFiltredByAll];
}

- (void)testThatUserCanFilterByReports
{
    [self selectFilterBy:JMResourceLoaderFilterByReportUnitPageAccessibilityId inSectionWithAccessibilityId:JMLibraryPageAccessibilityId];
    [self givenThatCellsAreVisible];
    [self verifyThatCellsFiltredByReports];
}

- (void)testThatUserCanFilterByDashboards
{
    [self selectFilterBy:JMResourceLoaderFilterByDashboardPageAccessibilityId inSectionWithAccessibilityId:JMLibraryPageAccessibilityId];
    [self givenThatCellsAreVisible];
    [self verifyThatCellsFiltredByDashboards];
}

@end
