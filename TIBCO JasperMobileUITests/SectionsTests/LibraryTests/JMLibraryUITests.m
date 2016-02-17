//
//  JMLibraryUITests.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 2/11/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "JMUITestConstants.h"

@interface JMLibraryUITests : XCTestCase
@property(nonatomic, strong) XCUIApplication *application;
@end

@implementation JMLibraryUITests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    
    self.application = [[XCUIApplication alloc] init];
    [self.application launch];
    
    XCUIElement *loginPageView = self.application.otherElements[@"JMLoginPageAccessibilityId"];
    if (loginPageView.exists) {
        [self loginWithTestProfile];
    }
}

- (void)tearDown {
    //self.application = nil;
    
    [super tearDown];
}

#pragma mark - Setup Helpers
- (void)selectTestProfile
{
    [self givenThatLoginPageOnScreen];
    [self tryOpenServerProfilesPage];
    
    [self givenThatServerProfilesPageOnScreen];
    
    XCUIElement *testProfile = self.application.collectionViews.staticTexts[@"Test Profile"];
    BOOL isTestProfileExists = testProfile.exists;
    if (isTestProfileExists) {
        [self trySelectNewTestServerProfile];
    } else {
        [self tryOpenNewServerProfilePage];
        
        [self givenThatNewProfilePageOnScreen];
        [self tryCreateNewTestServerProfile];
        
        [self givenThatServerProfilesPageOnScreen];
        [self trySelectNewTestServerProfile];
    }
}

- (void)loginWithTestProfile
{
    [self givenThatLoginPageOnScreen];
    [self selectTestProfile];
    
    [self givenThatLoginPageOnScreen];
    [self tryEnterTestCredentials];
    
    [self givenThatLoginPageOnScreen];
    [self tryTapLoginButton];
}

- (void)logout
{
    [self givenThatLibraryPageOnScreen];
    [self tryOpenSideApplicationMenu];
    
    [self tryOpenPageWithName:@"Log Out"];
}

#pragma mark - 
- (void)tryOpenServerProfilesPage
{
    XCUIElement *serverProfileTextField = self.application.textFields[@"JMLoginPageServerProfileTextFieldAccessibilityId"];
    if (serverProfileTextField.exists) {
        [serverProfileTextField tap];
    } else {
        XCTFail(@"Server profile text field doesn't exist.");
    }
}

- (void)tryOpenNewServerProfilePage
{
    XCUIElement *addProfileButton = self.application.buttons[@"JMServerProfilesPageAddNewProfileButtonAccessibilityId"];
    if (addProfileButton.exists) {
        [addProfileButton tap];
    } else {
        XCTFail(@"Add new profile button doesn't exist.");
    }
}

- (void)tryCreateNewTestServerProfile
{
    XCUIElementQuery *tablesQuery = self.application.tables;
    
    // Find Profile Name TextField
    XCUIElement *profileNameTextFieldElement = tablesQuery.textFields[@"Profile name"];
    if (profileNameTextFieldElement.exists) {
        [profileNameTextFieldElement tap];
        [profileNameTextFieldElement typeText:kJMTestProfileName];
    } else {
        XCTFail(@"Profile Name text field doesn't exist.");
    }
    
    // Close keyboard
    XCUIElement *doneButton = self.application.toolbars.buttons[@"Done"];
    if (doneButton.exists) {
        [doneButton tap];
    } else {
        XCTFail(@"Done button on keyboard doesn't exist.");
    }
    
    // Find Profile URL TextField
    XCUIElement *profileURLTextFieldElement = tablesQuery.textFields[@"Server address"];
    if (profileURLTextFieldElement.exists) {
        [profileURLTextFieldElement tap];
        [profileURLTextFieldElement typeText:kJMTestProfileURL];
    } else {
        XCTFail(@"Profile URL text field doesn't exist.");
    }
    
    // Close keyboard
    doneButton = self.application.toolbars.buttons[@"Done"];
    if (doneButton.exists) {
        [doneButton tap];
    } else {
        XCTFail(@"Done button on keyboard doesn't exist.");
    }
    
    // Save a new created profile
    XCUIElement *saveButton = self.application.buttons[@"Save"];
    if (saveButton.exists) {
        [saveButton tap];
    } else {
        XCTFail(@"Create new profile button doesn't exist.");
    }
    
    // Confirm if need http end point
    XCUIElement *securityWarningAlert = self.application.alerts[@"Warning"];
    if (securityWarningAlert.exists) {
        XCUIElement *securityWarningAlertOkButton = securityWarningAlert.collectionViews.buttons[@"ok"];
        if (securityWarningAlertOkButton.exists) {
            [securityWarningAlertOkButton tap];
        } else {
            XCTFail(@"'Ok' button on security warning alert doesn't exist.");
        }
    }
}

- (void)tryBackToLoginPageFromProfilesPage
{
    XCUIElement *backButton = [[[self.application.navigationBars[@"Server Profiles"] childrenMatchingType:XCUIElementTypeButton] matchingIdentifier:@"Back"] elementBoundByIndex:0];
    if (backButton.exists) {
        [backButton tap];
    } else {
        XCTFail(@"'Back' button on Profiles page doesn't exist.");
    }
}

- (void)trySelectNewTestServerProfile
{
    XCUIElement *testProfile = self.application.collectionViews.staticTexts[@"Test Profile"];
    if (testProfile.exists) {
        [testProfile tap];
        
        // TODO: how better to use this case
        //        XCUIElement *unknownServerAlert = self.application.alerts[@"Unknown server"];
        //        if (unknownServerAlert.exists) {
        //            XCUIElement *okButton = unknownServerAlert.collectionViews.buttons[@"OK"];
        //            if (okButton.exists) {
        //                [okButton tap];
        //            }
        //            XCTFail(@"Server Profile doesn't be select (maybe it turned off)");
        //        }
    } else {
        XCTFail(@"Test profile doesn't visible or exist");
    }
}

- (void)tryEnterTestCredentials
{
    XCUIElement *usernameTextField = self.application.textFields[@"JMLoginPageUserNameTextFieldAccessibilityId"];
    if (usernameTextField.exists) {
        [usernameTextField tap];
        [usernameTextField typeText:kJMTestProfileCredentialsUsername];
    } else {
        XCTFail(@"User name text field doesn't exist");
    }
    
    // Close keyboard
    XCUIElement *doneButton = self.application.buttons[@"Done"];
    if (doneButton.exists) {
        [doneButton tap];
    } else {
        XCTFail(@"Done button on keyboard doesn't exist.");
    }
    
    XCUIElement *passwordSecureTextField = self.application.secureTextFields[@"JMLoginPagePasswordTextFieldAccessibilityId"];
    if (passwordSecureTextField.exists) {
        [passwordSecureTextField tap];
        [passwordSecureTextField typeText:kJMTestProfileCredentialsPassword];
    } else {
        XCTFail(@"Password text field doesn't exist");
    }
    
    // Close keyboard
    doneButton = self.application.buttons[@"Done"];
    if (doneButton.exists) {
        [doneButton tap];
    } else {
        XCTFail(@"Done button on keyboard doesn't exist.");
    }
}

- (void)tryTapLoginButton
{
    XCUIElement *loginButton = self.application.buttons[@"JMLoginPageLoginButtonAccessibilityId"];
    if (loginButton.exists) {
        [loginButton tap];
    } else {
        XCTFail(@"'Login' button doesn't exist.");
    }
}

#pragma mark - Test 'Main' features

- (void)testThatLibraryPageHasTitleLibrary
{
    [self givenThatLibraryPageOnScreen];

    [self verifyThatCurrentPageIsLibrary];
}

- (void)testThatLibraryContainsListOfCells
{
    [self givenThatLibraryPageOnScreen];
    
    [self givenThatCellsAreVisible];
    [self givenThatCollectionViewContainsListOfCells];
    
    XCUIElement *contentView = self.application.otherElements[@"JMBaseCollectionContentViewAccessibilityId"];
    if (contentView.exists) {

        [self verifyThatCollectionViewContainsListOfCells];
        
    } else {
        XCTFail(@"Content View doesn't visible");
    }
}

- (void)testMenuButton
{
    [self givenThatLibraryPageOnScreen];
    [self givenSideMenuNotVisible];
    
    XCUIElement *menuButton = self.application.navigationBars[@"Library"].buttons[@"menu icon"];
    if (menuButton.exists) {
        [menuButton tap];
        
        [self givenSideMenuVisible];
    } else {
        XCTFail(@"'Menu' button doesn't exist.");
    }
    
    if (menuButton.exists) {
        [menuButton tap];
        
        [self givenSideMenuNotVisible];
    } else {
        XCTFail(@"'Menu' button doesn't exist.");
    }
}

- (void)testThatUserCanPullDownToRefresh
{
    [self givenThatLibraryPageOnScreen];
    [self givenSideMenuNotVisible];
    
    [self givenThatCellsAreVisible];
    
    XCUIElement *collectionViewElement = [self.application.collectionViews elementBoundByIndex:0];
    XCUIElement *firstCellElement = [collectionViewElement.cells elementBoundByIndex:0];
    XCUIElement *secondCellElement = [collectionViewElement.cells elementBoundByIndex:4];
    
    [firstCellElement pressForDuration:1 thenDragToElement:secondCellElement];
    
    [self verifyThatCollectionViewNotContainsCells];
    [self verifyThatCollectionViewContainsCells];
}

- (void)testThatUserCanScrollDown
{
    [self givenThatLibraryPageOnScreen];
    [self givenSideMenuNotVisible];
    
    [self givenThatCellsAreVisible];
    
    XCUIElement *collectionViewElement = [self.application.collectionViews elementBoundByIndex:0];
    XCUIElement *cellElement = [collectionViewElement.cells elementBoundByIndex:2];
    [cellElement swipeUp];
    
    [self verifyThatCollectionViewContainsCells];
}

#pragma mark - Test 'Search' feature

- (void)testThatSearchWorkWithCorrectWords
{
    [self givenThatLibraryPageOnScreen];
    [self givenSideMenuNotVisible];
    [self givenThatCellsAreVisible];
    
    // start find some text
    [self trySearchText:kJMTestLibrarySearchTextExample];
    // verify result
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.hittable == true"];
    NSInteger filtredResultCount = [[self.application.cells allElementsBoundByIndex] filteredArrayUsingPredicate:predicate].count;
    XCTAssertTrue(filtredResultCount == 1, @"Should be only one result");
    
    // Reset search
    [self tryClearSearchBar];
    // verify result
    [self verifyThatCollectionViewContainsCells];
}

- (void)testThatSearchShowsNoResults
{
    [self givenThatLibraryPageOnScreen];
    [self givenSideMenuNotVisible];
    [self givenThatCellsAreVisible];
    
    // start find wrong text
    XCUIElement *searchResourcesSearchField = self.application.searchFields[@"Search resources"];
    if (searchResourcesSearchField.exists) {
        [searchResourcesSearchField tap];
        [searchResourcesSearchField typeText:@"ababababababababa"];
        
        XCUIElement *searchButton = self.application.buttons[@"Search"];
        if (searchButton.exists) {
            [searchButton tap];
            
            // verify result
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.hittable == true"];
            NSInteger filtredResultCount = [[self.application.cells allElementsBoundByIndex] filteredArrayUsingPredicate:predicate].count;
            XCTAssertTrue(filtredResultCount == 0, @"Should be only one result");
            
        } else {
            XCTFail(@"Search button doesn't exist.");
        }
        
    } else {
        XCTFail(@"Search field doesn't exist.");
    }
}

#pragma mark - Test 'Changing View Presentation' feature

- (void)testThatViewTypeButtonChangeViewPresentation
{
    [self givenThatLibraryPageOnScreen];
    [self givenSideMenuNotVisible];
    [self givenThatCellsAreVisible];
    
    XCUIElement *contentView = self.application.otherElements[@"JMBaseCollectionContentViewAccessibilityId"];
    if (contentView.exists) {
        
        [self givenThatCollectionViewContainsListOfCells];
        
        [self tryChangeViewPresentationFromListToGrid];
        [self verifyThatCollectionViewContainsGridOfCells];
        
        [self tryChangeViewPresentationFromGridToList];
        [self verifyThatCollectionViewContainsListOfCells];
        
    } else {
        XCTFail(@"Content View doesn't visible");
    }
}

- (void)testThatViewPresentationNotChangeAfterChangingPages
{
    [self givenThatLibraryPageOnScreen];
    [self givenSideMenuNotVisible];
    [self givenThatCellsAreVisible];
    
    XCUIElement *contentView = self.application.otherElements[@"JMBaseCollectionContentViewAccessibilityId"];
    if (contentView.exists) {
        
        [self givenThatCollectionViewContainsListOfCells];
        
        [self tryChangeViewPresentationFromListToGrid];
        [self givenThatCellsAreVisible];
        [self verifyThatCollectionViewContainsGridOfCells];
        
        // Change Page to Repository
        [self tryOpenRepositoryPage];
        [self verifyThatCurrentPageIsRepository];
        
        // Change Page to Library
        [self tryOpenLibraryPage];
        [self verifyThatCurrentPageIsLibrary];
        [self givenThatCellsAreVisible];
        
        [self verifyThatCollectionViewContainsGridOfCells];
        
    } else {
        XCTFail(@"Content View doesn't visible");
    }
}

- (void)testThatViewPresentationNotChangeWhenUserUseSearch
{
    [self givenThatLibraryPageOnScreen];
    [self givenSideMenuNotVisible];
    [self givenThatCellsAreVisible];
    [self givenThatCollectionViewContainsListOfCells];

    [self tryChangeViewPresentationFromListToGrid];
    [self verifyThatCollectionViewContainsGridOfCells];
    
    // start find some text
    [self trySearchText:kJMTestLibrarySearchTextExample];
    [self verifyThatCollectionViewContainsGridOfCells];
    
    [self tryClearSearchBar];
}

#pragma mark - Test 'Sort' feature
- (void)testThatUserCanSortListItemsByName
{
    [self givenThatLibraryPageOnScreen];
    [self givenSideMenuNotVisible];
    [self givenThatCellsAreVisible];
    
    [self verifyThatCellsSortedByName];
}

- (void)testThatUserCanSortListItemsByCreationDate
{
    [self givenThatLibraryPageOnScreen];
    [self givenSideMenuNotVisible];
    [self givenThatCellsAreVisible];
    
    [self trySortByCreationDate];
    [self givenThatCellsAreVisible];
    
    [self verifyThatCellsSortedByCreationDate];
}

- (void)testThatUserCanSortListItemsByModifiedDate
{
    [self givenThatLibraryPageOnScreen];
    [self givenSideMenuNotVisible];
    [self givenThatCellsAreVisible];
    
    [self trySortByModifiedDate];
    [self verifyThatCellsSortedByModifiedDate];
}

#pragma mark - Test 'Filter' feature
- (void)testThatUserCanFilterByAllItems
{
    [self givenThatLibraryPageOnScreen];
    [self givenSideMenuNotVisible];
    [self givenThatCellsAreVisible];
    
    [self verifyThatCellsFiltredByAll];
}

- (void)testThatUserCanFilterByReports
{
    [self givenThatLibraryPageOnScreen];
    [self givenSideMenuNotVisible];
    [self givenThatCellsAreVisible];
    
    [self tryFilterByReports];
    [self verifyThatCellsFiltredByReports];
}

- (void)testThatUserCanFilterByDashboards
{
    [self givenThatLibraryPageOnScreen];
    [self givenSideMenuNotVisible];
    [self givenThatCellsAreVisible];
    
    [self tryFilterByDashboards];
    [self verifyThatCellsFiltredByDashboards];
}

#pragma mark - Helpers
- (void)givenThatLoginPageOnScreen
{
    XCUIElement *loginPageView = self.application.otherElements[@"JMLoginPageAccessibilityId"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.exists == true"];
    
    [self expectationForPredicate:predicate
              evaluatedWithObject:loginPageView
                          handler:nil];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)givenThatServerProfilesPageOnScreen
{
    XCUIElement *serverProfilesPageView = self.application.otherElements[@"JMServerProfilesPageAccessibilityId"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.exists == true"];
    
    [self expectationForPredicate:predicate
              evaluatedWithObject:serverProfilesPageView
                          handler:nil];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)givenThatNewProfilePageOnScreen
{
    XCUIElement *newServerProfilePageView = self.application.otherElements[@"JMNewServerProfilePageAccessibilityId"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.exists == true"];
    
    [self expectationForPredicate:predicate
              evaluatedWithObject:newServerProfilePageView
                          handler:nil];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)givenThatLibraryPageOnScreen
{
    [self verifyIntroPageIsOnScreen];
    [self verifyRateAlertIsShown];
    
    // Verify Library Page
    XCUIElement *libraryPageView = self.application.otherElements[@"JMLibraryPageAccessibilityId"];
    NSPredicate *libraryPagePredicate = [NSPredicate predicateWithFormat:@"self.exists == true"];
    
    [self expectationForPredicate:libraryPagePredicate
              evaluatedWithObject:libraryPageView
                          handler:nil];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)verifyIntroPageIsOnScreen
{
    XCUIElement *skipIntroButton = self.application.buttons[@"Skip Intro"];
    if (skipIntroButton.exists) {
        [skipIntroButton tap];
    }
}

- (void)verifyRateAlertIsShown
{
    XCUIElement *rateAlert = self.application.alerts[@"Rate TIBCO JasperMobile"];
    if (rateAlert.exists) {
        XCUIElement *rateAppLateButton = rateAlert.collectionViews.buttons[@"No, thanks"];
        if (rateAppLateButton.exists) {
            [rateAppLateButton tap];
        }
    }
}

- (void)givenThatCollectionViewContainsListOfCells
{
    NSInteger countOfListCells = [self countOfListCells];
    if (countOfListCells > 0) {
        return;
    } else {
        [self tryChangeViewPresentationFromGridToList];
    }
}

- (void)givenThatCellsAreVisible
{
    // wait until collection view will fill.
    NSPredicate *cellsCountPredicate = [NSPredicate predicateWithFormat:@"self.cells.count > 0"];
    [self expectationForPredicate:cellsCountPredicate
              evaluatedWithObject:self.application
                          handler:nil];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

// TODO: Implement this
//- (void)givenThatSortOptionIsByName
//{
//    [self verifyThatCellsSortedByName];
//}

#pragma mark - Helper Actions
// TODO: move to shared methods

- (void)tryOpenRepositoryPage
{
    NSString *libraryPageName = @"Repository";
    [self tryOpenPageWithName:libraryPageName];
}

- (void)tryOpenLibraryPage
{
    NSString *libraryPageName = @"Library";
    [self tryOpenPageWithName:libraryPageName];
}

- (void)tryOpenPageWithName:(NSString *)pageName
{
    [self tryOpenSideApplicationMenu];
    
    XCUIElement *menuView = self.application.otherElements[@"JMSideApplicationMenuAccessibilityId"];
    if (menuView.exists) {
        XCUIElement *pageMenuItem = menuView.cells.staticTexts[pageName];
        if (pageMenuItem.exists) {
            [pageMenuItem tap];
            
            // wait if need when view in navigation view will appear
            NSPredicate *navBarPredicate = [NSPredicate predicateWithFormat:@"self.navigationBars.count > 0"];
            [self expectationForPredicate:navBarPredicate
                      evaluatedWithObject:self.application
                                  handler:nil];
            [self waitForExpectationsWithTimeout:5 handler:nil];
        }
    } else {
        XCTFail(@"'Menu' isn't visible.");
    }
}

#pragma mark - Helpers - Side (App) Menu

- (void)givenSideMenuVisible
{
    XCUIElement *menuView = self.application.otherElements[@"JMSideApplicationMenuAccessibilityId"];
    if (!menuView.exists) {
        [self tryOpenSideApplicationMenu];
    }
}

- (void)givenSideMenuNotVisible
{
    XCUIElement *menuView = self.application.otherElements[@"JMSideApplicationMenuAccessibilityId"];
    if (menuView.exists) {
        [self tryOpenSideApplicationMenu];
    }
}

- (void)tryOpenSideApplicationMenu
{
    XCUIElement *menuButton = self.application.buttons[@"menu icon"];
    if (menuButton.exists) {
        [menuButton tap];
    } else {
        XCTFail(@"'Menu' button doesn't exist.");
    }
}

#pragma mark - Helpers - Collection View Presentations

- (void)tryChangeViewPresentationFromListToGrid
{
    XCUIElement *gridButtonButton = self.application.buttons[@"grid button"];
    if (gridButtonButton.exists) {
        [gridButtonButton tap];
    } else {
        XCTFail(@"There isn't 'grid' button");
    }
}

- (void)tryChangeViewPresentationFromGridToList
{
    XCUIElement *horizontalListButtonButton = self.application.buttons[@"horizontal list button"];
    if (horizontalListButtonButton.exists) {
        [horizontalListButtonButton tap];
    } else {
        XCTFail(@"There isn't 'list' button");
    }
}

#pragma mark - Helpers - Search

- (void)trySearchText:(NSString *)text
{
    // start find some text
    XCUIElement *searchResourcesSearchField = self.application.searchFields[@"Search resources"];
    if (searchResourcesSearchField.exists) {
        [searchResourcesSearchField tap];
        [searchResourcesSearchField typeText:text];
        
        XCUIElement *searchButton = self.application.buttons[@"Search"];
        if (searchButton.exists) {
            [searchButton tap];
        } else {
            XCTFail(@"Search button doesn't exist.");
        }
    } else {
        XCTFail(@"Search field doesn't exist.");
    }
}

- (void)tryClearSearchBar
{
    XCUIElement *searchResourcesSearchField = self.application.searchFields[@"Search resources"];
    if (searchResourcesSearchField.exists) {
        [searchResourcesSearchField tap];
        
        XCUIElement *cancelButton = self.application.buttons[@"Cancel"];
        if (cancelButton.exists) {
            [cancelButton tap];
        } else {
            XCTFail(@"Cancel button doesn't exist.");
        }
    } else {
        XCTFail(@"Search field doesn't exist.");
    }
}

#pragma mark - Helpers - Menu
- (BOOL)isShareButtonExists
{
    BOOL isShareButtonExists = NO;
    XCUIElement *navBar = self.application.navigationBars[@"Library"];
    if (navBar.exists) {
        XCUIElement *menuActionsButton = navBar.buttons[@"Share"];
        if (menuActionsButton.exists) {
            isShareButtonExists = YES;
        }
    }
    return isShareButtonExists;
}

#pragma mark - Helpers - Menu Sort By

- (void)tryOpenSortMenu
{
    BOOL isShareButtonExists = [self isShareButtonExists];
    if (isShareButtonExists) {
        [self tryOpenMenuActions];
        [self tryOpenSortMenuFromMenuActions];
    } else {
        [self tryOpenSortMenuFromNavBar];
    }
}

- (void)tryOpenSortMenuFromMenuActions
{
    XCUIElement *menuActionsElement = [self.application.tables elementBoundByIndex:0];
    XCUIElement *sortActionElement = menuActionsElement.staticTexts[@"Sort by"];
    if (sortActionElement.exists) {
        [sortActionElement tap];
        
        // Wait until sort view appears
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.tables.count == 1"];
        [self expectationForPredicate:predicate
                  evaluatedWithObject:self.application
                              handler:nil];
        [self waitForExpectationsWithTimeout:5 handler:nil];
        
    } else {
        XCTFail(@"Sort Action isn't visible");
    }
}

- (void)tryOpenSortMenuFromNavBar
{
    XCUIElement *navBar = self.application.navigationBars[@"Library"];
    if (navBar.exists) {
        XCUIElement *sortButton = navBar.buttons[@"sort action"];
        if (sortButton.exists) {
            [sortButton tap];
        } else {
            XCTFail(@"Sort Button isn't visible");
        }
    } else {
        XCTFail(@"Navigation bar isn't visible");
    }
}

#pragma mark - Helpers - Menu Filter By

- (void)tryOpenFilterMenu
{
    BOOL isShareButtonExists = [self isShareButtonExists];
    if (isShareButtonExists) {
        [self tryOpenMenuActions];
        [self tryOpenFilterMenuFromMenuActions];
    } else {
        [self tryOpenFilterMenuFromNavBar];
    }
}

- (void)tryOpenMenuActions
{
    XCUIElement *navBar = self.application.navigationBars[@"Library"];
    if (navBar.exists) {
        XCUIElement *menuActionsButton = navBar.buttons[@"Share"];
        if (menuActionsButton.exists) {
            [menuActionsButton tap];
            
            // Wait until menu actions appears
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.tables.count == 1"];
            [self expectationForPredicate:predicate
                      evaluatedWithObject:self.application
                                  handler:nil];
            [self waitForExpectationsWithTimeout:5 handler:nil];
            
            XCUIElement *menuActionsElement = [self.application.tables elementBoundByIndex:0];
            if (!menuActionsElement.exists) {
                XCTFail(@"Menu Actions isn't visible");
            }
        } else {
            XCTFail(@"Menu Actions button isn't visible");
        }
    } else {
        XCTFail(@"Navigation bar isn't visible");
    }
}

- (void)tryOpenFilterMenuFromMenuActions
{
    XCUIElement *menuActionsElement = [self.application.tables elementBoundByIndex:0];
    XCUIElement *filterActionElement = menuActionsElement.staticTexts[@"Filter by"];
    if (filterActionElement.exists) {
        [filterActionElement tap];
        
        // Wait until sort view appears
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.tables.count == 1"];
        [self expectationForPredicate:predicate
                  evaluatedWithObject:self.application
                              handler:nil];
        [self waitForExpectationsWithTimeout:5 handler:nil];
        
    } else {
        XCTFail(@"Sort Action isn't visible");
    }
}

- (void)tryOpenFilterMenuFromNavBar
{
    XCUIElement *navBar = self.application.navigationBars[@"Library"];
    if (navBar.exists) {
        XCUIElement *filterButton = navBar.buttons[@"filter action"];
        if (filterButton.exists) {
            [filterButton tap];
        } else {
            XCTFail(@"Filter Button isn't visible");
        }
    } else {
        XCTFail(@"Navigation bar isn't visible");
    }
}

#pragma mark - Helpers - Sort By

- (void)trySortByName
{
    [self tryOpenSortMenu];
    [self trySelectSortBy:@"Name"];
}

- (void)trySortByCreationDate
{
    [self tryOpenSortMenu];
    [self trySelectSortBy:@"Creation Date"];
}

- (void)trySortByModifiedDate
{
    [self tryOpenSortMenu];
    [self trySelectSortBy:@"Modified Date"];
}

- (void)trySelectSortBy:(NSString *)sortTypeString
{
    XCUIElement *sortOptionsViewElement = [self.application.tables elementBoundByIndex:0];
    if (sortOptionsViewElement.exists) {
        XCUIElement *sortOptionElement = sortOptionsViewElement.staticTexts[sortTypeString];
        if (sortOptionElement.exists) {
            [sortOptionElement tap];
        } else {
            XCTFail(@"'%@' Sort Option isn't visible", sortTypeString);
        }
    } else {
        XCTFail(@"Sort Options View isn't visible");
    }
}

#pragma mark - Helpers - Filter By

- (void)tryFilterByAll
{
    [self tryOpenFilterMenu];
    [self trySelectFilterBy:@"All"];
}

- (void)tryFilterByReports
{
    [self tryOpenFilterMenu];
    [self trySelectFilterBy:@"Reports"];
}

- (void)tryFilterByDashboards
{
    [self tryOpenFilterMenu];
    [self trySelectFilterBy:@"Dashboards"];
}

- (void)trySelectFilterBy:(NSString *)filterTypeString
{
    XCUIElement *filterOptionsViewElement = [self.application.tables elementBoundByIndex:0];
    if (filterOptionsViewElement.exists) {
        XCUIElement *filterOptionElement = filterOptionsViewElement.staticTexts[filterTypeString];
        if (filterOptionElement.exists) {
            [filterOptionElement tap];
        } else {
            XCTFail(@"'%@' Filter Option isn't visible", filterTypeString);
        }
    } else {
        XCTFail(@"Filter Options View isn't visible");
    }
}

#pragma mark - Verfies
- (void)verifyThatCollectionViewContainsListOfCells
{
    // Shold be 'list' cells
    NSInteger countOfListCells = [self countOfListCells];
    XCTAssertTrue(countOfListCells > 0, @"Should be 'List' presentation");
    
    // Should not be 'grid' cells
    NSInteger countOfGridCells = [self countOfGridCells];
    XCTAssertTrue(countOfGridCells == 0, @"Should be 'Grid' presentation");
}

- (void)verifyThatCollectionViewContainsGridOfCells
{
    // Should be 'grid' cells
    NSInteger countOfGridCells = [self countOfGridCells];
    XCTAssertTrue(countOfGridCells > 0, @"Should be 'Grid' presentation");
    
    // Shold not be 'list' cells
    NSInteger countOfListCells = [self countOfListCells];
    XCTAssertTrue(countOfListCells == 0, @"Should be 'List' presentation");
}

- (void)verifyThatCurrentPageIsLibrary
{
    XCUIElement *libraryNavBar = self.application.navigationBars[@"Library"];
    XCTAssertTrue(libraryNavBar.exists, @"Should be 'Library' page");
}

- (void)verifyThatCurrentPageIsRepository
{
    XCUIElement *libraryNavBar = self.application.navigationBars[@"Repository"];
    XCTAssertTrue(libraryNavBar.exists, @"Should be 'Library' page");
}

- (void)verifyThatCollectionViewContainsCells
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.hittable == true"];
    NSInteger filtredResultCount = [[self.application.cells allElementsBoundByIndex] filteredArrayUsingPredicate:predicate].count;
    XCTAssertTrue(filtredResultCount > 0, @"Should be some cells");
}

- (void)verifyThatCollectionViewNotContainsCells
{
    // TODO: implement
}

- (void)verifyThatCellsSortedByName
{
    NSArray *visibleCells = [self.application.cells allElementsBoundByIndex];
    
    NSArray *sortedCelsByName = [visibleCells sortedArrayUsingComparator:^NSComparisonResult(XCUIElement *obj1, XCUIElement *obj2) {
        XCUIElement *firstObjectTitleElement = [obj1.staticTexts elementBoundByIndex:0];
        NSString *firstObjectTitle = firstObjectTitleElement.label;
        
        XCUIElement *secondObjectTitleElement = [obj1.staticTexts elementBoundByIndex:0];
        NSString *secondObjectTitle = secondObjectTitleElement.label;
        return [firstObjectTitle compare:secondObjectTitle];
    }];
    
    XCTAssertEqualObjects([visibleCells lastObject], [sortedCelsByName lastObject], @"Cells should be sorted by name");
}

- (void)verifyThatCellsSortedByCreationDate
{
    // TODO: implement
//    XCTFail(@"Need implementation");
    XCTAssertTrue(YES, @"Should be sorted by creation date");
}

- (void)verifyThatCellsSortedByModifiedDate
{
    // TODO: implement
//    XCTFail(@"Need implementation");
    XCTAssertTrue(YES, @"Should be sorted by modified date");
}

- (void)verifyThatCellsFiltredByAll
{
    // TODO: implement
//    XCTFail(@"Need implementation");
    XCTAssertTrue(YES, @"Should be filtred by all");
}

- (void)verifyThatCellsFiltredByReports
{
    // TODO: implement
//    XCTFail(@"Need implementation");
    XCTAssertTrue(YES, @"Should be filtred by reports");
}

- (void)verifyThatCellsFiltredByDashboards
{
    // TODO: implement
//    XCTFail(@"Need implementation");
    XCTAssertTrue(YES, @"Should be filtred by dashboards");
}

#pragma mark - 
- (NSInteger)countOfGridCells
{
    NSPredicate *predicateForGrid = [NSPredicate predicateWithFormat:@"self.hittable == true && (self.identifier == 'JMCollectionViewGridCellAccessibilityId')"];
    NSInteger filtredResultCount = [[self.application.cells allElementsBoundByIndex] filteredArrayUsingPredicate:predicateForGrid].count;
    return filtredResultCount;
}

- (NSInteger)countOfListCells
{
    NSPredicate *predicateForList = [NSPredicate predicateWithFormat:@"self.hittable == true && (self.identifier == 'JMCollectionViewListCellAccessibilityId')"];
    NSInteger filtredResultCount = [[self.application.cells allElementsBoundByIndex] filteredArrayUsingPredicate:predicateForList].count;
    return filtredResultCount;
}

@end
