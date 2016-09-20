//
//  JMSavedItemInfoDialogUITests.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 2/19/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMSavedItemInfoDialogUITests.h"
#import "JMBaseUITestCase+Helpers.h"
#import "JMBaseUITestCase+SideMenu.h"
#import "JMBaseUITestCase+SavedItems.h"
#import "JMBaseUITestCase+ActionsMenu.h"
#import "JMBaseUITestCase+Resource.h"
#import "JMBaseUITestCase+Report.h"

@implementation JMSavedItemInfoDialogUITests

#pragma mark - Tests

//User should see Info dialog
//    < Open the Left Panel
//    < Tap on the Saved Items button
//    < Open the saved report
//    < Tap Info button on the Saved Report View screen
//    > Info dialog (screen for iPhone) about the report should appear
- (void)testThatUserCanSeeInfoDialog
{
    [self createAndOpenTestSavedItemInHTMLFormat];
    [self showInfoPageTestSavedItemFromViewer];
    
    [self verifyThatInfoPageOnScreen];

    [self closeInfoPageTestSavedItemFromViewer];
    [self closeAndDeleteTestSavedItem];
}

//Cancel button on Info dialog
//    < Open the Left Panel
//    < Tap on the Saved Items button
//    < Open the saved report
//    < Tap Info button on the Saved Report View screen
//    < Tap Cancel button on Info dialog
//    > Saved Report View screen should appears
- (void)testThatCancelButtonWorkCorrectly
{
    [self createAndOpenTestSavedItemInHTMLFormat];
    [self showInfoPageTestSavedItemFromViewer];
    
    [self verifyThatInfoPageHasCancelButton];

    [self closeInfoPageTestSavedItemFromViewer];
    [self closeAndDeleteTestSavedItem];
}

//Title like name of item
//    < Open the Left Panel
//    < Tap on the Saved Items button
//    < Open the saved report
//    < Tap Info button on the Saved Report View screen
//    > User should see title like name of item
- (void)testThatDialogHasCorrectTitle
{
    [self createAndOpenTestSavedItemInHTMLFormat];
    [self showInfoPageTestSavedItemFromViewer];
    
    [self verifyThatInfoPageHasCorrectTitle];

    [self closeInfoPageTestSavedItemFromViewer];
    [self closeAndDeleteTestSavedItem];
}

//Info about the html-file
//    < Open the Left Panel
//    < Tap on the Library button
//    < Open "02. Sales Mix by Demographic Report"
//    < Save the report as html-file
//    < Open the Left Panel
//    < Tap on the Saved Items button
//    < Open the saved report
//    < Tap Info button on the Saved Report View screen
//    > User should see Info Dialog about the report:
//    - Name: 02. Sales Mix by Demographic Report
//    - Description: Sample HTML5 Spider Line chart from OLAP source. Created from an Ad Hoc View.
//    - URI: /reports/02. Sales Mix by Demographic Report.html/report.html
//    - Type: Content Resource
//    - Version: 1
//    - Creation Date: appropriate date
//    - Modified Date: appropriate date
//    - Format: html
- (void)testThatDialogHasNeededFieldsForHTMLfile
{
    [self createAndOpenTestSavedItemInHTMLFormat];
    [self showInfoPageTestSavedItemFromViewer];
    
    [self verifyThatInfoPageHasNeededFieldsForHTMLFile];

    [self closeInfoPageTestSavedItemFromViewer];
    [self closeAndDeleteTestSavedItem];
}

//Info about the pdf-file
//    < Open the Left Panel
//    < Tap on the Library button
//    < Open "02. Sales Mix by Demographic Report"
//    < Save the report as pdf-file
//    < Open the Left Panel
//    < Tap on the Saved Items button
//    < Open the saved report
//    < Tap Info button on the Saved Report View screen
//    > User should see Info Dialog about the report:
//    - Name: 02. Sales Mix by Demographic Report
//    - Description: Sample HTML5 Spider Line chart from OLAP source. Created from an Ad Hoc View.
//    - URI: /reports/02. Sales Mix by Demographic Report.pdf/report.pdf
//    - Type: Content Resource
//    - Version: 1
//    - Creation Date: appropriate date
//    - Modified Date: appropriate date
//    - Format: pdf
- (void)testThatDialogHasNeededFieldsForPDFfile
{
    [self createAndOpenTestSavedItemInPDFFormat];
    [self showInfoPageTestSavedItemFromViewer];
    
    [self verifyThatInfoPageHasNeededFieldsForPDFFile];

    [self closeInfoPageTestSavedItemFromViewer];
    [self closeAndDeleteTestSavedItem];
}

//Favorite button
//    < Open the Left Panel
//    < Tap on the Saved Items button
//    < Open the saved report
//    < Tap Info button
//    < Add item to favorites
//    < Remove item from favorites
//    > Star should be filled after adding the item to favorites
//    > Star should be empty after removing the item from favorites
- (void)testThatFavoriteButtonWorkCorrectly
{
    [self createAndOpenTestSavedItemInHTMLFormat];
    [self showInfoPageTestSavedItemFromViewer];
    
    [self markSavedAsFavoriteFromInfoPage];
    [self unmarkSavedAsFavoriteFromInfoPage];

    [self closeInfoPageTestSavedItemFromViewer];
    [self closeAndDeleteTestSavedItem];
}

#pragma mark - Helpers

- (void)createAndOpenTestSavedItemInHTMLFormat
{
    [self givenThatSavedItemsEmpty];
    [self saveTestReportInHTMLFormat];

    [self openTestSavedItemInHTMLFormat];
}

- (void)createAndOpenTestSavedItemInPDFFormat
{
    [self givenThatSavedItemsEmpty];
    [self saveTestReportInPDFFormat];

    [self openTestSavedItemInPDFFormat];
}

- (void)closeAndDeleteTestSavedItem
{
    [self closeTestSavedItem];
    
    [self deleteTestReportInHTMLFormat];
}

#pragma mark - Verifying

- (void)verifyThatInfoPageOnScreen
{
    [self verifyInfoPageOnScreenForPageWithAccessibilityId:@"JMSavedItemsInfoViewControllerAccessibilityId"]; 
}

- (void)verifyThatInfoPageHasCancelButton
{
    XCUIElement *navBar = [self findNavigationBarWithLabel:nil];
    XCUIElement *cancelButton = [self waitButtonWithAccessibilityId:@"Cancel"
                                                      parentElement:navBar
                                                            timeout:kUITestsBaseTimeout];
    if (!cancelButton) {
        XCTFail(@"Cancel button should be on navigation bar");
    }
}

- (void)verifyThatInfoPageHasCorrectTitle
{
    [self waitNavigationBarWithLabel:kTestReportName
                             timeout:kUITestsBaseTimeout];
}

- (void)verifyThatInfoPageHasNeededFieldsForHTMLFile
{
    [self verifyCommonFieldsOnInfoPage];
    
    XCUIElement *infoPageElement = self.application.otherElements[@"JMSavedItemsInfoViewControllerAccessibilityId"];
    XCUIElement *formatLabel = infoPageElement.staticTexts[@"Format"];
    if (!formatLabel.exists) {
        XCTFail(@"'Format' Label isn't visible.");
    } else {
        XCUIElement *formatValue = infoPageElement.staticTexts[@"html"];
        if (!formatValue.exists) {
            XCTFail(@"'Format' is not correct (%@).", formatValue);
        }
    }
}

- (void)verifyThatInfoPageHasNeededFieldsForPDFFile
{
    [self verifyCommonFieldsOnInfoPage];
    
    XCUIElement *infoPageElement = self.application.otherElements[@"JMSavedItemsInfoViewControllerAccessibilityId"];
    XCUIElement *formatLabel = infoPageElement.staticTexts[@"Format"];
    if (!formatLabel.exists) {
        XCTFail(@"'Format' Label isn't visible.");
    } else {
        XCUIElement *formatValue = infoPageElement.staticTexts[@"pdf"];
        if (!formatValue.exists) {
            XCTFail(@"'Format' is not correct (%@).", formatValue);
        }
    }
}

- (void)verifyCommonFieldsOnInfoPage
{
    XCUIElement *infoPageElement = self.application.otherElements[@"JMSavedItemsInfoViewControllerAccessibilityId"];
    
    XCUIElement *nameLabel = infoPageElement.staticTexts[@"Name"];
    if (!nameLabel.exists) {
        XCTFail(@"Name Label isn't visible.");
    }
    
    XCUIElement *descriptionLabel = infoPageElement.staticTexts[@"Description"];
    if (!descriptionLabel.exists) {
        XCTFail(@"Description Label isn't visible.");
    }
    
    XCUIElement *uriLabel = infoPageElement.staticTexts[@"URI"];
    if (!uriLabel.exists) {
        XCTFail(@"URI Label isn't visible.");
    }
    
    XCUIElement *typeLabel = infoPageElement.staticTexts[@"Type"];
    if (!typeLabel.exists) {
        XCTFail(@"Type Label isn't visible.");
    } else {
        XCUIElement *typeValue = infoPageElement.staticTexts[@"Content Resource"];
        if (!typeValue.exists) {
            XCTFail(@"Type has incorrect value (%@)", typeValue);
        }
    }
    
    XCUIElement *versionLabel = infoPageElement.staticTexts[@"Version"];
    if (!versionLabel.exists) {
        XCTFail(@"Version Label isn't visible.");
    }
    
    XCUIElement *creatingDateLabel = infoPageElement.staticTexts[@"Creation Date"];
    if (!creatingDateLabel.exists) {
        XCTFail(@"'Creation Date' Label isn't visible.");
    }
    
    XCUIElement *modifiedDateLabel = infoPageElement.staticTexts[@"Modified Date"];
    if (!modifiedDateLabel.exists) {
        XCTFail(@"'Modified Date' Label isn't visible.");
    }
}

@end
