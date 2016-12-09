//
//  JMSavedItemsPageUITests.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 2/19/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMSavedItemsPageUITests.h"
#import "JMBaseUITestCase+SideMenu.h"
#import "JMBaseUITestCase+Helpers.h"
#import "JMBaseUITestCase+SavedItems.h"
#import "JMBaseUITestCase+Report.h"
#import "JMBaseUITestCase+Section.h"

@implementation JMSavedItemsPageUITests

#pragma mark - Tests

//User should see Saved Items screen
//    < Open the Left Panel
//    < Tap on the Saved Items button
//    > User should see Saved Items screen
- (void)testThatUserCanSeeSavedItemsPage
{
    [self openSavedItemsSection];
    [self verifyThatSavedItemsSectionOnScreen];
}

//Left Panel button
//    < Open the Left Panel
//    < Tap on the Saved Items button
//    > User should see Left Panel button on the Saved Items screen
- (void)testThatMenuButtonWorkCorrectly
{
    [self openSavedItemsSection];

    [self showSideMenuInSectionWithName:@"Saved Items"];
    [self verifySideMenuVisible];
    [self hideSideMenuInSectionWithName:@"Saved Items"];
}

//Saved Items title
//    < Open the Left Panel
//    < Tap on the Saved Items button
//    > User should see title like "Saved Items"
- (void)testThatPageHasCorrectTitle
{
    [self openSavedItemsSection];
    [self verifyThatSavedItemsSectionHasCorrectTitle];
}

//Search result
//    < Open the Left Panel
//    < Tap on the Saved Items button
//    < Verify searching operation
//    > User can:
//    - enter search text
//    - edit search text
//    - delete search text
//    - cancel search
//    - see result after searching
- (void)testThatSearchWorkCorrectly
{
    [self givenThatSavedItemsEmpty];
    [self saveTestReportInHTMLFormat];
    [self openSavedItemsSection];

    [self selectFilterBy:@"HTML" inSectionWithTitle:@"Saved Items"];
    
    [self searchResourceWithName:kTestReportName
    inSectionWithAccessibilityId:@"JMBaseCollectionContentViewAccessibilityId"];
    [self verifyTestReportInHTMLFormatIsInSearchResult];
    [self clearSearchResultInSectionWithAccessibilityId:@"JMBaseCollectionContentViewAccessibilityId"];
    
    [self deleteTestReportInHTMLFormat];
}

//Error message when no search result
//    < Open the Left Panel
//    < Tap on the Saved Items button
//    < Enter incorrect search text
//    > User can see error message when no search result
- (void)testThatCorrectMessageAppearsInCaseSearchWithoutResult
{
    [self givenThatSavedItemsEmpty];
    [self saveTestReportInHTMLFormat];
    [self openSavedItemsSection];

    [self searchResourceWithName:@"Wrong Test Saved Item"
    inSectionWithAccessibilityId:@"JMBaseCollectionContentViewAccessibilityId"];
    [self verifyThatNoResultsOnScreen];
    [self clearSearchResultInSectionWithAccessibilityId:@"JMBaseCollectionContentViewAccessibilityId"];

    [self deleteTestReportInHTMLFormat];
}

//Viev type button
//    < Open the Left Panel
//    < Tap on the Saved Items button
//    < Switch View Type to grid
//    < Switch View Type to list
//    < Verify that view type is saved when user change one and leave Saved Items page
//    > User can see items as grid (user can see icon and label of item) and View Type button should be switched
//    > User can see items as list (user can see icon, label and description of item) and View Type button should be switched
- (void)testThatViewTypeButtonWorkCorrectly
{
    [self givenThatSavedItemsEmpty];
    [self saveTestReportInHTMLFormat];
    [self openSavedItemsSection];

    [self verifyThatListOfCellsVisible];
    [self switchViewFromListToGridInSectionWithTitle:@"Saved Items"];
    [self verifyThatGridOfCellsVisible];
    [self switchViewFromGridToListInSectionWithTitle:@"Saved Items"];
    [self verifyThatListOfCellsVisible];
    
    [self deleteTestReportInHTMLFormat];
}

//Sorting button
//    < Open the Left Panel
//    < Tap on the Saved Items button
//    < Tap Sorting button
//    < Select sorting by Name
//    < Select sorting by Creation Date
//    < Select sorting by Modified Date
//    < Verify that sorting options don't save when user leave Saved Items screen
//    > Sorting dialog should appear
//    > User can sorted by Name
//    > User can sorted by Creation Date
//    > User can sorted by Modified Date
- (void)testThatSortButtonWorkCorrectly
{
    [self givenThatSavedItemsEmpty];
    [self saveTestReportInHTMLFormat];
    [self openSavedItemsSection];

    [self selectSortBy:@"Name" inSectionWithTitle:@"Saved Items"];
    [self selectSortBy:@"Creation Date" inSectionWithTitle:@"Library"];
    [self selectSortBy:@"Modified Date" inSectionWithTitle:@"Library"];

    [self deleteTestReportInHTMLFormat];
}

//Filter button
//    < Open the Left Panel
//    < Tap on the Saved Items button
//    < Tap Filter button
//    < Select filter by All
//    < Select filter by HTML
//    < Select filter by PDF
//    < Select filter by XLS
//    < Verify that filter options don't save when user leave Saved Items screen
//    > Filter dialog should appear
//    > User can see all items
//    > User can see only HTML-files
//    > User can see only PDF-files
//    > User can see only XLS-files
- (void)testThatFilterButtonWorkCorrectly
{
    [self givenThatSavedItemsEmpty];
    [self saveTestReportInHTMLFormat];
    [self openSavedItemsSection];
    
    [self selectFilterBy:@"All" inSectionWithTitle:@"Saved Items"];
    [self selectFilterBy:@"HTML" inSectionWithTitle:@"Saved Items"];
    [self selectFilterBy:@"PDF" inSectionWithTitle:@"Saved Items"];
    [self selectFilterBy:@"XLS" inSectionWithTitle:@"Saved Items"];
    
    [self deleteTestReportInHTMLFormat];
}

//Appropriate icon for HTML-file
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run the report
//    < Tap Save icon
//    < Enter correct report name
//    < Choose Output Format as HTML
//    < Tap Save button
//    < Open the Left Panel
//    < Tap on the Saved Items button
//    > User should see Appropriate icon for HTML-file
- (void)testThatHTMLFileHasCorrectIcon
{
    [self givenThatSavedItemsEmpty];
    [self saveTestReportInHTMLFormat];
    [self openSavedItemsSection];
    
    [self verifyThatCellHasIconForHTMLFormat];
    
    [self deleteTestReportInHTMLFormat];
}

//File extension for HTML-file
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run the report
//    < Tap Save icon
//    < Enter correct report name
//    < Choose Output Format as HTML
//    < Tap Save button
//    < Open the Left Panel
//    < Tap on the Saved Items button
//    > User should see file extension for HTML-file as .html
- (void)testThatHTMLFileHasCorrectFormat
{
    [self givenThatSavedItemsEmpty];
    [self saveTestReportInHTMLFormat];
    [self openSavedItemsSection];
    
    [self verifyThatTestSavedItemHasHTMLFormat];
    
    [self deleteTestReportInHTMLFormat];
}

//Appropriate icon for PDF-file
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run the report
//    < Tap Save icon
//    < Enter correct report name
//    < Choose Output Format as PDF
//    < Tap Save button
//    < Open the Left Panel
//    < Tap on the Saved Items button
//    > User should see Appropriate icon for PDF-file
- (void)testThatPDFfileHasCorrectIcon
{
    [self givenThatSavedItemsEmpty];
    [self saveTestReportInPDFFormat];
    [self openSavedItemsSection];

    [self verifyThatCellHasIconForPDFFormat];

    [self deleteTestReportInPDFFormat];
}

//File extension for PDF-file
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run the report
//    < Tap Save icon
//    < Enter correct report name
//    < Choose Output Format as PDF
//    < Tap Save button
//    < Open the Left Panel
//    < Tap on the Saved Items button
//    > User should see file extension for PDF-file as .pdf
- (void)testThatPDFfileHasCorrectFormat
{
    [self givenThatSavedItemsEmpty];
    [self saveTestReportInPDFFormat];
    [self openSavedItemsSection];
    
    [self verifyThatTestSavedItemHasPDFFormat];
    
    [self deleteTestReportInPDFFormat];
}

//Pull down to refresh all items
//    < Open the Left Panel
//    < Tap on the Saved Items button
//    < Pull down to refresh
//    > Saved Items screen should refresh
- (void)testThatPullDownToRefreshWorkCorrectly
{
    [self givenThatSavedItemsEmpty];
    [self saveTestReportInHTMLFormat];
    [self saveTestReportInPDFFormat];
    
    [self openSavedItemsSection];
    
    [self performPullDownToRefresh];
    
    [self deleteTestReportInHTMLFormat];
    [self deleteTestReportInPDFFormat];
}

//Scrolling of the list/grid
//    < Open the Left Panel
//    < Tap on the Saved Items button
//    < Scroll the list
//    < Scroll the grid
//    > Scroll should work as expected
- (void)testThatScrollingWorkCorrectly
{
    [self givenThatSavedItemsEmpty];
    [self saveTestReportInHTMLFormat];
    [self openSavedItemsSection];
    
    [self performSwipeToScrool];
    
    [self deleteTestReportInHTMLFormat];
}

//User should see only saved files which he/she saved they
//    < Open the Left Panel
//    < Tap on the Settings button
//    < Tap on current active server's name
//    < Tap on any server connection
//    < Login as joeuser
//    < Open the Left Panel
//    < Tap on the Library button
//    < Run the report
//    < Tap Save icon
//    < Save the report
//    < Open the Left Panel
//    < Tap on the Settings button
//    < Tap on current active server's name
//    < Tap on any server connection
//    < Login as jasperadmin
//    < Open the Left Panel
//    < Tap on the Saved Items button
//    > Jasperadmin shouldn't see saved files which joeuser saved they
- (void)testThatSavedItemsForActiveAccountVisible
{
//    XCTFail(@"Not implemented tests");
}

#pragma mark - Helpers

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

#pragma mark - Verifying

- (void)verifyThatSavedItemsSectionOnScreen
{
    // TODO: replace with waiting element (collection view) by accessibility id
    [self waitNavigationBarWithLabel:@"Saved Items"
                             timeout:kUITestsBaseTimeout];
}

- (void)verifySideMenuVisible
{
    XCUIElement *sideMenu = [self sideMenuElement];
    if (!sideMenu.exists) {
        XCTFail(@"Side menu should be visible");
    }
}

- (void)verifyThatSavedItemsSectionHasCorrectTitle
{
    [self waitNavigationBarWithLabel:@"Saved Items"
                             timeout:kUITestsBaseTimeout];
}

- (void)verifyTestReportInHTMLFormatIsInSearchResult
{
    [self verifyExistSavedItemWithName:kTestReportName
                                format:@"html"];
}

- (void)verifyThatNoResultsOnScreen
{
    XCUIElement *noResultLabel = [self waitElementMatchingType:XCUIElementTypeStaticText
                                                          text:@"No Saved Items."
                                                       timeout:kUITestsBaseTimeout];
    if (!noResultLabel.exists) {
        XCTFail(@"Message 'No Saved Item' is missed");
    }
}

- (void)verifyThatListOfCellsVisible
{
    NSInteger cellsCount = [self countOfListCells];
    if (cellsCount == 0) {
        XCTFail(@"List of cells should be visible");
    }
}

- (void)verifyThatGridOfCellsVisible
{
    NSInteger cellsCount = [self countOfGridCells];
    if (cellsCount == 0) {
        XCTFail(@"List of cells should be visible");
    }
}

- (void)verifyThatCellHasIconForHTMLFormat
{
    XCUIElement *cell = [self savedItemWithName:kTestReportName
                                         format:@"html"];

    XCUIElement *image = [cell.images elementBoundByIndex:0];
    NSString *imageIdentifier = image.identifier;
    if (![imageIdentifier isEqualToString:@"res_type_file_html"]) {
        XCTFail(@"Icon is not for html format");
    }
}

- (void)verifyThatCellHasIconForPDFFormat
{
    XCUIElement *cell = [self savedItemWithName:kTestReportName
                                         format:@"pdf"];

    XCUIElement *image = [cell.images elementBoundByIndex:0];
    NSString *imageIdentifier = image.identifier;
    if (![imageIdentifier isEqualToString:@"res_type_file_pdf"]) {
        XCTFail(@"Icon is not for html format");
    }
}

- (void)verifyThatTestSavedItemHasHTMLFormat
{
    XCUIElement *cell = [self savedItemWithName:kTestReportName
                                         format:@"html"];
    
    NSString *fullName = [NSString stringWithFormat:@"%@.html", kTestReportName];
    XCUIElement *nameLabel = [self waitElementMatchingType:XCUIElementTypeStaticText
                                                      text:fullName
                                             parentElement:cell
                                                   timeout:kUITestsBaseTimeout];
    if (!nameLabel.exists) {
        XCTFail(@"Cell has incorrect format");
    }
}
    
    
- (void)verifyThatTestSavedItemHasPDFFormat
{
    XCUIElement *cell = [self savedItemWithName:kTestReportName
                                         format:@"pdf"];
    
    NSString *fullName = [NSString stringWithFormat:@"%@.pdf", kTestReportName];
    XCUIElement *nameLabel = [self waitElementMatchingType:XCUIElementTypeStaticText
                                                      text:fullName
                                             parentElement:cell
                                                   timeout:kUITestsBaseTimeout];
    if (!nameLabel.exists) {
        XCTFail(@"Cell has incorrect format");
    }
}
    
@end
