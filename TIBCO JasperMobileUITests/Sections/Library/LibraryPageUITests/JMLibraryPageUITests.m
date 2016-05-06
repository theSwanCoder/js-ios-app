//
//  JMLibraryUITests.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 2/11/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMLibraryPageUITests.h"
#import "JMLibraryPageUITests+Helpers.h"

@implementation JMLibraryPageUITests

#pragma mark - Test 'Main' features

//- (void)testThatLibraryPageHasTitleLibrary
//{
//    [self givenThatLibraryPageOnScreen];
//
//    [self verifyThatCurrentPageIsLibrary];
//}
//
//- (void)testThatLibraryContainsListOfCells
//{
//    [self givenThatLibraryPageOnScreen];
//    
//    [self givenThatCellsAreVisible];
//    [self givenThatCollectionViewContainsListOfCells];
//    
//    XCUIElement *contentView = self.application.otherElements[@"JMBaseCollectionContentViewAccessibilityId"];
//    if (contentView.exists) {
//
//        [self verifyThatCollectionViewContainsListOfCells];
//        
//    } else {
//        XCTFail(@"Content View doesn't visible");
//    }
//}
//
//- (void)testMenuButton
//{
//    [self givenThatLibraryPageOnScreen];
//    [self givenSideMenuNotVisible];
//    
//    XCUIElement *menuButton = self.application.navigationBars[@"Library"].buttons[@"menu icon"];
//    if (menuButton.exists) {
//        [menuButton tap];
//        
//        [self givenSideMenuVisible];
//    } else {
//        XCTFail(@"'Menu' button doesn't exist.");
//    }
//    
//    if (menuButton.exists) {
//        [menuButton tap];
//        
//        [self givenSideMenuNotVisible];
//    } else {
//        XCTFail(@"'Menu' button doesn't exist.");
//    }
//}
//
//- (void)testThatUserCanPullDownToRefresh
//{
//    [self givenThatLibraryPageOnScreen];
//    [self givenSideMenuNotVisible];
//    
//    [self givenThatCellsAreVisible];
//    
//    XCUIElement *collectionViewElement = [self.application.collectionViews elementBoundByIndex:0];
//    XCUIElement *firstCellElement = [collectionViewElement.cells elementBoundByIndex:0];
//    XCUIElement *secondCellElement = [collectionViewElement.cells elementBoundByIndex:4];
//    
//    [firstCellElement pressForDuration:1 thenDragToElement:secondCellElement];
//    
//    [self verifyThatCollectionViewNotContainsCells];
//    [self verifyThatCollectionViewContainsCells];
//}
//
//- (void)testThatUserCanScrollDown
//{
//    [self givenThatLibraryPageOnScreen];
//    [self givenSideMenuNotVisible];
//    
//    [self givenThatCellsAreVisible];
//    
//    XCUIElement *collectionViewElement = [self.application.collectionViews elementBoundByIndex:0];
//    XCUIElement *cellElement = [collectionViewElement.cells elementBoundByIndex:2];
//    [cellElement swipeUp];
//    
//    [self verifyThatCollectionViewContainsCells];
//}
//
//#pragma mark - Test 'Search' feature
//
//- (void)testThatSearchWorkWithCorrectWords
//{
//    [self givenThatLibraryPageOnScreen];
//    [self givenSideMenuNotVisible];
//    [self givenThatCellsAreVisible];
//    
//    // start find some text
//    [self trySearchText:kJMTestLibrarySearchTextExample];
//    // verify result
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.hittable == true"];
//    NSInteger filtredResultCount = [[self.application.cells allElementsBoundByIndex] filteredArrayUsingPredicate:predicate].count;
//    XCTAssertTrue(filtredResultCount == 1, @"Should be only one result");
//    
//    // Reset search
//    [self tryClearSearchBar];
//    // verify result
//    [self verifyThatCollectionViewContainsCells];
//}
//
//- (void)testThatSearchShowsNoResults
//{
//    [self givenThatLibraryPageOnScreen];
//    [self givenSideMenuNotVisible];
//    [self givenThatCellsAreVisible];
//    
//    // start find wrong text
//    XCUIElement *searchResourcesSearchField = self.application.searchFields[@"Search resources"];
//    if (searchResourcesSearchField.exists) {
//        [searchResourcesSearchField tap];
//        [searchResourcesSearchField typeText:@"ababababababababa"];
//        
//        XCUIElement *searchButton = self.application.buttons[@"Search"];
//        if (searchButton.exists) {
//            [searchButton tap];
//            
//            // verify result
//            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.hittable == true"];
//            NSInteger filtredResultCount = [[self.application.cells allElementsBoundByIndex] filteredArrayUsingPredicate:predicate].count;
//            XCTAssertTrue(filtredResultCount == 0, @"Should be only one result");
//            
//        } else {
//            XCTFail(@"Search button doesn't exist.");
//        }
//        
//    } else {
//        XCTFail(@"Search field doesn't exist.");
//    }
//}
//
//#pragma mark - Test 'Changing View Presentation' feature
//
//- (void)testThatViewTypeButtonChangeViewPresentation
//{
//    [self givenThatLibraryPageOnScreen];
//    [self givenSideMenuNotVisible];
//    [self givenThatCellsAreVisible];
//    
//    XCUIElement *contentView = self.application.otherElements[@"JMBaseCollectionContentViewAccessibilityId"];
//    if (contentView.exists) {
//        
//        [self givenThatCollectionViewContainsListOfCells];
//        
//        [self tryChangeViewPresentationFromListToGrid];
//        [self verifyThatCollectionViewContainsGridOfCells];
//        
//        [self tryChangeViewPresentationFromGridToList];
//        [self verifyThatCollectionViewContainsListOfCells];
//        
//    } else {
//        XCTFail(@"Content View doesn't visible");
//    }
//}
//
//- (void)testThatViewPresentationNotChangeAfterChangingPages
//{
//    [self givenThatLibraryPageOnScreen];
//    [self givenSideMenuNotVisible];
//    [self givenThatCellsAreVisible];
//    
//    XCUIElement *contentView = self.application.otherElements[@"JMBaseCollectionContentViewAccessibilityId"];
//    if (contentView.exists) {
//        
//        [self givenThatCollectionViewContainsListOfCells];
//        
//        [self tryChangeViewPresentationFromListToGrid];
//        [self givenThatCellsAreVisible];
//        [self verifyThatCollectionViewContainsGridOfCells];
//        
//        // Change Page to Repository
//        [self tryOpenRepositoryPage];
//        [self verifyThatCurrentPageIsRepository];
//        
//        // Change Page to Library
//        [self tryOpenLibraryPage];
//        [self verifyThatCurrentPageIsLibrary];
//        [self givenThatCellsAreVisible];
//        
//        [self verifyThatCollectionViewContainsGridOfCells];
//        
//    } else {
//        XCTFail(@"Content View doesn't visible");
//    }
//}
//
//- (void)testThatViewPresentationNotChangeWhenUserUseSearch
//{
//    [self givenThatLibraryPageOnScreen];
//    [self givenSideMenuNotVisible];
//    [self givenThatCellsAreVisible];
//    [self givenThatCollectionViewContainsListOfCells];
//
//    [self tryChangeViewPresentationFromListToGrid];
//    [self verifyThatCollectionViewContainsGridOfCells];
//    
//    // start find some text
//    [self trySearchText:kJMTestLibrarySearchTextExample];
//    [self verifyThatCollectionViewContainsGridOfCells];
//    
//    [self tryClearSearchBar];
//}
//
//#pragma mark - Test 'Sort' feature
//- (void)testThatUserCanSortListItemsByName
//{
//    [self givenThatLibraryPageOnScreen];
//    [self givenSideMenuNotVisible];
//    [self givenThatCellsAreVisible];
//    
//    [self verifyThatCellsSortedByName];
//}
//
//- (void)testThatUserCanSortListItemsByCreationDate
//{
//    [self givenThatLibraryPageOnScreen];
//    [self givenSideMenuNotVisible];
//    [self givenThatCellsAreVisible];
//    
//    [self trySortByCreationDate];
//    [self givenThatCellsAreVisible];
//    
//    [self verifyThatCellsSortedByCreationDate];
//}
//
//- (void)testThatUserCanSortListItemsByModifiedDate
//{
//    [self givenThatLibraryPageOnScreen];
//    [self givenSideMenuNotVisible];
//    [self givenThatCellsAreVisible];
//    
//    [self trySortByModifiedDate];
//    [self verifyThatCellsSortedByModifiedDate];
//}
//
//#pragma mark - Test 'Filter' feature
//- (void)testThatUserCanFilterByAllItems
//{
//    [self givenThatLibraryPageOnScreen];
//    [self givenSideMenuNotVisible];
//    [self givenThatCellsAreVisible];
//    
//    [self verifyThatCellsFiltredByAll];
//}
//
//- (void)testThatUserCanFilterByReports
//{
//    [self givenThatLibraryPageOnScreen];
//    [self givenSideMenuNotVisible];
//    [self givenThatCellsAreVisible];
//    
//    [self tryFilterByReports];
//    [self verifyThatCellsFiltredByReports];
//}
//
//- (void)testThatUserCanFilterByDashboards
//{
//    [self givenThatLibraryPageOnScreen];
//    [self givenSideMenuNotVisible];
//    [self givenThatCellsAreVisible];
//    
//    [self tryFilterByDashboards];
//    [self verifyThatCellsFiltredByDashboards];
//}

@end
