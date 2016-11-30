//
//  JMFavoriteInfoPageUITests.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 2/19/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMFavoriteInfoPageUITests.h"
#import "JMBaseUITestCase+Favorites.h"
#import "JMBaseUITestCase+SideMenu.h"
#import "JMBaseUITestCase+InfoPage.h"
#import "JMBaseUITestCase+Report.h"
#import "JMBaseUITestCase+Dashboard.h"
#import "JMBaseUITestCase+Section.h"

@implementation JMFavoriteInfoPageUITests

//    Info Screen from Favorite Section
//    - Preconditions:
//      - Mark as favorite test report
//      - Mark as favorite test dashboard
//      - Mark as favorite test folder
//      - Mark as favorite test html-file
//      - Mark as favorite test pdf-file
//      - Mark as favorite test xls-file
//      - Mark as favorite test content resource
//      - Open the Left Panel
//      - Tap on the Favorites button
//    - Steps:
//      - Tap Info button on the report/dashboard/folder/html-file/pdf-file/xls-file/content resource
//    - Results:
//      - User should see Info screen about the report/dashboard/folder/html-file/pdf-file/xls-file/content resource
//    - After:
//      - Unmark from favorite test report
//      - Unmark from favorite test dashboard
//      - Unmark from favorite test folder
//      - Unmark from favorite test html-file
//      - Unmark from favorite test pdf-file
//      - Unmark from favorite test xls-file
//      - Unmark from favorite test content resource
- (void)testViewingInfoScreenFromFavoritesScreenForReport
{
    [self givenThatFavoritesSectionIsEmpty];

    [self selectFilterBy:@"Reports"
      inSectionWithTitle:@"Library"];
    [self markTestReportAsFavoriteFromSectionWithName:@"Library"];
    [self openFavoritesSection];

    [self openInfoPageForTestReportFromSectionWithName:@"Favorites"];
    [self closeInfoPageForTestReport];

    [self unmarkTestReportFromFavoriteFromSectionWithName:@"Favorites"];
}

- (void)testViewingInfoScreenFromFavoritesScreenForDashboard
{
    [self givenThatFavoritesSectionIsEmpty];

    [self selectFilterBy:@"Dashboards"
      inSectionWithTitle:@"Library"];
    [self markTestDashboardAsFavoriteFromSectionWithName:@"Library"];
    [self openFavoritesSection];

    [self openInfoPageForTestDashboardFromSectionWithName:@"Favorites"];
    [self closeInfoPageForTestDashboard];

    [self unmarkTestDashboardFromFavoriteFromSectionWithName:@"Favorites"];
}

//    Back button from Info Screen
//    - Preconditions:
//      - Mark as favorite test report
//      - Mark as favorite test dashboard
//      - Mark as favorite test folder
//      - Mark as favorite test html-file
//      - Mark as favorite test pdf-file
//      - Mark as favorite test xls-file
//      - Mark as favorite test content resource
//      - Open the Left Panel
//      - Tap on the Favorites button
//    - Steps:
//      - Tap Info button on the report/dashboard/folder/html-file/pdf-file/xls-file/content resource
//      - Tap ‘back’ button
//    - Results:
//      - Favorite screen should appear
//    - After:
//      - Unmark from favorite test report
//      - Unmark from favorite test dashboard
//      - Unmark from favorite test folder
//      - Unmark from favorite test html-file
//      - Unmark from favorite test pdf-file
//      - Unmark from favorite test xls-file
//      - Unmark from favorite test content resource
- (void)testThatBackButtonAtReportInfoScreenWorkCorrectly
{
    [self givenThatFavoritesSectionIsEmpty];
    
    [self selectFilterBy:@"Reports"
      inSectionWithTitle:@"Library"];
    [self markTestReportAsFavoriteFromSectionWithName:@"Library"];
    [self openFavoritesSection];
    
    [self openInfoPageForTestReportFromSectionWithName:@"Favorites"];
    [self verifyThatInfoPageForTestReportHasBackButton];
    [self closeInfoPageForTestReport];
    
    [self unmarkTestReportFromFavoriteFromSectionWithName:@"Favorites"];
}

- (void)testThatBackButtonAtDashboardInfoScreenWorkCorrectly
{
    [self givenThatFavoritesSectionIsEmpty];
    
    [self selectFilterBy:@"Dashboards"
      inSectionWithTitle:@"Library"];
    [self markTestDashboardAsFavoriteFromSectionWithName:@"Library"];
    [self openFavoritesSection];
    
    [self openInfoPageForTestDashboardFromSectionWithName:@"Favorites"];
    [self verifyThatInfoPageForTestDashboardHasBackButton];
    [self closeInfoPageForTestDashboard];
    
    [self unmarkTestDashboardFromFavoriteFromSectionWithName:@"Favorites"];
}
  
//    Title like name of the item
//    - Preconditions:
//      - Mark as favorite test report
//      - Mark as favorite test dashboard
//      - Mark as favorite test folder
//      - Mark as favorite test html-file
//      - Mark as favorite test pdf-file
//      - Mark as favorite test xls-file
//      - Mark as favorite test content resource
//      - Open the Left Panel
//      - Tap on the Favorites button
//    - Steps:
//      - Tap Info button on the report/dashboard/folder/html-file/pdf-file/xls-file/content resource
//    - Results:
//      - User should see title like name of them
//    - After:
//      - Unmark from favorite test report
//      - Unmark from favorite test dashboard
//      - Unmark from favorite test folder
//      - Unmark from favorite test html-file
//      - Unmark from favorite test pdf-file
//      - Unmark from favorite test xls-file
//      - Unmark from favorite test content resource
- (void)testThatInfoScreenForTestReportHasCorrectTitle
{
    [self givenThatFavoritesSectionIsEmpty];
    
    [self selectFilterBy:@"Reports"
      inSectionWithTitle:@"Library"];
    [self markTestReportAsFavoriteFromSectionWithName:@"Library"];
    [self openFavoritesSection];
    
    [self openInfoPageForTestReportFromSectionWithName:@"Favorites"];
    [self verifyThatInfoPageForTestReportHasCorrectTitle];
    [self closeInfoPageForTestReport];
    
    [self unmarkTestReportFromFavoriteFromSectionWithName:@"Favorites"];
}

- (void)testThatInfoScreenForTestDashboardHasCorrectTitle
{
    [self givenThatFavoritesSectionIsEmpty];
    
    [self selectFilterBy:@"Dashboards"
      inSectionWithTitle:@"Library"];
    [self markTestDashboardAsFavoriteFromSectionWithName:@"Library"];
    [self openFavoritesSection];
    
    [self openInfoPageForTestDashboardFromSectionWithName:@"Favorites"];
    [self verifyThatInfoPageForTestDashboardHasCorrectTitle];
    [self closeInfoPageForTestDashboard];
    
    [self unmarkTestDashboardFromFavoriteFromSectionWithName:@"Favorites"];
}

//    Info about test folder
//    - Preconditions:
//      - Mark as favorite test folder
//      - Open the Left Panel
//      - Tap on the Favorites button
//    - Steps:
//      - Tap Info Button on test folder
//    - Results:
//      - User should see info about the folder
//          - Name: Samples
//          - Description: Samples
//          - URI: /public/Samples
//          - Type: Folder
//          - Version: ‘current version’
//          - Creation Date: appropriate date
//          - Modified Date: appropriate date
//    - After:
//      - Unmark from favorite test folder
- (void)testThatInfoScreenForFolderContainsCorrectData
{
    
}

//    Info about test report
//    - Preconditions:
//      - Mark as favorite test report
//      - Open the Left Panel
//      - Tap on the Favorites button
//    - Steps:
//      - Tap Info Button on test report
//    - Results:
//      - User should see info about test report
//          - Name: Samples
//          - Description: Samples
//          - URI: /public/Samples
//          - Type: Report
//          - Version: ‘current version’
//          - Creation Date: appropriate date
//          - Modified Date: appropriate date
//    - After:
//      - Unmark from favorite test report
- (void)testThatInfoScreenForReportContainsCorrectData
{
    [self givenThatFavoritesSectionIsEmpty];
    
    [self selectFilterBy:@"Reports"
      inSectionWithTitle:@"Library"];
    [self markTestReportAsFavoriteFromSectionWithName:@"Library"];
    [self openFavoritesSection];
    
    [self openInfoPageForTestReportFromSectionWithName:@"Favorites"];
    [self verifyThatInfoPageForTestReportContainsCorrectData];
    [self closeInfoPageForTestReport];
    
    [self unmarkTestReportFromFavoriteFromSectionWithName:@"Favorites"];
}

//    Info about test dashboard
//    - Preconditions:
//      - Mark as favorite test dashboard
//      - Open the Left Panel
//      - Tap on the Favorites button
//    - Steps:
//      - Tap Info Button on test dashboard
//    - Results:
//      - User should see info about test dashboard
//          - Name: Samples
//          - Description: Samples
//          - URI: /public/Samples
//          - Type: Dashboard
//          - Version: ‘current version’
//          - Creation Date: appropriate date
//          - Modified Date: appropriate date
//    - After:
//      - Unmark from favorite test dashboard
- (void)testThatInfoScreenForDashboardContainsCorrectData
{
    [self givenThatFavoritesSectionIsEmpty];
    
    [self selectFilterBy:@"Dashboards"
      inSectionWithTitle:@"Library"];
    [self markTestDashboardAsFavoriteFromSectionWithName:@"Library"];
    [self openFavoritesSection];
    
    [self openInfoPageForTestDashboardFromSectionWithName:@"Favorites"];
    [self verifyThatInfoPageForTestDashboardContainsCorrectData];
    [self closeInfoPageForTestDashboard];
    
    [self unmarkTestDashboardFromFavoriteFromSectionWithName:@"Favorites"];
}

//    Info about test html-file
//    - Preconditions:
//      - Mark as favorite test html-file
//      - Open the Left Panel
//      - Tap on the Favorites button
//    - Steps:
//      - Tap Info Button on test html-file
//    - Results:
//      - User should see info about test html-file
//          - Name: Samples
//          - Description: Samples
//          - URI: /public/Samples
//          - Type: Content Resource
//          - Version: ‘current version’
//          - Creation Date: appropriate date
//          - Modified Date: appropriate date
//    - After:
//      - Unmark from favorite test html-file
- (void)testThatInfoScreenForHTMLFileContainsCorrectData
{
    
}

//    Info about test pdf-file
//    - Preconditions:
//      - Mark as favorite test pdf-file
//      - Open the Left Panel
//      - Tap on the Favorites button
//    - Steps:
//      - Tap Info Button on test pdf-file
//    - Results:
//      - User should see info about test pdf-file
//          - Name: Samples
//          - Description: Samples
//          - URI: /public/Samples
//          - Type: Content Resource
//          - Version: ‘current version’
//          - Creation Date: appropriate date
//          - Modified Date: appropriate date
//    - After:
//      - Unmark from favorite test pdf-file
- (void)testThatInfoScreenForPDFFileContainsCorrectData
{
    
}

//    Info about test xls-file
//    - Preconditions:
//      - Mark as favorite test xls-file
//      - Open the Left Panel
//      - Tap on the Favorites button
//    - Steps:
//      - Tap Info Button on test xls-file
//    - Results:
//      - User should see info about test xls-file
//          - Name: Samples
//          - Description: Samples
//          - URI: /public/Samples
//          - Type: Content Resource
//          - Version: ‘current version’
//          - Creation Date: appropriate date
//          - Modified Date: appropriate date
//    - After:
//      - Unmark from favorite test xls-file
- (void)testThatInfoScreenForXLSFileContainsCorrectData
{
    
}

//    Info about test image file
//    - Preconditions:
//      - Mark as favorite test image file
//      - Open the Left Panel
//      - Tap on the Favorites button
//    - Steps:
//      - Tap Info Button on test image file
//    - Results:
//      - User should see info about test image file
//          - Name: Samples
//          - Description: Samples
//          - URI: /public/Samples
//          - Type: Content Resource
//          - Version: ‘current version’
//          - Creation Date: appropriate date
//          - Modified Date: appropriate date
//    - After:
//      - Unmark from favorite test image file
- (void)testThatInfoScreenForImageFileContainsCorrectData
{
    
}

//    Info about test other files
//    - Preconditions:
//      - Mark as favorite test other file (/public/samples/resources/extras)
//      - Open the Left Panel
//      - Tap on the Favorites button
//    - Steps:
//      - Tap Info Button on test other file
//    - Results:
//      - User should see info about test other file
//          - Name: Samples
//          - Description: Samples
//          - URI: /public/Samples
//          - Type: Content Resource
//          - Version: ‘current version’
//          - Creation Date: appropriate date
//          - Modified Date: appropriate date
//    - After:
//      - Unmark from favorite test other file
- (void)testThatInfoScreenForOtherFilesContainsCorrectData
{
    
}

//    Favorite button
//    - Preconditions:
//      - Mark as favorite test report
//      - Mark as favorite test dashboard
//      - Mark as favorite test folder
//      - Mark as favorite test html-file
//      - Mark as favorite test pdf-file
//      - Mark as favorite test xls-file
//      - Mark as favorite test content resource
//      - Open the Left Panel
//      - Tap on the Favorites button
//    - Steps:
//      - Tap Info button on the report/dashboard/folder/html-file/pdf-file/xls-file/folder/content resource
//      - Remove item from favorite
//      - Add item to favorite
//    - Results:
//      - Star should be empty after removing the item from favorites
//      - Star should be filled after adding the item to favorites
//    - After:
//      - Unmark from favorite test report
//      - Unmark from favorite test dashboard
//      - Unmark from favorite test folder
//      - Unmark from favorite test html-file
//      - Unmark from favorite test pdf-file
//      - Unmark from favorite test xls-file
//      - Unmark from favorite test content resource
- (void)testThatFavoriteButtonOnInfoScreenForTestReportWorkCorrectly
{
    [self givenThatFavoritesSectionIsEmpty];
    
    [self selectFilterBy:@"Reports"
      inSectionWithTitle:@"Library"];
    [self markTestReportAsFavoriteFromSectionWithName:@"Library"];
    [self openFavoritesSection];
    
    [self openInfoPageForTestReportFromSectionWithName:@"Favorites"];
    [self unmarkFromFavoritesFromMenuActions];
    [self markAsFavoriteFromMenuActions];
    [self closeInfoPageForTestReport];
    
    [self unmarkTestReportFromFavoriteFromSectionWithName:@"Favorites"];
}

- (void)testThatFavoriteButtonOnInfoScreenForTestDashboardWorkCorrectly
{
    [self givenThatFavoritesSectionIsEmpty];
    
    [self selectFilterBy:@"Dashboards"
      inSectionWithTitle:@"Library"];
    [self markTestDashboardAsFavoriteFromSectionWithName:@"Library"];
    [self openFavoritesSection];
    
    [self openInfoPageForTestDashboardFromSectionWithName:@"Favorites"];
    [self unmarkFromFavoritesFromMenuActions];
    [self markAsFavoriteFromMenuActions];
    [self closeInfoPageForTestDashboard];
    
    [self unmarkTestDashboardFromFavoriteFromSectionWithName:@"Favorites"];
}

//    Run button
//    - Preconditions:
//      - Mark as favorite test report
//      - Mark as favorite test dashboard
//      - Mark as favorite test folder
//      - Mark as favorite test html-file
//      - Mark as favorite test pdf-file
//      - Mark as favorite test xls-file
//      - Mark as favorite test content resource
//      - Open the Left Panel
//      - Tap on the Favorites button
//    - Steps:
//      - Tap Info button on the report/dashboard/folder/html-file/pdf-file/xls-file/folder/content resource
//      - Tap Run button
//    - Results:
//      - User should see the report/dashboard/folder/html-file/pdf-file/xls-file/folder/content resource
//    - After:
//      - Unmark from favorite test report
//      - Unmark from favorite test dashboard
//      - Unmark from favorite test folder
//      - Unmark from favorite test html-file
//      - Unmark from favorite test pdf-file
//      - Unmark from favorite test xls-file
//      - Unmark from favorite test content resource

- (void)testThatRunButtonOnInfoScreenForTestReportWorkCorrectly
{
    [self givenThatFavoritesSectionIsEmpty];
    
    [self selectFilterBy:@"Reports"
      inSectionWithTitle:@"Library"];
    [self markTestReportAsFavoriteFromSectionWithName:@"Library"];
    [self openFavoritesSection];
    
    [self openInfoPageForTestReportFromSectionWithName:@"Favorites"];
    [self openTestReportFromInfoPage];
    [self closeInfoPageForTestReport];
    
    [self unmarkTestReportFromFavoriteFromSectionWithName:@"Favorites"];
}

- (void)testThatRunButtonOnInfoScreenForTestDashboardWorkCorrectly
{
    [self givenThatFavoritesSectionIsEmpty];
    
    [self selectFilterBy:@"Dashboards"
      inSectionWithTitle:@"Library"];
    [self markTestDashboardAsFavoriteFromSectionWithName:@"Library"];
    [self openFavoritesSection];
    
    [self openInfoPageForTestDashboardFromSectionWithName:@"Favorites"];
    [self openTestDashboardFromInfoPage];
    [self closeInfoPageForTestDashboard];
    
    [self unmarkTestDashboardFromFavoriteFromSectionWithName:@"Favorites"];
}

@end
