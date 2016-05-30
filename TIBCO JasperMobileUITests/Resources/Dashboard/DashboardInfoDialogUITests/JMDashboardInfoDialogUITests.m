//
//  JMDashboardInfoDialogUITests.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 2/19/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMDashboardInfoDialogUITests.h"

@implementation JMDashboardInfoDialogUITests

#pragma mark - Tests

//User should see Info Dialog about the dashboard
//    < Open the Left Panel
//    < Tap on the Library button
//    < Open "1. Supermart Dashboard"
//    < Tap Info button
//    > User should see Info Dialog about the dashboard:
//    - Name: 1. Supermart Dashboard
//    - Description: Sample containing 5 Dashlets and Filter wiring. One Dashlet is a report with hyperlinks, the other Dashlets are defined as part of the Dashboard.
//    - URI: /public/Samples/Dashboards/1._Supermart_Dashboard
//    - Type: Dashboard
//    - Version: 0
//    - Creation Date: appropriate date
//    - Modified Date: appropriate date
- (void)testThatUserCanSeeInfoDialog
{
//    XCTFail(@"Not implemented tests");
}

//Cancel button on Info dialog
//    < Open the Left Panel
//    < Tap on the Library button
//    < Open the dashboard
//    < Tap Info button
//    < Tap Cancel button on Info dialog
//    > Dashboard View screen should appears
- (void)testThatCnacelButtonWorkCorrectly
{
//    XCTFail(@"Not implemented tests");
}

//Title on the Info Dialog like title of the dashboard
//    < Open the Left Panel
//    < Tap on the Library button
//    < Open the dashboard
//    < Tap Info button
//    > User should see title on the Info Dialog like title of the dashboard
- (void)testThatDialogHasCorrectTitle
{
//    XCTFail(@"Not implemented tests");
}

//Favorite button
//    < Open the Left Panel
//    < Tap on the Library button
//    < Open the dashboard
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
