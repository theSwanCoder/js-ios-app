//
//  JMReportInfoDialogUITests.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 2/19/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMReportInfoDialogUITests.h"
#import "JMBaseUITestCase+Report.h"
#import "JMBaseUITestCase+InfoPage.h"
#import "JMBaseUITestCase+ActionsMenu.h"
#import "JMBaseUITestCase+Helpers.h"
#import "JMBaseUITestCase+Favorites.h"

@implementation JMReportInfoDialogUITests

- (void)setUp
{
    [super setUp];

    [self openTestReportPage];
    [self openInfoPageFromMenuActions];
}

- (void)tearDown
{
    [self closeInfoPageFromMenuActions];
    [self closeTestReportPage];

    [super tearDown];
}

#pragma mark - Tests

//  User should see Info Dialog about the report
//    - Preconditions:
//      - Open the Left Panel
//      - Tap on the Library button
//      - Open test report
//    - Steps:
//      - Tap Info button
//    - Results:
//      - User should see Info Dialog about the report
//          - Name: ‘correct name’
//          - Description: appropriate version
//          - URI: appropriate version
//          - Type: Report
//          - Version: appropriate version
//          - Creation Date: appropriate date
//          - Modified Date: appropriate date
//    - After:
- (void)testThatUserCanSeeCorrectDataOnInfoDialog
{
//    [self verifyThatInfoPageForTestReportContainsCorrectData];
}

//  Title on the Info Dialog like title of the report
//    - Preconditions:
//      - Open the Left Panel
//      - Tap on the Library button
//      - Open test report
//    - Steps:
//      - Tap Info Button
//    - Results:
//      - User should see title on the Info Dialog like title of the report
//    - After:
- (void)testThatInfoDialogHasCorrectTitle
{
    [self verifyThatInfoPageForTestReportHasCorrectTitle];
}

//  Favorite button
//    - Preconditions:
//      - Open the Left Panel
//      - Tap on the Library button
//      - Open test report
//    - Steps:
//      - Tap Info button
//      - Add item to favorite
//      - Remove item from favorite
//    - Results:
//      - Star should be filled after adding the item to favorites
//      - Star should be empty after removing the item from favorites
//    - After:
- (void)testThatFavoriteButtonWorkOnInfoDialog
{
    XCUIElement *navBar = [self findNavigationBarWithControllerAccessibilityId:kTestReportName];
    [self markAsFavoriteFromNavigationBar:navBar];
    [self unmarkFromFavoritesFromNavigationBar:navBar];
}

//  Cancel button on Info Dialog
//    - Preconditions:
//      - Open the Left Panel
//      - Tap on the Library button
//      - Open test report
//    - Steps:
//      - Tap Info button
//      - Tap Cancel button on Info Dialog
//    - Results:
//      - Report View screen should appear
//    - After:
- (void)testThatUserCanCancelInfoDialog
{
    [self verifyThatInfoPageHasCancelButton];
}
    
#pragma mark - Verifying

- (void)verifyThatInfoPageHasCancelButton
{
    XCUIElement *navBar = [self findNavigationBarWithControllerAccessibilityId:JMReportViewerPageAccessibilityId];
    XCUIElement *cancelButton = [self findButtonWithAccessibilityId:JMButtonCancelAccessibilityId parentElement:navBar];
    if (!cancelButton.exists) {
        XCTFail(@"Cancel button isn't exist on Info Dialog");
    }
}
    
@end
