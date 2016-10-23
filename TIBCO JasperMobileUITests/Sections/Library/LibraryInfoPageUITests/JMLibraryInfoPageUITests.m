//
//  JMReportInfoPageUITests.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 2/19/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMLibraryInfoPageUITests.h"
#import "JMBaseUITestCase+InfoPage.h"
#import "JMBaseUITestCase+Favorites.h"
#import "JMBaseUITestCase+Helpers.h"
#import "JMBaseUITestCase+ActionsMenu.h"

@implementation JMLibraryInfoPageUITests

- (void)setUp
{
    [super setUp];
    
    [self givenThatLibraryPageOnScreen];
    [self givenThatCellsAreVisible];
}

#pragma mark - Tests - Main
- (void)testThatReportInfoPageCanBeViewed
{
    [self openInfoPageForTestReportFromSectionWithAccessibilityId:JMLibraryPageAccessibilityId];
    [self verifyInfoPageOnScreenForPageWithAccessibilityId:JMReportInfoPageAccessibilityId];
}

- (void)testThatReportInfoPageHasTitleAsReportLabel
{
    [self openInfoPageForTestReportFromSectionWithAccessibilityId:JMLibraryPageAccessibilityId];
    [self verifyThatInfoPageForTestReportHasCorrectTitle];
}

#pragma mark - Tests - Menu
- (void)testThatReportCanBeMarkAsFavorite
{
    [self openInfoPageForTestReportFromSectionWithAccessibilityId:JMLibraryPageAccessibilityId];
    
    XCUIElement *navBar = [self findNavigationBarWithControllerAccessibilityId:JMReportInfoPageAccessibilityId];
    XCUIElement *markAsFavoriteButton = [self findButtonWithAccessibilityId:JMMenuActionsViewMarkAsFavoriteActionAccessibilityId parentElement:navBar];
    if (markAsFavoriteButton.exists) {
        [markAsFavoriteButton tap];
    } else {
        [self openMenuActionsWithControllerAccessibilityId:JMReportInfoPageAccessibilityId];
        [self selectActionWithAccessibility:JMMenuActionsViewMarkAsFavoriteActionAccessibilityId];
    }
    
    XCUIElement *markAsUnFavoriteButton = [self findButtonWithAccessibilityId:JMMenuActionsViewMarkAsUnFavoriteActionAccessibilityId parentElement:navBar];
    if (markAsUnFavoriteButton.exists) {
        [markAsUnFavoriteButton tap];
    } else {
        [self openMenuActionsWithControllerAccessibilityId:JMReportInfoPageAccessibilityId];
        [self selectActionWithAccessibility:JMMenuActionsViewMarkAsUnFavoriteActionAccessibilityId];
    }
}

@end
