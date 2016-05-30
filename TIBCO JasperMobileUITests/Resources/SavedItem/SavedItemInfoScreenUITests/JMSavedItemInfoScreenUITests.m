//
//  JMSavedItemInfoScreenUITests.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 2/19/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMSavedItemInfoScreenUITests.h"

@implementation JMSavedItemInfoScreenUITests

#pragma mark - Tests

//User should see Info screen
//    < Open the Left Panel
//    < Tap on the Saved Items button
//    < Tap Info button on the saved report
//    > User should see Info screen about the saved report
- (void)testThatUserCanSeeInfoScreen
{
//    XCTFail(@"Not implemented tests");
}

//Back button like "Saved Items"
//    < Open the Left Panel
//    < Tap on the Saved Items button
//    < Tap Info button on the saved report
//    < Tap back button
//    > Saved Items screen should appears
- (void)testThatBackButtonHasCorrectTitle
{
//    XCTFail(@"Not implemented tests");
}

//Title like name of item
//    < Open the Left Panel
//    < Tap on the Saved Items button
//    < Tap Info button on the saved report
//    > User should see title like name of item
- (void)testThatPageHasCorrectTitle
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
//    XCTFail(@"Not implemented tests");
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
//    XCTFail(@"Not implemented tests");
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
//    XCTFail(@"Not implemented tests");
}

//Run button
//    < Open the Left Panel
//    < Tap on the Saved Items button
//    < Tap Info button on the saved report
//    < Tap Run button
//    > User should see Saved Report View Screen
- (void)testThatRunButtonWorkCorrectly
{
//    XCTFail(@"Not implemented tests");
}

@end
