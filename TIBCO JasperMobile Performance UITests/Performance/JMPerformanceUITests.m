//
//  JMPerformanceUITests.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 5/16/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMPerformanceUITests.h"
#import "XCUIElement+Tappable.h"

NSInteger static kJMRunReportTestCellIndex = 2;

@implementation JMPerformanceUITests

#pragma mark - Performance Login
- (void)testLogin
{
    [self givenThatLibraryPageOnScreen];
    [self logout];
    
    [self measureBlock:^{
        [self loginWithTestProfileIfNeed];
        
        [self givenThatLibraryPageOnScreen];
        [self logout];
    }];
}

#pragma mark - Performance Run Report
- (void)testRunReport
{
    [self givenThatLibraryPageOnScreen];
    [self givenThatListCellsAreVisible];
    
    [self runTestReport];
    [self backToLibrary];
    
    [self measureBlock:^{
        [self runTestReport];
        [self backToLibrary];
    }];

}

- (void)runTestReport
{
    XCUIElement *testCell = [self testCell];
    if (testCell.exists) {
        XCUIElement *reportNameLabel = testCell.staticTexts[@"JMResourceCellResourceNameLabelAccessibilityId"];
        NSString *reportInfoLabel = reportNameLabel.label;
        
        [testCell tapByWaitingHittable];
        
        [self verifyThatReportPageOnScreenWithReportName:reportInfoLabel];
    } else {
        XCTFail(@"'Test Cell' wasn't visible");
    }

    [self givenLoadingPopupNotVisible];
}

- (void)backToLibrary
{
    XCUIElement *navBar = [self.application.navigationBars elementBoundByIndex:0];
    if (navBar.exists) {
        NSArray *allButtons = navBar.buttons.allElementsBoundByAccessibilityElement;
        NSLog(@"all buttons: %@", allButtons);
        for (XCUIElement *button in allButtons) {
            if ([button.label isEqualToString:JMLocalizedString(@"menuitem_library_label")]) {
                [button tapByWaitingHittable];
                break;
            }
        }
    } else {
        XCTFail(@"Nav bar isn't visible");
    }
}

#pragma mark - Helpers
- (XCUIElement *)testCell
{
    // Run second report
    XCUIElement *testCell = [self.application.collectionViews.cells elementBoundByIndex:kJMRunReportTestCellIndex];
    return testCell;
}

- (void)verifyThatReportPageOnScreenWithReportName:(NSString *)reportName
{
    NSLog(@"reportName: %@", reportName);
    
    XCUIElement *reportNavBar = [self.application.navigationBars elementMatchingType:XCUIElementTypeAny identifier:reportName];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.exists == true"];
    [self expectationForPredicate:predicate
              evaluatedWithObject:reportNavBar
                          handler:nil];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

@end
