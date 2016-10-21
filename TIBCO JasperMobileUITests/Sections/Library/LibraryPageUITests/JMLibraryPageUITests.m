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
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.hittable == true"];
    NSInteger filtredResultCount = [[self.application.cells allElementsBoundByIndex] filteredArrayUsingPredicate:predicate].count;
    XCTAssertTrue(filtredResultCount == 1, @"Should be only one result");
    
    // Reset search
    [self tryClearSearchBar];
    // verify result
    [self verifyThatCollectionViewContainsCells];
}

- (void)testThatSearchShowsNoResults
{
    // start find wrong text
    XCUIElement *searchResourcesSearchField = self.application.searchFields[@"Search resources"];
    if (searchResourcesSearchField.exists) {
        [searchResourcesSearchField tap];
        [searchResourcesSearchField typeText:@"ababababababababa"];
        
        XCUIElement *searchButton = self.application.buttons[@"Search"];
        if (searchButton.exists) {
            [searchButton tap];
            
            // verify result
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.hittable == true"];
            NSInteger filtredResultCount = [[self.application.cells allElementsBoundByIndex] filteredArrayUsingPredicate:predicate].count;
            XCTAssertTrue(filtredResultCount == 0, @"Should be only one result");
            
        } else {
            XCTFail(@"Search button doesn't exist.");
        }
        
    } else {
        XCTFail(@"Search field doesn't exist.");
    }
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
    [self trySortByName];
    [self givenThatCellsAreVisible];

    [self verifyThatCellsSortedByName];
}

- (void)testThatUserCanSortListItemsByCreationDate
{
    [self trySortByCreationDate];
    [self givenThatCellsAreVisible];
    
    [self verifyThatCellsSortedByCreationDate];
}

- (void)testThatUserCanSortListItemsByModifiedDate
{
    [self trySortByModifiedDate];
    [self givenThatCellsAreVisible];

    [self verifyThatCellsSortedByModifiedDate];
}

#pragma mark - Test 'Filter' feature
- (void)testThatUserCanFilterByAllItems
{
    [self givenThatLibraryPageOnScreen];
    [self givenThatCellsAreVisible];
    
    [self verifyThatCellsFiltredByAll];
}

- (void)testThatUserCanFilterByReports
{
//    [self tryFilterByReports];
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
