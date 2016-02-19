//
//  JMRunReportTests.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 2/19/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMReportPageUITests.h"

NSInteger static kJMRunReportTestCellIndex = 0;

@implementation JMReportPageUITests

#pragma mark - Setup
- (void)setUp {
    [super setUp];
    
    XCUIElement *loginPageView = self.application.otherElements[@"JMLoginPageAccessibilityId"];
    if (loginPageView.exists) {
        [self loginWithTestProfile];
    }
}

- (void)tearDown {
    [super tearDown];
}

#pragma mark - Tests - Main
- (void)testThatReportCanBeRun
{
    [self givenThatLibraryPageOnScreen];
    [self givenThatCellsAreVisible];
    
    XCUIElement *testCell = [self testCell];
    if (testCell.exists) {
        XCUIElement *reportNameLabel = testCell.staticTexts[@"JMResourceCellResourceNameLabelAccessibilityId"];
        NSString *reportInfoLabel = reportNameLabel.label;
        
        [testCell tap];

        [self verifyThatLoadingPopupVisible];
        [self verifyThatLoadingPopupNotVisible];
        
        [self verifyThatReportFiltersPageOnScreen];
        
        // Run report
        XCUIElement *runReportButton = self.application.buttons[@"Run Report"];
        if (runReportButton.exists) {
            [runReportButton tap];
        } else {
            XCTFail(@"'Run Report' button isn't visible");
        }
        
        [self verifyThatLoadingPopupVisible];
        [self verifyThatLoadingPopupNotVisible];
        
        [self verifyThatReportPageOnScreenWithReportName:reportInfoLabel];
    }
}

#pragma mark - Helpers
- (XCUIElement *)testCell
{
    XCUIElement *testCell = [self.application.collectionViews.cells elementBoundByIndex:kJMRunReportTestCellIndex];
    return testCell;
}

#pragma mark - Verifies
- (void)verifyThatReportFiltersPageOnScreen
{
    XCUIElement *filtersNavBar = [self.application.navigationBars elementMatchingType:XCUIElementTypeAny identifier:@"Filters"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.exists == true"];
    [self expectationForPredicate:predicate
              evaluatedWithObject:filtersNavBar
                          handler:nil];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)verifyThatReportPageOnScreenWithReportName:(NSString *)reportName
{
    XCUIElement *reportNavBar = [self.application.navigationBars elementMatchingType:XCUIElementTypeAny identifier:reportName];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.exists == true"];
    [self expectationForPredicate:predicate
              evaluatedWithObject:reportNavBar
                          handler:nil];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

@end
