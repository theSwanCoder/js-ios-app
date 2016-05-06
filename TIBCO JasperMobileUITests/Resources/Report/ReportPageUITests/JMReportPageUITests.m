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

#pragma mark - Tests - Main
// User should see the report
//- (void)testThatReportCanBeRun
//{
//    [self givenThatLibraryPageOnScreen];
//    [self givenThatCellsAreVisible];
//    
//    XCUIElement *testCell = [self testCell];
//    if (testCell) {
//        [self runTestReport];
//        
//        XCUIElement *navBar = [self.application.navigationBars elementBoundByIndex:0];
//        if (navBar.exists) {
//            NSArray *allButtons = navBar.buttons.allElementsBoundByAccessibilityElement;
//            for (XCUIElement *button in allButtons) {
//                if ([button.label isEqualToString:@"Back"]) {
//                    [button tap];
//                    break;
//                }
//            }
//        }
//    } else {
//        XCTFail(@"'Test Cell' isn't visible");
//    }
//}
//
//- (void)runTestReport
//{
//    XCUIElement *testCell = [self testCell];
//    
//    XCUIElement *reportNameLabel = testCell.staticTexts[@"JMResourceCellResourceNameLabelAccessibilityId"];
//    NSString *reportInfoLabel = reportNameLabel.label;
//    
//    [testCell tap];
//    
////    [self verifyThatLoadingPopupVisible];
//    sleep(2);
//    [self verifyThatLoadingPopupNotVisible];
//    
//    if ([self verifyIfReportFiltersPageOnScreen]) {
////        [self verifyThatReportFiltersPageOnScreen];
//        
//        // Run report
//        XCUIElement *runReportButton = self.application.buttons[@"Run Report"];
//        if (runReportButton.exists) {
//            [runReportButton tap];
//        } else {
//            XCTFail(@"'Run Report' button isn't visible");
//        }
//        
////        [self verifyThatLoadingPopupVisible];
//        sleep(2);
//        [self verifyThatLoadingPopupNotVisible];
//    }
//    
//    [self verifyThatReportPageOnScreenWithReportName:reportInfoLabel];
//}
//
//// Loader
//- (void)testThatUserCanCancelLoadingReport
//{
//    // try run report
//    // wait until loader with 'cancel' button appears
//    // tap 'cancel' button
//    // verify user is on 'library' page
//    
//    [self givenThatLibraryPageOnScreen];
//    [self givenThatCellsAreVisible];
//    
//    XCUIElement *testCell = [self testCell];
//    if (testCell.exists) {
//        [testCell tap];
//        
//        [self verifyThatLoadingPopupVisible];
//        [self cancelLoading];
//        
//        [self verifyThatCurrentPageIsLibrary];
//    }
//}
//
//// Title like name of the report
//// TODO: do we need this case?
//
//// Favorite button
//- (void)testThatReportCanBeMarkAsFavorite
//{
//    // go to 'favorites'
//    // verify report isn't in favorites list
//    // try run report
//    // wait until report is run
//    // try open action menu
//    // try mark report as favorites
//    // back to library
//    // go to 'favorites'
//    // verify report is in favorites list
//    // remove report from favorites
//    
//    [self givenThatLibraryPageOnScreen];
//    [self givenThatCellsAreVisible];
//    
//    XCUIElement *testCell = [self testCell];
//    if (testCell) {
//        [self runTestReport];
//        
//        XCUIElement *navBar = [self.application.navigationBars elementBoundByIndex:0];
//        if (navBar.exists) {
//            XCUIElement *menuActionsButton = navBar.buttons[@"Share"];
//            if (menuActionsButton.exists) {
//                [menuActionsButton tap];
//                XCUIElement *menuActionsView = self.application.otherElements[@"JMMenuActionsViewAccessibilityId"];
//                if (menuActionsView.exists) {
//                    //Remove From Favorites
//                    XCUIElement *removeFromFavoriteButton = menuActionsView.staticTexts[@"Remove From Favorites"];
//                    if (removeFromFavoriteButton.exists) {
//                        [removeFromFavoriteButton tap];
//                        if (menuActionsButton.exists) {
//                            [menuActionsButton tap];
//                        }
//                    }
//                    XCUIElement *markAsFavoriteButton = menuActionsView.staticTexts[@"Mark as Favorite"];
//                    if (markAsFavoriteButton.exists) {
//                        [markAsFavoriteButton tap];
//                        
//                        // Verify that report is mark as favorite
//                        // TODO: verify in 'Favorite' section
//
//                        NSArray *allButtons = navBar.buttons.allElementsBoundByAccessibilityElement;
//                        for (XCUIElement *button in allButtons) {
//                            if ([button.label isEqualToString:@"Back"]) {
//                                [button tap];
//                                break;
//                            }
//                        }
//                        
//                    } else {
//                        XCTFail(@"'Refresh' button isn't visible");
//                    }
//                } else {
//                    XCTFail(@"'Menu Actions View' isn't visible");
//                }
//            } else {
//                XCTFail(@"'Menu' button isn't visible");
//            }
//        } else {
//            XCTFail(@"'navBar' isn't visible");
//        }
//    } else {
//        XCTFail(@"'Test Cell' isn't visible");
//    }
//}
//
//// Refresh button
//- (void)testThatUserCanRefreshReport
//{
//    // try run report
//    // wait until report is run
//    // try open action menu
//    // tap 'refresh' button
//    // wait until report has being refreshed
//    // back to the 'library' page
//    
//    [self givenThatLibraryPageOnScreen];
//    [self givenThatCellsAreVisible];
//    
//    XCUIElement *testCell = [self testCell];
//    if (testCell) {
//        [self runTestReport];
//        
//        XCUIElement *navBar = [self.application.navigationBars elementBoundByIndex:0];
//        if (navBar.exists) {
//            XCUIElement *menuActionsButton = navBar.buttons[@"Share"];
//            if (menuActionsButton.exists) {
//                [menuActionsButton tap];
//                
//                XCUIElement *menuActionsView = self.application.otherElements[@"JMMenuActionsViewAccessibilityId"];
//                if (menuActionsView.exists) {
//                    XCUIElement *refreshButton = menuActionsView.staticTexts[@"Refresh"];
//                    if (refreshButton.exists) {
//                        [refreshButton tap];
//                        
////                        [self verifyThatLoadingPopupVisible];
//                        sleep(2);
//                        [self verifyThatLoadingPopupNotVisible];
//
//                        NSArray *allButtons = navBar.buttons.allElementsBoundByAccessibilityElement;
//                        for (XCUIElement *button in allButtons) {
//                            if ([button.label isEqualToString:@"Back"]) {
//                                [button tap];
//                                break;
//                            }
//                        }
//                    } else {
//                        XCTFail(@"'Refresh' button isn't visible");
//                    }
//                } else {
//                    XCTFail(@"'Menu Actions View' isn't visible");
//                }
//            } else {
//               XCTFail(@"'Menu' button isn't visible");
//            }
//        } else {
//            XCTFail(@"'navBar' isn't visible");
//        }
//    } else {
//        XCTFail(@"'Test Cell' isn't visible");
//    }
//}
//
//// Edit Filters button
//- (void)testThatUserCanSeeChangeInputControlsPage
//{
//    // try run report
//    // wait until report is run
//    // try open action menu
//    // tap 'edit filters' button
//    // wait until 'filters' page appears
//    // verify that 'filters' page on screen
//    // back to report page
//    
//    [self givenThatLibraryPageOnScreen];
//    [self givenThatCellsAreVisible];
//    
//    XCUIElement *testCell = [self testCell];
//    if (testCell) {
//        [self runTestReport];
//        
//        XCUIElement *navBar = [self.application.navigationBars elementBoundByIndex:0];
//        if (navBar.exists) {
//            XCUIElement *menuActionsButton = navBar.buttons[@"Share"];
//            if (menuActionsButton.exists) {
//                [menuActionsButton tap];
//                
//                XCUIElement *menuActionsView = self.application.otherElements[@"JMMenuActionsViewAccessibilityId"];
//                if (menuActionsView) {
//                    XCUIElement *editValuesButton = menuActionsView.staticTexts[@"Edit Values"];
//                    if (editValuesButton) {
//                        [editValuesButton tap];
//                        
//                        // verify that 'edit values' page is on the screen
//                        XCUIElement *editValuesFilters = self.application.otherElements[@"JMInputControlsViewControllerAccessibilityIdentifier"];
//                        if (editValuesFilters) {
//                           
//                            // back from edit values page
//                            NSArray *allButtons = navBar.buttons.allElementsBoundByAccessibilityElement;
//                            NSLog(@"allButtons: %@", allButtons);
//                            for (XCUIElement *button in allButtons) {
//                                if ([button.label isEqualToString:@"Back"]) {
//                                    [button tap];
//                                    break;
//                                }
//                            }
//                            
//                            // back from report view page
//                            allButtons = navBar.buttons.allElementsBoundByAccessibilityElement;
//                            NSLog(@"allButtons: %@", allButtons);
//                            for (XCUIElement *button in allButtons) {
//                                if ([button.label isEqualToString:@"Back"]) {
//                                    [button tap];
//                                    break;
//                                }
//                            }
//
//                        } else {
//                            XCTFail(@"User can't see edit values page");
//                        }
//                    } else {
//                        XCTFail(@"'Refresh' button isn't visible");
//                    }
//                } else {
//                    XCTFail(@"'Menu Actions View' isn't visible");
//                }
//            } else {
//                XCTFail(@"'Menu' button isn't visible");
//            }
//        } else {
//            XCTFail(@"'navBar' isn't visible");
//        }
//    } else {
//        XCTFail(@"'Test Cell' isn't visible");
//    }
//}
//
//// TODO: Add case when report is without filters
//
//// Save button
//- (void)testThatUserCanSeeSaveReportPage
//{
//    // try run report
//    // wait until report is run
//    // try open action menu
//    // tap 'save report' button
//    // wait until 'save report' page appears
//    // verify that 'save report' page on screen
//    // back to report page
//    // back to the 'library' page
//    
//    [self givenThatLibraryPageOnScreen];
//    [self givenThatCellsAreVisible];
//    
//    XCUIElement *testCell = [self testCell];
//    if (testCell) {
//        [self runTestReport];
//        
//        XCUIElement *navBar = [self.application.navigationBars elementBoundByIndex:0];
//        if (navBar.exists) {
//            XCUIElement *menuActionsButton = navBar.buttons[@"Share"];
//            if (menuActionsButton.exists) {
//                [menuActionsButton tap];
//                
//                XCUIElement *menuActionsView = self.application.otherElements[@"JMMenuActionsViewAccessibilityId"];
//                if (menuActionsView) {
//                    XCUIElement *saveButton = menuActionsView.staticTexts[@"Save"];
//                    if (saveButton) {
//                        [saveButton tap];
//                        
//                        // verify that 'save report' page is on the screen
//                        XCUIElement *saveReportPage = self.application.otherElements[@"JMSaveReportViewControllerAccessibilityIdentifier"];
//                        if (saveReportPage) {
//                            
//                            // back from save report page
//                            NSArray *allButtons = navBar.buttons.allElementsBoundByAccessibilityElement;
//                            NSLog(@"allButtons: %@", allButtons);
//                            for (XCUIElement *button in allButtons) {
//                                if ([button.label isEqualToString:@"Back"]) {
//                                    [button tap];
//                                    break;
//                                }
//                            }
//                            
//                            // back from report view page
//                            allButtons = navBar.buttons.allElementsBoundByAccessibilityElement;
//                            NSLog(@"allButtons: %@", allButtons);
//                            for (XCUIElement *button in allButtons) {
//                                if ([button.label isEqualToString:@"Back"]) {
//                                    [button tap];
//                                    break;
//                                }
//                            }
//
//                        } else {
//                            XCTFail(@"User can't see 'save report' page");
//                        }
//                    } else {
//                        XCTFail(@"'Refresh' button isn't visible");
//                    }
//                } else {
//                    XCTFail(@"'Menu Actions View' isn't visible");
//                }
//            } else {
//                XCTFail(@"'Menu' button isn't visible");
//            }
//        } else {
//            XCTFail(@"'navBar' isn't visible");
//        }
//    } else {
//        XCTFail(@"'Test Cell' isn't visible");
//    }
//}
//
//// Print button
//- (void)testThatUserCanPrintReport
//{
//    // try run report
//    // wait until report is run
//    // try open action menu
//    // tap 'print' button
//    // wait until 'print' page appears
//    // verify that 'print' page on screen
//    // back to report page
//    // back to the 'library' page
//    
//    [self givenThatLibraryPageOnScreen];
//    [self givenThatCellsAreVisible];
//    
//    XCUIElement *testCell = [self testCell];
//    if (testCell) {
//        [self runTestReport];
//        
//        XCUIElement *navBar = [self.application.navigationBars elementBoundByIndex:0];
//        if (navBar.exists) {
//            XCUIElement *menuActionsButton = navBar.buttons[@"Share"];
//            if (menuActionsButton.exists) {
//                [menuActionsButton tap];
//                
//                XCUIElement *menuActionsView = self.application.otherElements[@"JMMenuActionsViewAccessibilityId"];
//                if (menuActionsView) {
//                    XCUIElement *printButton = menuActionsView.staticTexts[@"Print"];
//                    if (printButton) {
//                        [printButton tap];
//                        
//                        sleep(2);
//                        [self verifyThatLoadingPopupNotVisible];
//                        // verify that 'print report' page is on the screen
//                        XCUIElement *printNavBar = self.application.navigationBars[@"Printer Options"];
//                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.exists == true"];
//                        [self expectationForPredicate:predicate
//                                  evaluatedWithObject:printNavBar
//                                              handler:nil];
//                        [self waitForExpectationsWithTimeout:5 handler:nil];
//
//                        XCUIElement *cancelButton = printNavBar.buttons[@"Cancel"];
//                        if (cancelButton.exists) {
//                            [cancelButton tap];
//                        }
//                        
//                        NSArray *allButtons = navBar.buttons.allElementsBoundByAccessibilityElement;
//                        for (XCUIElement *button in allButtons) {
//                            if ([button.label isEqualToString:@"Back"]) {
//                                [button tap];
//                                break;
//                            }
//                        }
//
//                    } else {
//                        XCTFail(@"'Refresh' button isn't visible");
//                    }
//                } else {
//                    XCTFail(@"'Menu Actions View' isn't visible");
//                }
//            } else {
//                XCTFail(@"'Menu' button isn't visible");
//            }
//        } else {
//            XCTFail(@"'navBar' isn't visible");
//        }
//    } else {
//        XCTFail(@"'Test Cell' isn't visible");
//    }
//}
//
//// Info button
//- (void)testThatUserCanSeeInfoReportPage
//{
//    // try run report
//    // wait until report is run
//    // try open action menu
//    // tap 'info' button
//    // wait until 'info' page appears
//    // verify that 'info' page on screen
//    // back to report page
//    // back to the 'library' page
//    
//    [self givenThatLibraryPageOnScreen];
//    [self givenThatCellsAreVisible];
//    
//    XCUIElement *testCell = [self testCell];
//    if (testCell) {
//        [self runTestReport];
//        
//        XCUIElement *navBar = [self.application.navigationBars elementBoundByIndex:0];
//        if (navBar.exists) {
//            XCUIElement *menuActionsButton = navBar.buttons[@"Share"];
//            if (menuActionsButton.exists) {
//                [menuActionsButton tap];
//                
//                XCUIElement *menuActionsView = self.application.otherElements[@"JMMenuActionsViewAccessibilityId"];
//                if (menuActionsView) {
//                    XCUIElement *infoButton = menuActionsView.staticTexts[@"Info"];
//                    if (infoButton) {
//                        [infoButton tap];
//                        
//                        // verify that 'info' page is on the screen
//                        [self verifyThatReportInfoPageOnScreen];
//                        
//                        NSArray *allButtons = navBar.buttons.allElementsBoundByAccessibilityElement;
//                        for (XCUIElement *button in allButtons) {
//                            if ([button.label isEqualToString:@"Back"]) {
//                                [button tap];
//                                break;
//                            }
//                        }
//
//                    } else {
//                        XCTFail(@"'Refresh' button isn't visible");
//                    }
//                } else {
//                    XCTFail(@"'Menu Actions View' isn't visible");
//                }
//            } else {
//                XCTFail(@"'Menu' button isn't visible");
//            }
//        } else {
//            XCTFail(@"'navBar' isn't visible");
//        }
//    } else {
//        XCTFail(@"'Test Cell' isn't visible");
//    }
//}

// Back button like "Library"
// TODO: do we need this case?

// Zoom on Report View screen
// TODO: skip this for now

// Pagination
// TODO: run this test on other test report.
//- (void)testThatUserCanChangePage
//{
//    // try run report
//    // wait until report is run
//    // tap 'next' button
//    // wait until 'next' page appears
//    // back to the 'library' page
//    
//    // TODO: run this test on other test report.
//    XCTFail(@"Not implemented tests");
//}

// JRS 6.0+: Hyperlinks
// TODO: skip this for now

// Chart report with legends
// TODO: skip this for now

// Multilanguage Report
// TODO: skip this for now

// JIVE
// TODO: skip this for now

#pragma mark - Helpers
- (XCUIElement *)testCell
{
    XCUIElement *testCell = [self.application.collectionViews.cells elementBoundByIndex:kJMRunReportTestCellIndex];
    return testCell;
}

- (void)cancelLoading
{
    XCUIElement *loadingPopup = [self.application.otherElements elementMatchingType:XCUIElementTypeAny identifier:@"JMCancelRequestPopupAccessibilityId"];
    
    XCUIElement *cancelButton = loadingPopup.buttons[@"Cancel"];
    if (cancelButton) {
        [cancelButton tap];
    } else {
        XCTFail(@"'Cancel' button doesn't exist.");
    }
}

#pragma mark - Verifies
- (BOOL)verifyIfReportFiltersPageOnScreen
{
    BOOL isFilterPage = NO;
    XCUIElement *filtersNavBar = [self.application.navigationBars elementMatchingType:XCUIElementTypeAny identifier:@"Filters"];
    isFilterPage = filtersNavBar.exists;
    return isFilterPage;
}

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

- (void)verifyThatReportInfoPageOnScreen
{
    XCUIElement *reportInfoPageElement = self.application.otherElements[@"JMReportInfoViewControllerAccessibilityId"];
    NSPredicate *cellsCountPredicate = [NSPredicate predicateWithFormat:@"self.exists == true"];
    [self expectationForPredicate:cellsCountPredicate
              evaluatedWithObject:reportInfoPageElement
                          handler:nil];
    [self waitForExpectationsWithTimeout:5 handler:nil];

    XCUIElement *navBar = [self.application.navigationBars elementBoundByIndex:0];
    XCUIElement *cancelButton = navBar.buttons[@"Cancel"];
    if (cancelButton.exists) {
        [cancelButton tap];
    }
}

@end
