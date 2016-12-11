//
//  JMRepositoryPageUITests.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 2/19/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMRepositoryPageUITests.h"
#import "JMBaseUITestCase+SideMenu.h"
#import "JMBaseUITestCase+Helpers.h"
#import "JMBaseUITestCase+Folders.h"
#import "JMBaseUITestCase+Section.h"
#import "JMBaseUITestCase+Buttons.h"

@implementation JMRepositoryPageUITests

- (void)setUp
{
    [super setUp];

    [self openRepositorySection];
}

#pragma mark - Tests

//  User should see Repository screen
//    - Preconditions:
//    - Steps:
//      - Open the Left Panel
//      - Tap on the Repository button
//    - Results:
//      - User should see Repository screen
//    - After:
- (void)testThatUserCanOpenRepositoryPage
{
    [self verifyThatSectionOnScreenWithTitle:@"Repository"];
}

//  Left Panel button
//    - Preconditions:
//    - Steps:
//      - Open the Left Panel
//      - Tap on the Repository button
//    - Results:
//      - User should see Left Panel button on the Repository screen
//    - After:
- (void)testThatRepositoryPageHasSideMenuButton
{
    XCUIElement *menuButton = [self findMenuButtonOnNavBarWithTitle:@"Repository"];
    if (!menuButton) {
        XCTFail(@"Menu button isn't found in Repository section");
    }
}
    
//  Repository Title
//    - Preconditions:
//    - Steps:
//      - Open the Left Panel
//      - Tap on the Repository button
//    - Results:
//      - User should see title like “Repository”
//    - After:
- (void)testThatRepositoryPageHasCorrectTitle
{
    [self waitNavigationBarWithLabel:@"Repository"
                             timeout:kUITestsBaseTimeout];
}
    
//  Folder title
//    - Preconditions:
//      - Open the Left Panel
//      - Tap on the Repository button
//    - Steps:
//      - Open any folder
//    - Results:
//      - User should see title like name of current folder
//    - After:
- (void)testThatOpendFolderHasCorrectTitle
{
    [self givenThatCollectionViewContainsListOfCellsInSectionWithName:@"Repository"];
    
    [self openFolderWithName:kTestFolderName];
    [self verifyCorrectTitleForFolderWithName:kTestFolderName];
    [self backToFolderWithName:@"Repository"];
}
    
//  Back button on the folder screen like name of the parent folder
//    - Preconditions:
//      - Open the Left Panel
//      - Tap on the Repository button
//    - Steps:
//      - Open any folder
//      - Tap back button
//    - Results:
//      - Previous screen should appear
//    - After:
- (void)testThatOpenedFolderHasBackButtonWithCorrectTitle
{
    [self givenThatCollectionViewContainsListOfCellsInSectionWithName:@"Repository"];
    
    [self openFolderWithName:kTestFolderName];
    XCUIElement *navBar = [self waitNavigationBarWithLabel:kTestFolderName
                                                   timeout:kUITestsBaseTimeout];
    [self verifyButtonExistWithText:@"Repository"
                      parentElement:navBar];

    [self backToFolderWithName:@"Repository"];
}

//  Search result
//    - Preconditions:
//      - Open the Left Panel
//      - Tap on the Repository button
//    - Steps:
//      - Verify searching operation
//    - Results:
//      - User can:
//          - enter search text
//          - edit search text
//          - delete search text
//          - cancel search
//          - see result after searching
//          - Verify that search is recursive
//    - After:
- (void)testThatSearchOnRepositoryPageWorkCorrectly
{
    [self searchResourceWithName:@"Samples"
               inSectionWithName:@"Repository"];
    [self verifyThatCollectionViewContainsCells];
    
    [self searchResourceWithName:@"Templates"
               inSectionWithName:@"Repository"];
    [self verifyThatCollectionViewContainsCells];
}

//  Error message when no search result
//    - Preconditions:
//      - Open the Left Panel
//      - Tap on the Repository button
//    - Steps:
//      - Enter incorrect search text
//    - Results:
//      - User can see error message when no search result
//    - After:
- (void)testThatSearchWithEmptyResultOnRepositoryPageHasCorrectMessage
{
    [self searchResourceWithName:@"NoSearchResults"
               inSectionWithName:@"Repository"];

    XCUIElement *noResultLabel = [self waitElementMatchingType:XCUIElementTypeStaticText
                                                          text:@"No Results."
                                                       timeout:kUITestsBaseTimeout];
    if (!noResultLabel.exists) {
        XCTFail(@"There isn't 'No Results.' label");
    }
}
    
//  View type button
//    - Preconditions:
//      - Open the Left Panel
//      - Tap on the Repository button
//    - Steps:
//      - Switch View Type to grid
//      - Switch View Type to list
//      - Verify that view type is saved when user change one and leave Repository page
//      - Verify that view type on search result like Repository screen
//      - Verify that view type on Repository screen like on search result when user change one here
//    - Results:
//      - User can see items as grid (user can see icon and label of item) and View Type button should be switched
//      - User can see items as list (user can see icon, label and description of item) and View Type button should be switched
//    - After:
- (void)testThatUserCanChangeViewTypeOnRepositoryPage
{
    [self switchViewFromListToGridInSectionWithTitle:@"Repository"];
    [self verifyThatCollectionViewContainsGridOfCells];
    
    [self openLibrarySection];
    [self openRepositorySection];
    [self verifyThatCollectionViewContainsCells];
    [self verifyThatCollectionViewContainsGridOfCells];
    
    [self switchViewFromGridToListInSectionWithTitle:@"Repository"];
    [self verifyThatCollectionViewContainsListOfCells];
}
    
//  Pull down to refresh all items
//    - Preconditions:
//      - Open the Left Panel
//      - Tap on the Repository button
//    - Steps:
//      - Pull down to refresh
//    - Results:
//      - Repository screen should refresh
//    - After:
- (void)testThatUserCanPullDownToRefreshOnRepositoryPage
{
    [self performPullDownToRefresh];
}

//  Scroll
//    - Preconditions:
//      - Open the Left Panel
//      - Tap on the Repository button
//    - Steps:
//      - Scroll the list
//      - Scroll the grid
//    - Results:
//      - Scroll should work as expected
//    - After:
- (void)testThatUserCanScrollOnRepositoryPage
{
    [self performSwipeToScrool];
}
    
//  Empty folder
//    - Preconditions:
//      - Open the Left Panel
//      - Tap on the Repository button
//    - Steps:
//      - Open any empty folder
//    - Results:
//      - User should see message “No Results.”
//    - After:
- (void)testThatEmptyFolderHasCorrectMessage
{
    [self switchViewFromGridToListInSectionWithTitle:@"Repository"];
    [self searchResourceWithName:@"Monitoring"
               inSectionWithName:@"Repository"];

    NSInteger cellsCount = [self countOfListCells];
    if (cellsCount > 0) {
        // Some instances hasn't the folder
        [self openFolderWithName:@"Monitoring"];
        [self verifyThatCollectionViewContainsCells];
        [self openFolderWithName:@"Monitoring Domains"];
        XCUIElement *noResultLabel = [self waitElementMatchingType:XCUIElementTypeStaticText
                                                              text:@"No Results."
                                                           timeout:kUITestsBaseTimeout];
        if (!noResultLabel.exists) {
            XCTFail(@"There isn't 'No Results.' label");
        }

        [self backToFolderWithName:@"Monitoring"];
        [self backToFolderWithName:@"Repository"];
    }
}

//  JRS 6.0/6.0.1/6.1: Report Thumbnails
//    - Preconditions:
//      - Open the Left Panel
//      - Tap on the Repository button
//    - Steps:
//      - Don’t run the part of the reports
//      - Run the part of the reports
//    - Results:
//      - User should see default placeholder for non runned reports
//      - User should see Report Thumbnails for runned reports
//    - After:
- (void)testThatThumbnailsVisibleInRepositoryPage
{
    
}

- (void)performPullDownToRefresh
{
    XCUIElement *collectionViewElement = [self collectionViewElementFromSectionWithAccessibilityId:@"JMBaseCollectionContentViewAccessibilityId"];

    XCUIElement *firstCellElement = [collectionViewElement.cells elementBoundByIndex:0];
    XCUIElement *secondCellElement = [collectionViewElement.cells elementBoundByIndex:1];

    [firstCellElement pressForDuration:1
                     thenDragToElement:secondCellElement];
}

- (void)performSwipeToScrool
{
    XCUIElement *collectionViewElement = [self collectionViewElementFromSectionWithAccessibilityId:@"JMBaseCollectionContentViewAccessibilityId"];
    XCUIElement *cellElement = [collectionViewElement.cells elementBoundByIndex:0];
    [cellElement swipeUp];
}

@end
