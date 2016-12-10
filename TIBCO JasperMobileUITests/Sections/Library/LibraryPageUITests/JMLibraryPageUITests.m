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
#import "JMBaseUITestCase+Report.h"

@implementation JMLibraryPageUITests

- (void)setUp
{
    [super setUp];

    [self givenThatLibraryPageOnScreen];
    [self verifyThatCollectionViewContainsCells];
}

- (void)tearDown
{

    [super tearDown];
}

#pragma mark - Test 'Main' features

- (void)testThatLibraryPageHasCorrectTitle
{
    // verify that library page has correct title
}

- (void)testThatLibraryContainsListOfCells
{
    [self givenThatCollectionViewContainsListOfCellsInSectionWithName:@"Library"];
    
    XCUIElement *contentView = self.application.otherElements[@"JMBaseCollectionContentViewAccessibilityId"];
    if (contentView.exists) {

        [self verifyThatCollectionViewContainsListOfCells];
        
    } else {
        XCTFail(@"Content View doesn't visible");
    }
}

- (void)testMenuButton
{
    [self showSideMenuInSectionWithName:@"Library"];
    [self hideSideMenuInSectionWithName:@"Library"];
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
    [self switchViewFromGridToListInSectionWithTitle:@"Library"];
    [self givenThatReportCellsOnScreen];

    [self searchResourceWithName:kJMTestLibrarySearchTextExample
               inSectionWithName:@"Library"];
    NSInteger cellsCount = [self countOfListCells];
    XCTAssertTrue(cellsCount > 0, @"Should one or more results");

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
            XCTAssertTrue(filtredResultCount == 0, @"Should not be any results");
            
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
    XCUIElement *contentView = self.application.otherElements[@"JMBaseCollectionContentViewAccessibilityId"];
    if (contentView.exists) {
        
        [self givenThatCollectionViewContainsListOfCellsInSectionWithName:@"Library"];

        [self switchViewFromListToGridInSectionWithTitle:@"Library"];
        [self verifyThatCollectionViewContainsGridOfCells];

        [self switchViewFromGridToListInSectionWithTitle:@"Library"];
        [self verifyThatCollectionViewContainsListOfCells];
        
    } else {
        XCTFail(@"Content View doesn't visible");
    }
}

- (void)testThatViewPresentationNotChangeAfterChangingPages
{
    XCUIElement *contentView = self.application.otherElements[@"JMBaseCollectionContentViewAccessibilityId"];
    if (contentView.exists) {
        
        [self givenThatCollectionViewContainsListOfCellsInSectionWithName:@"Library"];

        [self switchViewFromListToGridInSectionWithTitle:@"Library"];
        [self verifyThatCollectionViewContainsCells];
        [self verifyThatCollectionViewContainsGridOfCells];
        
        // Change Page to Repository
        [self openRepositorySection];
        [self givenThatRepositoryPageOnScreen];
        
        // Change Page to Library
        [self openLibrarySection];
        [self givenThatLibraryPageOnScreen];
        [self verifyThatCollectionViewContainsCells];
        
        [self verifyThatCollectionViewContainsGridOfCells];
        
    } else {
        XCTFail(@"Content View doesn't visible");
    }
}

- (void)testThatViewPresentationNotChangeWhenUserUseSearch
{
    [self givenThatCollectionViewContainsListOfCellsInSectionWithName:@"Library"];

    [self switchViewFromListToGridInSectionWithTitle:@"Library"];
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
    [self verifyThatCollectionViewContainsCells];

    [self verifyThatCellsSortedByName];
}

- (void)testThatUserCanSortListItemsByCreationDate
{
    [self trySortByCreationDate];
    [self verifyThatCollectionViewContainsCells];
    
    [self verifyThatCellsSortedByCreationDate];
}

- (void)testThatUserCanSortListItemsByModifiedDate
{
    [self trySortByModifiedDate];
    [self verifyThatCollectionViewContainsCells];

    [self verifyThatCellsSortedByModifiedDate];
}

#pragma mark - Test 'Filter' feature
- (void)testThatUserCanFilterByAllItems
{
    [self givenThatLibraryPageOnScreen];
    [self verifyThatCollectionViewContainsCells];
    
    [self verifyThatCellsFiltredByAll];
}

- (void)testThatUserCanFilterByReports
{
    [self tryFilterByReports];
    [self verifyThatCollectionViewContainsCells];
    [self verifyThatCellsFiltredByReports];
}

- (void)testThatUserCanFilterByDashboards
{
    [self tryFilterByDashboards];
    [self verifyThatCollectionViewContainsCells];
    [self verifyThatCellsFiltredByDashboards];
}

@end
