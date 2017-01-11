//
//  JMSavedItemInfoDialogUITests.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 2/19/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMSavedItemInfoDialogUITests.h"
#import "JMBaseUITestCase+Helpers.h"
#import "JMBaseUITestCase+SavedItems.h"
#import "JMBaseUITestCase+Report.h"
#import "JMBaseUITestCase+InfoPage.h"
#import "JMBaseUITestCase+Buttons.h"
#import "JMBaseUITestCase+SideMenu.h"

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
    [self openInfoPageTestSavedItemFromViewer];
    
    [self verifyThatInfoPageOnScreen];

    [self closeInfoPageTestSavedItemFromViewer];
    [self closeAndDeleteTestSavedItemInHTMLFormat];
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
    [self openInfoPageTestSavedItemFromViewer];
    
    [self verifyThatInfoPageHasCancelButton];

    [self closeInfoPageTestSavedItemFromViewer];
    [self closeAndDeleteTestSavedItemInHTMLFormat];
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
    [self openInfoPageTestSavedItemFromViewer];
    
    [self verifyThatInfoPageHasCorrectTitle];

    [self closeInfoPageTestSavedItemFromViewer];
    [self closeAndDeleteTestSavedItemInHTMLFormat];
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
    [self openInfoPageTestSavedItemFromViewer];
    
    [self verifyThatInfoPageHasNeededFieldsForHTMLFile];

    [self closeInfoPageTestSavedItemFromViewer];
    [self closeAndDeleteTestSavedItemInHTMLFormat];
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
    [self openInfoPageTestSavedItemFromViewer];
    
    [self verifyThatInfoPageHasNeededFieldsForPDFFile];

    [self closeInfoPageTestSavedItemFromViewer];
    [self closeAndDeleteTestSavedItemInPDFFormat];
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
    [self openInfoPageTestSavedItemFromViewer];
    
    [self markSavedAsFavoriteFromInfoPage];
    [self unmarkSavedAsFavoriteFromInfoPage];

    [self closeInfoPageTestSavedItemFromViewer];
    [self closeAndDeleteTestSavedItemInHTMLFormat];
}

#pragma mark - Helpers

- (void)createAndOpenTestSavedItemInHTMLFormat
{
    [self openSavedItemsSectionIfNeed];
    [self givenThatSavedItemsEmpty];
    [self saveTestReportInHTMLFormatNeedOpen:YES];
}

- (void)createAndOpenTestSavedItemInPDFFormat
{
    [self openSavedItemsSectionIfNeed];
    [self givenThatSavedItemsEmpty];
    [self saveTestReportInPDFFormatNeedOpen:YES];
}

- (void)closeAndDeleteTestSavedItemInHTMLFormat
{
    [self closeTestSavedItem];
    [self deleteTestReportInHTMLFormat];
}
    
- (void)closeAndDeleteTestSavedItemInPDFFormat
{
    [self closeTestSavedItem];
    [self deleteTestReportInPDFFormat];
}

#pragma mark - Verifying

- (void)verifyThatInfoPageOnScreen
{
    [self verifyThatSavedItemInfoPageOnScreen];
}

- (void)verifyThatInfoPageHasCancelButton
{
    [self verifyCancelButtonExistOnNavBarWithTitle:nil];
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
    XCUIElement *formatLabel = infoPageElement.staticTexts[JMLocalizedString(@"resource_format_title")];
    if (!formatLabel.exists) {
        XCTFail(@"'Format' Label isn't visible.");
    } else {
        XCUIElement *formatValue = infoPageElement.staticTexts[@"html"]; // We don't have translation for this string
        if (!formatValue.exists) {
            XCTFail(@"'Format' is not correct (%@).", formatValue);
        }
    }
}

- (void)verifyThatInfoPageHasNeededFieldsForPDFFile
{
    [self verifyCommonFieldsOnInfoPage];
    
    XCUIElement *infoPageElement = self.application.otherElements[@"JMSavedItemsInfoViewControllerAccessibilityId"];
    XCUIElement *formatLabel = infoPageElement.staticTexts[JMLocalizedString(@"resource_format_title")];
    if (!formatLabel.exists) {
        XCTFail(@"'Format' Label isn't visible.");
    } else {
        XCUIElement *formatValue = infoPageElement.staticTexts[@"pdf"]; // We don't have translation for this string
        if (!formatValue.exists) {
            XCTFail(@"'Format' is not correct (%@).", formatValue);
        }
    }
}

- (void)verifyCommonFieldsOnInfoPage
{
    XCUIElement *infoPageElement = self.application.otherElements[@"JMSavedItemsInfoViewControllerAccessibilityId"];
    
    XCUIElement *nameLabel = infoPageElement.staticTexts[JMLocalizedString(@"resource_label_title")];
    if (!nameLabel.exists) {
        XCTFail(@"Name Label isn't visible.");
    }
    
    XCUIElement *descriptionLabel = infoPageElement.staticTexts[JMLocalizedString(@"resource_description_title")];
    if (!descriptionLabel.exists) {
        XCTFail(@"Description Label isn't visible.");
    }
    
    XCUIElement *uriLabel = infoPageElement.staticTexts[JMLocalizedString(@"resource_uri_title")];
    if (!uriLabel.exists) {
        XCTFail(@"URI Label isn't visible.");
    }
    
    XCUIElement *typeLabel = infoPageElement.staticTexts[JMLocalizedString(@"resource_type_title")];
    if (!typeLabel.exists) {
        XCTFail(@"Type Label isn't visible.");
    } else {
        XCUIElement *typeValue = infoPageElement.staticTexts[JMLocalizedString(@"resources_type_saved_reportUnit")];
        if (!typeValue.exists) {
            XCTFail(@"Type has incorrect value (%@)", typeValue);
        }
    }
    
    XCUIElement *versionLabel = infoPageElement.staticTexts[JMLocalizedString(@"resource_version_title")];
    if (!versionLabel.exists) {
        XCTFail(@"Version Label isn't visible.");
    }
    
    XCUIElement *creatingDateLabel = infoPageElement.staticTexts[JMLocalizedString(@"resource_creationDate_title")];
    if (!creatingDateLabel.exists) {
        XCTFail(@"'Creation Date' Label isn't visible.");
    }
    
    XCUIElement *modifiedDateLabel = infoPageElement.staticTexts[JMLocalizedString(@"resource_modifiedDate_title")];
    if (!modifiedDateLabel.exists) {
        XCTFail(@"'Modified Date' Label isn't visible.");
    }
}

@end
