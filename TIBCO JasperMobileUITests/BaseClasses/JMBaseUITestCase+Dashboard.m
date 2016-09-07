//
// Created by Aleksandr Dakhno on 9/7/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMBaseUITestCase+Dashboard.h"
#import "JMBaseUITestCase+Helpers.h"
#import "JMBaseUITestCase+ActionsMenu.h"

NSString *const kTestDashboardName = @"1. Supermart Dashboard";

@implementation JMBaseUITestCase (Dashboard)

#pragma mark - Operations

- (void)openTestDashboardPage
{
    [self givenThatLibraryPageOnScreen];
    [self givenThatListCellsAreVisible];

    [self searchTestDashboard];
    [self tryOpenTestDashboard];
}

- (void)closeTestDashboardPage
{
    [self tryBackToPreviousPage];
}

- (void)openDashboardInfoPage
{
    [self openMenuActions];
    [self selectActionWithName:@"Info"];
    [self givenThatDashboardInfoPageOnScreen];
}

- (void)closeDashboardInfoPage
{
    XCUIElement *navBar = [self findNavigationBarWithLabel:nil];
    XCUIElement *cancelButton = [self waitButtonWithAccessibilityId:@"Cancel"
                                                      parentElement:navBar
                                                            timeout:kUITestsBaseTimeout];
    [cancelButton tap];
}

- (void)markDashboardAsFavoriteFromInfoPage
{
    XCUIElement *navBar = [self waitNavigationBarWithLabel:kTestDashboardName
                                                   timeout:kUITestsBaseTimeout];
    XCUIElement *favoriteButton = [self waitButtonWithAccessibilityId:@"make favorite item"
                                                        parentElement:navBar
                                                              timeout:kUITestsBaseTimeout];
    [favoriteButton tap];
}

- (void)unmarkDashboardFromFavoriteFromInfoPage
{
    XCUIElement *navBar = [self waitNavigationBarWithLabel:kTestDashboardName
                                                   timeout:kUITestsBaseTimeout];
    XCUIElement *favoriteButton = [self waitButtonWithAccessibilityId:@"favorited item"
                                                        parentElement:navBar
                                                              timeout:kUITestsBaseTimeout];
    [favoriteButton tap];
}

#pragma mark - Helpers

- (void)searchTestDashboard
{
    [self searchResourceWithName:kTestDashboardName
                       inSection:@"Library"];
}

- (void)tryOpenTestDashboard
{
    XCUIElement *testCell = [self testDashboardCell];
    [testCell tap];

    [self givenLoadingPopupNotVisible];
}

- (XCUIElement *)testDashboardCell
{
    XCUIElement *testCell = [self findCellWithAccessibilityId:@"JMCollectionViewListCellAccessibilityId"
                             containsLabelWithAccessibilityId:@"JMResourceCellResourceNameLabelAccessibilityId"
                                                    labelText:kTestDashboardName];
    if (!testCell) {
        XCTFail(@"There isn't test cell");
    }
    return testCell;
}

- (void)givenThatDashboardInfoPageOnScreen
{
    [self waitElementWithAccessibilityId:@"JMDashboardInfoViewControllerAccessibilityId"
                                 timeout:kUITestsBaseTimeout];
}

@end