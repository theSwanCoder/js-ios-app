//
//  JMReportInfoPageUITests.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 2/19/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMLibraryInfoPageUITests.h"
#import "JMBaseUITestCase+Helpers.h"

NSInteger static kJMReportInfoPageTestCellIndex = 0;

@implementation JMLibraryInfoPageUITests

#pragma mark - Tests - Main
- (void)testThatReportInfoPageCanBeViewed
{
    [self givenThatLibraryPageOnScreen];
    [self givenThatCellsAreVisible];

    // open info page
    [self givenThatReportInfoPageOnScreen];
    
    [self tryBackToPreviousPage];
}

- (void)testThatReportInfoPageHasTitleAsReportLabel
{
    [self givenThatLibraryPageOnScreen];
    [self givenThatCellsAreVisible];
    
    // get label of first report
    XCUIElement *testCell = [self waitTestCell];
    XCUIElement *reportNameLabel = testCell.staticTexts[@"JMResourceCellResourceNameLabelAccessibilityId"];
    NSString *reportInfoLabel = reportNameLabel.label;
    
    [self givenThatReportInfoPageOnScreen];
    
    [self waitNavigationBarWithLabel:reportInfoLabel
                             timeout:kUITestsBaseTimeout];

    [self tryBackToPreviousPage];
}

- (void)testThatReportInfoPageHasFullReportInfo
{
    [self givenThatLibraryPageOnScreen];
    [self givenThatCellsAreVisible];

    // open info page
    [self givenThatReportInfoPageOnScreen];
    
    [self verifyThatReportInfoPageContainsFullReportInfo];
    
    [self tryBackToPreviousPage];
}

#pragma mark - Tests - Menu
- (void)testThatReportCanBeMarkAsFavorite
{
    // Pre
    [self givenThatLibraryPageOnScreen];
    [self givenThatCellsAreVisible];
    
    // get label of first report
    XCUIElement *testCell = [self testCell];
    XCUIElement *reportNameLabel = testCell.staticTexts[@"JMResourceCellResourceNameLabelAccessibilityId"];
    NSString *reportInfoLabel = reportNameLabel.label;
    
    [self givenThatReportNotMarkAsFavorite:reportInfoLabel];

    
    // Test
    [self givenThatCellsAreVisible];
    [self givenThatReportInfoPageOnScreen];
    [self tryMarkTestReportAsFavorite];
    
    // verify report is favorite
    [self tryBackToPreviousPage];
    [self givenThatLibraryPageOnScreen];
    [self tryOpenFavoritePage];
    if (![self isReportMarkAsFavorite:reportInfoLabel]) {
        XCTFail(@"Test report isn't marked as favorite.");
    }
    [self tryOpenLibraryPage];
    
    // Clean Up
    [self givenThatLibraryPageOnScreen];
    [self givenThatCellsAreVisible];
    [self givenThatReportInfoPageOnScreen];
    [self tryUnMarkTestReportAsFavorite];
    
    [self tryBackToPreviousPage];
}

#pragma mark - Helpers
- (void)givenThatReportInfoPageOnScreen
{
    [self tryOpenReportInfoPage];
    [self verifyThatReportInfoPageOnScreen];
}

- (void)tryOpenReportInfoPage
{
    XCUIElement *testCell = [self testCell];
    XCUIElement *infoButton = testCell.buttons[@"More Info"];
    if (infoButton.exists) {
        [infoButton tap];
    } else {
        XCTFail(@"'Info' button isn't visible.");
    }
}

- (XCUIElement *)waitTestCell
{
    XCUIElement *testCell = [self testCell];
    [self waitElement:testCell
              visible:true
              timeout:kUITestsBaseTimeout];
    return testCell;
}

- (XCUIElement *)testCell
{
    XCUIElement *testCell = [self.application.collectionViews.cells elementBoundByIndex:kJMReportInfoPageTestCellIndex];
    return testCell;
}

#pragma mark - Helpers - Menu
- (void)givenThatReportNotMarkAsFavorite:(NSString *)reportLabel
{
    [self tryOpenFavoritePage];
    
    if ( [self isReportMarkAsFavorite:reportLabel] ) {
        // unmark
        [self givenThatReportInfoPageOnScreen];
        [self tryUnMarkTestReportAsFavorite];
        [self tryBackToPreviousPage];
    }
    
    [self tryOpenLibraryPage];
    [self givenThatCellsAreVisible];
}

- (BOOL)isReportMarkAsFavorite:(NSString *)reportLabel
{
    BOOL isTestReportMarkAsFavorite = NO;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.label == %@", reportLabel];
    XCUIElementQuery *query = [self.application.cells.staticTexts matchingPredicate:predicate];
    if (query.count > 0) {
        isTestReportMarkAsFavorite = YES;
    }
    
    return isTestReportMarkAsFavorite;
}

- (void)tryMarkTestReportAsFavorite
{
    [self openMenuActions];
    
    XCUIElement *menu = [self.application.otherElements elementMatchingType:XCUIElementTypeAny identifier:@"JMMenuActionsViewAccessibilityId"];
    XCUIElement *markAsFavoriteElement = menu.staticTexts[@"Mark as Favorite"];
    if (markAsFavoriteElement.exists) {
        [markAsFavoriteElement tap];
    } else {
        XCTFail(@"'Mark as Favorites' item isn't visible");
    }
}

- (void)tryUnMarkTestReportAsFavorite
{
    [self openMenuActions];
    
    XCUIElement *menu = [self.application.otherElements elementMatchingType:XCUIElementTypeAny identifier:@"JMMenuActionsViewAccessibilityId"];
    XCUIElement *unmarkAsFavoriteElement = menu.staticTexts[@"Remove From Favorites"];
    if (unmarkAsFavoriteElement.exists) {
        [unmarkAsFavoriteElement tap];
    } else {
        XCTFail(@"'Remove From Favorites' item isn't visible");
    }
}

#pragma mark - Verifies
- (void)verifyThatReportInfoPageOnScreen
{
    XCUIElement *reportInfoPageElement = self.application.otherElements[@"JMReportInfoViewControllerAccessibilityId"];
    NSPredicate *cellsCountPredicate = [NSPredicate predicateWithFormat:@"self.exists == true"];
    [self expectationForPredicate:cellsCountPredicate
              evaluatedWithObject:reportInfoPageElement
                          handler:nil];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)verifyThatReportInfoPageContainsFullReportInfo
{
    XCUIElement *reportInfoPageElement = self.application.otherElements[@"JMReportInfoViewControllerAccessibilityId"];
    XCUIElement *nameLabel = reportInfoPageElement.staticTexts[@"Name"];
    if (!nameLabel.exists) {
        XCTFail(@"Name Label isn't visible.");
    }
    
    XCUIElement *descriptionLabel = reportInfoPageElement.staticTexts[@"Description"];
    if (!descriptionLabel.exists) {
        XCTFail(@"Description Label isn't visible.");
    }
    
    XCUIElement *uriLabel = reportInfoPageElement.staticTexts[@"URI"];
    if (!uriLabel.exists) {
        XCTFail(@"URI Label isn't visible.");
    }
    
    XCUIElement *typeLabel = reportInfoPageElement.staticTexts[@"Type"];
    if (!typeLabel.exists) {
        XCTFail(@"Type Label isn't visible.");
    }
    
    XCUIElement *versionLabel = reportInfoPageElement.staticTexts[@"Version"];
    if (!versionLabel.exists) {
        XCTFail(@"Version Label isn't visible.");
    }
    
    XCUIElement *creatingDateLabel = reportInfoPageElement.staticTexts[@"Creation Date"];
    if (!creatingDateLabel.exists) {
        XCTFail(@"'Creation Date' Label isn't visible.");
    }
    
    XCUIElement *modifiedDateLabel = reportInfoPageElement.staticTexts[@"Modified Date"];
    if (!modifiedDateLabel.exists) {
        XCTFail(@"'Modified Date' Label isn't visible.");
    }
}

@end
