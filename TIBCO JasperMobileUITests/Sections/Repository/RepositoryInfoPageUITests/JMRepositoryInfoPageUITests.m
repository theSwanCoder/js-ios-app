/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.6
 */

#import "JMRepositoryInfoPageUITests.h"
#import "JMBaseUITestCase+SideMenu.h"
#import "JMBaseUITestCase+Report.h"
#import "JMBaseUITestCase+InfoPage.h"
#import "JMBaseUITestCase+Favorites.h"
#import "JMBaseUITestCase+Dashboard.h"

@implementation JMRepositoryInfoPageUITests

#pragma mark - Tests
//    User should see Info screen
//    - Preconditions:
//      - Open the Left Panel
//      - Tap on the Repository button
//    - Steps:
//      - Tap Info button on the report/dashboard/folder and other files (pdf/xls/html etc)
//    - Results:
//      - User should see Info screen about the report/dashboard/folder and other files
//    - After:
- (void)testThatUserCanSeeInfoScreenTestReport
{
    [self openInfoPageForTestReportFromSectionWithName:JMLocalizedString(@"menuitem_repository_label")];
    [self closeInfoPageForTestReport];
}

- (void)testThatUserCanSeeInfoScreenTestDashboard
{
    [self openInfoPageForTestDashboardFromSectionWithName:JMLocalizedString(@"menuitem_repository_label")];
    [self closeInfoPageForTestDashboard];
}

- (void)testThatUserCanSeeInfoScreenTestFolder
{
    [self openInfoPageForTestFolderFromSectionWithName:JMLocalizedString(@"menuitem_repository_label")];
    [self closeInfoPageForTestFolder];
}

//  Back button like folder name where is the resource
//    - Preconditions:
//      - Open the Left Panel
//      - Tap on the Repository button
//    - Steps:
//      - Tap Info button on the report/dashboard/folder and other files (pdf/xls/html etc)
//      - Tap back button
//    - Results:
//      - Repository screen should appear
//    - After:
- (void)testThatInfoScreenHasCorrectTitleOnBackButton
{
    [self openInfoPageForTestReportFromSectionWithName:JMLocalizedString(@"menuitem_repository_label")];
    [self verifyThatInfoPageForTestReportHasBackButton];
    [self closeInfoPageForTestReport];
}

//  Title like name of item
//    - Preconditions:
//      - Open the Left Panel
//      - Tap on the Repository button
//    - Steps:
//      - Tap Info button on the report/dashboard/folder and other files (pdf/xls/html etc)
//    - Results:
//      - User should see title like name of item
//    - After:
- (void)testThatInfoScreenHasCorrectTitle
{
    [self openInfoPageForTestReportFromSectionWithName:JMLocalizedString(@"menuitem_repository_label")];
    [self verifyThatInfoPageForTestReportHasCorrectTitle];
    [self closeInfoPageForTestReport];
}

//  Info about the report
//    - Preconditions:
//      - Open the Left Panel
//      - Tap on the Repository button
//    - Steps:
//      - Search “02. Sales Mix by Demographic Report”
//      - Tap Info button on “02. Sales Mix by Demographic Report”
//    - Results:
//      - User should see info about the report
//          - Name: “02. Sales Mix by Demographic Report”
//          - Description: “Sample HTML5 Spider Line chart from OLAP source. Created from an Ad Hoc View.”
//          - URI: “/public/Samples/Reports/02._Sales_Mix_by_Demographic_Report”
//          - Type: Report
//          - Version: appropriate version
//          - Creation Date: appropriate date
//          - Modified Date: appropriate date
//    - After:
- (void)testThatInfoScreenContainsCorrectInfoForTestReport
{
    [self openInfoPageForTestReportFromSectionWithName:JMLocalizedString(@"menuitem_repository_label")];
    [self verifyThatInfoPageForTestReportContainsCorrectData];
    [self closeInfoPageForTestReport];
}
    
//  Info about the dashboard
//    - Preconditions:
//      - Open the Left Panel
//      - Tap on the Repository button
//    - Steps:
//      - Search “1. Supermart Dashboard”
//      - Tap Info button on “1. Supermart Dashboard”
//    - Results:
//      - User should see info about the report
//          - Name: “1. Supermart Dashboard”
//          - Description: “Sample containing 5 Dashlets and Filter wiring. One Dashlet is a report with hyperlinks, the other Dashlets are defined as part of the Dashboard.”
//          - URI: “/public/Samples/Dashboards/1._Supermart_Dashboard”
//          - Type: Dashboard
//          - Version: appropriate version
//          - Creation Date: appropriate date
//          - Modified Date: appropriate date
//    - After:
- (void)testThatInfoScreenContainsCorrectInfoForTestDashboard
{
    [self openInfoPageForTestDashboardFromSectionWithName:JMLocalizedString(@"menuitem_repository_label")];
    [self verifyThatInfoPageForTestDashboardContainsCorrectData];
    [self closeInfoPageForTestDashboard];
}
    
//  Info about the folder
//    - Preconditions:
//      - Open the Left Panel
//      - Tap on the Repository button
//    - Steps:
//      - Search “Samples”
//      - Tap Info button on “Samples”
//    - Results:
//      - User should see info about the report
//          - Name: “Samples”
//          - Description: “Samples”
//          - URI: “/public/Samples”
//          - Type: Folder
//          - Version: appropriate version
//          - Creation Date: appropriate date
//          - Modified Date: appropriate date
//    - After:
- (void)testThatInfoScreenContainsCorrectInfoForTestFolder
{
    [self openInfoPageForTestFolderFromSectionWithName:JMLocalizedString(@"menuitem_repository_label")];
    [self verifyThatInfoPageForTestFolderContainsCorrectData];
    [self closeInfoPageForTestFolder];
}
    
//  Favorite button
//    - Preconditions:
//      - Open the Left Panel
//      - Tap on the Repository button
//    - Steps:
//      - Tap Info button on the report/dashboard/folder
//      - Add the item to favorites
//      - Remove the item from favorites
//    - Results:
//      - Star should be filled after adding the item to favorites
//      - Star should be empty after removing the item from favorites
//    - After:
- (void)testThatTestReportCanBeMarkFavoriteFromInfoScreen
{
    [self openInfoPageForTestReportFromSectionWithName:JMLocalizedString(@"menuitem_repository_label")];

    [self markAsFavoriteFromMenuActions];
    [self unmarkFromFavoritesFromMenuActions];

    [self closeInfoPageForTestReport];
}

- (void)testThatTestDashboardCanBeMarkFavoriteFromInfoScreen
{
    [self openInfoPageForTestDashboardFromSectionWithName:JMLocalizedString(@"menuitem_repository_label")];

    [self markAsFavoriteFromMenuActions];
    [self unmarkFromFavoritesFromMenuActions];

    [self closeInfoPageForTestDashboard];
}
    
- (void)testThatTestFolderCanBeMarkFavoriteFromInfoScreen
{
    [self openInfoPageForTestFolderFromSectionWithName:JMLocalizedString(@"menuitem_repository_label")];

    [self markAsFavoriteFromMenuActions];
    [self unmarkFromFavoritesFromMenuActions];

    [self closeInfoPageForTestFolder];
}
    
//  Run button
//    - Preconditions:
//      - Open the Left Panel
//      - Tap on the Repository button
//    - Steps:
//      - Tap Info button on the report/dashboard
//      - Tap Run button
//    - Results:
//      - User should see report/dashboard on Report/Dashboard View screen
//    - After:
- (void)testThatTestReportCanBeRunFromInfoScreen
{
    [self openInfoPageForTestReportFromSectionWithName:JMLocalizedString(@"menuitem_repository_label")];
    
    [self openTestReportFromInfoPage];
    
    [self closeInfoPageForTestReport];
}

- (void)testThatTestDashboardCanBeRunFromInfoScreen
{
    [self openInfoPageForTestDashboardFromSectionWithName:JMLocalizedString(@"menuitem_repository_label")];

    [self openTestDashboardFromInfoPage];

    [self closeInfoPageForTestDashboard];
}

@end
