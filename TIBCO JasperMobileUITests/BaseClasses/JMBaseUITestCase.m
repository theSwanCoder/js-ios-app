//
//  JMBaseUITestCase.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 2/18/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMBaseUITestCase.h"

@implementation JMBaseUITestCase

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

#pragma mark - Helpers Test Profile
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

#pragma mark - Helper Actions

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

#pragma mark - Verifies
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

@end
