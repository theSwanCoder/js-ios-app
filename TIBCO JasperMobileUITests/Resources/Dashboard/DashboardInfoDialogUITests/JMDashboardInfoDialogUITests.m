/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.6
 */

#import "JMDashboardInfoDialogUITests.h"
#import "JMBaseUITestCase+Dashboard.h"
#import "JMBaseUITestCase+Helpers.h"
#import "JMBaseUITestCase+InfoPage.h"
#import "JMBaseUITestCase+Favorites.h"

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
    [self openTestDashboardPage];

    [self openInfoPageFromMenuActions];
    [self verifyInfoPageContainsCorrectInfo];
    [self closeInfoPageFromMenuActions];

    [self closeTestDashboardPage];
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
    [self openTestDashboardPage];

    [self openInfoPageFromMenuActions];
    [self closeInfoPageFromMenuActions];

    [self closeTestDashboardPage];
}

//Title on the Info Dialog like title of the dashboard
//    < Open the Left Panel
//    < Tap on the Library button
//    < Open the dashboard
//    < Tap Info button
//    > User should see title on the Info Dialog like title of the dashboard
- (void)testThatDialogHasCorrectTitle
{
    [self openTestDashboardPage];

    [self openInfoPageFromMenuActions];
    [self verifyInfoPageHasCorrectTitle];
    [self closeInfoPageFromMenuActions];

    [self closeTestDashboardPage];
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
    [self openTestDashboardPage];

    [self openInfoPageFromMenuActions];
    [self markAsFavoriteFromNavigationBar:nil];
    [self unmarkFromFavoritesFromNavigationBar:nil];
    [self closeInfoPageFromMenuActions];

    [self closeTestDashboardPage];
}

#pragma mark - Verifying

- (void)verifyInfoPageContainsCorrectInfo
{
    XCUIElement *infoPage = self.application.otherElements[@"JMDashboardInfoViewControllerAccessibilityId"];
    [self waitElementMatchingType:XCUIElementTypeStaticText
                             text:JMLocalizedString(@"resource_label_title")
                    parentElement:infoPage
                          timeout:kUITestsBaseTimeout];
    [self waitElementMatchingType:XCUIElementTypeStaticText
                             text:JMLocalizedString(@"resource_description_title")
                    parentElement:infoPage
                          timeout:kUITestsBaseTimeout];
    [self waitElementMatchingType:XCUIElementTypeStaticText
                             text:JMLocalizedString(@"resource_uri_title")
                    parentElement:infoPage
                          timeout:kUITestsBaseTimeout];
    [self waitElementMatchingType:XCUIElementTypeStaticText
                             text:JMLocalizedString(@"resource_type_title")
                    parentElement:infoPage
                          timeout:kUITestsBaseTimeout];
    [self waitElementMatchingType:XCUIElementTypeStaticText
                             text:JMLocalizedString(@"resource_version_title")
                    parentElement:infoPage
                          timeout:kUITestsBaseTimeout];
    [self waitElementMatchingType:XCUIElementTypeStaticText
                             text:JMLocalizedString(@"resource_creationDate_title")
                    parentElement:infoPage
                          timeout:kUITestsBaseTimeout];
    [self waitElementMatchingType:XCUIElementTypeStaticText
                             text:JMLocalizedString(@"resource_modifiedDate_title")
                    parentElement:infoPage
                          timeout:kUITestsBaseTimeout];
}

- (void)verifyInfoPageHasCorrectTitle
{
    [self waitNavigationBarWithLabel:kTestDashboardName
                             timeout:kUITestsBaseTimeout];
}

@end
