//
//  JMSavedItemInfoDialogUITests.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 2/19/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMSavedItemInfoDialogUITests.h"

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
//    XCTFail(@"Not implemented tests");
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
//    XCTFail(@"Not implemented tests");
}

//Title like name of item
//    < Open the Left Panel
//    < Tap on the Saved Items button
//    < Open the saved report
//    < Tap Info button on the Saved Report View screen
//    > User should see title like name of item
- (void)testThatDialogHasCorrectTitle
{
//    XCTFail(@"Not implemented tests");
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
//    XCTFail(@"Not implemented tests");
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
//    XCTFail(@"Not implemented tests");
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
//    XCTFail(@"Not implemented tests");
}

@end
