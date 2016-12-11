//
//  JMSavedItemInfoScreenUITests.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 2/19/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMSavedItemInfoScreenUITests.h"
#import "JMBaseUITestCase+SavedItems.h"
#import "JMBaseUITestCase+Helpers.h"
#import "JMBaseUITestCase+Report.h"
#import "JMBaseUITestCase+Buttons.h"
#import "JMBaseUITestCase+SideMenu.h"

@implementation JMSavedItemInfoScreenUITests

#pragma mark - Tests

//User should see Info screen
//    < Open the Left Panel
//    < Tap on the Saved Items button
//    < Tap Info button on the saved report
//    > User should see Info screen about the saved report
- (void)testThatUserCanSeeInfoScreen
{
    [self createTestSavedItemInHTMLFormatAndOpenInfoPage];

    [self verifyThatInfoPageOnScreen];

    [self closeInfoPageAndDeleteTestSavedItemInHTMLFormat];
}

//Back button like "Saved Items"
//    < Open the Left Panel
//    < Tap on the Saved Items button
//    < Tap Info button on the saved report
//    < Tap back button
//    > Saved Items screen should appears
- (void)testThatBackButtonHasCorrectTitle
{
    [self createTestSavedItemInHTMLFormatAndOpenInfoPage];
    
    [self verifyThatBackButtonOnInfoPageHasCorrectTitle];
    
    [self closeInfoPageAndDeleteTestSavedItemInHTMLFormat];
}

//Title like name of item
//    < Open the Left Panel
//    < Tap on the Saved Items button
//    < Tap Info button on the saved report
//    > User should see title like name of item
- (void)testThatPageHasCorrectTitle
{
    [self createTestSavedItemInHTMLFormatAndOpenInfoPage];
    
    [self verifyThatInfoPageHasCorrectTitle];
    
    [self closeInfoPageAndDeleteTestSavedItemInHTMLFormat];
}

//Info about the html-file
//    < Open the Left Panel
//    < Tap on the Library button
//    < Open "02. Sales Mix by Demographic Report"
//    < Save the report as html-file
//    < Open the Left Panel
//    < Tap on the Saved Items button
//    < Tap Info button on the html-file
//    > User should see Info Dialog about the report:
//    - Name: 02. Sales Mix by Demographic Report
//    - Description: Sample HTML5 Spider Line chart from OLAP source. Created from an Ad Hoc View.
//    - URI: /reports/02. Sales Mix by Demographic Report.html/report.html
//    - Type: Content Resource
//    - Version: 1
//    - Creation Date: appropriate date
//    - Modified Date: appropriate date
//    - Format: html
- (void)testThatPageHasCorrectFieldsForHTMLfile
{
    [self createTestSavedItemInHTMLFormatAndOpenInfoPage];

    [self verifyThatInfoPageHasNeededFieldsForHTMLFile];

    [self closeInfoPageAndDeleteTestSavedItemInHTMLFormat];
}

//Info about the pdf-file
//    < Open the Left Panel
//    < Tap on the Library button
//    < Open "02. Sales Mix by Demographic Report"
//    < Save the report as pdf-file
//    < Open the Left Panel
//    < Tap on the Saved Items button
//    < Tap Info button on the pdf-file
//    > User should see Info Dialog about the report:
//    - Name: 02. Sales Mix by Demographic Report
//    - Description: Sample HTML5 Spider Line chart from OLAP source. Created from an Ad Hoc View.
//    - URI: /reports/02. Sales Mix by Demographic Report.pdf/report.pdf
//    - Type: Content Resource
//    - Version: 1
//    - Creation Date: appropriate date
//    - Modified Date: appropriate date
//    - Format: pdf
- (void)testThatPageHasCorrectFieldsForPDFfile
{
    [self createTestSavedItemInPDFFormatAndOpenInfoPage];

    [self verifyThatInfoPageHasNeededFieldsForPDFFile];

    [self closeInfoPageAndDeleteTestSavedItemInPDFFormat];
}

//Favorite button
//    < Open the Left Panel
//    < Tap on the Saved Items button
//    < Tap Info button on the saved report
//    < Add item to favorites
//    < Remove item from favorites
//    > Star should be filled after adding the item to favorites
//    > Star should be empty after removing the item from favorites
- (void)testThatFavoriteButtonWorkCorrectly
{
    [self createTestSavedItemInHTMLFormatAndOpenInfoPage];

    [self markTestSavedItemAsFavoriteFromMenuOnInfoPage];
    [self unmarkTestSavedItemAsFavoriteFromMenuOnInfoPage];

    [self closeInfoPageAndDeleteTestSavedItemInHTMLFormat];
}

//Run button
//    < Open the Left Panel
//    < Tap on the Saved Items button
//    < Tap Info button on the saved report
//    < Tap Run button
//    > User should see Saved Report View Screen
- (void)testThatRunButtonWorkCorrectly
{
    [self createTestSavedItemInHTMLFormatAndOpenInfoPage];
    
    [self openTestSavedItemFromInfoPage];
    [self verifyThatTestSavedItemPageOnScreen];
    [self closeTestSavedItem];
    
    [self closeInfoPageAndDeleteTestSavedItemInHTMLFormat];
}

#pragma mark - Helpers

- (void)createTestSavedItemInHTMLFormatAndOpenInfoPage
{
    [self openSavedItemsSectionIfNeed];
    [self givenThatSavedItemsEmpty];
    [self saveTestReportInHTMLFormatNeedOpen:NO];
    [self openInfoPageTestSavedItemFromSavedItemsSection];
}

- (void)createTestSavedItemInPDFFormatAndOpenInfoPage
{
    [self openSavedItemsSectionIfNeed];
    [self givenThatSavedItemsEmpty];
    [self saveTestReportInPDFFormatNeedOpen:NO];
    [self openInfoPageTestSavedItemFromSavedItemsSection];
}

- (void)closeInfoPageAndDeleteTestSavedItemInHTMLFormat
{
    [self closeInfoPageTestSavedItemFromSavedItemsSection];

    [self deleteTestReportInHTMLFormat];
}
    
- (void)closeInfoPageAndDeleteTestSavedItemInPDFFormat
{
    [self closeInfoPageTestSavedItemFromSavedItemsSection];

    [self deleteTestReportInPDFFormat];
}

#pragma mark - Verifying

- (void)verifyThatInfoPageOnScreen
{
    [self verifyThatSavedItemInfoPageOnScreen];
}

- (void)verifyThatBackButtonOnInfoPageHasCorrectTitle
{
    [self verifyBackButtonExistWithAlternativeTitle:nil
                                  onNavBarWithTitle:nil];
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

- (void)verifyThatTestSavedItemPageOnScreen
{
    [self waitNavigationBarWithLabel:kTestReportName
                             timeout:kUITestsBaseTimeout];
}

@end
