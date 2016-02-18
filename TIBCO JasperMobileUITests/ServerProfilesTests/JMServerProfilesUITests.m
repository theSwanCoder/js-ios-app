//
//  JMServerProfilesUITests.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 2/14/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "JMUITestConstants.h"

@interface JMServerProfilesUITests : XCTestCase
@property(nonatomic, strong) XCUIApplication *application;
@end

@implementation JMServerProfilesUITests

- (void)setUp {
    [super setUp];
    
    self.continueAfterFailure = NO;
    
    self.application = [[XCUIApplication alloc] init];
    [self.application launch];
    
    XCUIElement *loginPageView = self.application.otherElements[@"JMLoginPageAccessibilityId"];
    if (loginPageView.exists) {
        [self loginWithTestProfile];
    } else {
        [self logout];
        [self loginWithTestProfile];
    }
}

- (void)testThatListOfServerProfilesVisible
{
    
}

- (void)tearDown {
    [self logout];
//    [self removeTestProfile];
    
    self.application = nil;
    [super tearDown];
}

#pragma mark - High level Helpers
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
    
    [self trySelectLogoutMenuAction];
}

- (void)removeTestProfile
{
    [self givenThatLoginPageOnScreen];
    [self tryOpenServerProfilesPage];
    
    [self givenThatServerProfilesPageOnScreen];
    [self tryDeleteServerProfile];
    
    [self givenThatServerProfilesPageOnScreen];
    [self tryBackToLoginPageFromProfilesPage];
}

#pragma mark - State detections
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

#pragma mark - Low level Helpers
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

// TODO: move to shared methods
- (void)tryOpenSideApplicationMenu
{
    XCUIElement *menuButton = self.application.navigationBars[@"Library"].buttons[@"menu icon"];
    if (menuButton.exists) {
        [menuButton tap];
    } else {
        XCTFail(@"'Menu' button doesn't exist.");
    }
}

- (void)trySelectLogoutMenuAction
{
    XCUIElement *logoutActionElement = self.application.tables.staticTexts[@"Log Out"];
    if (logoutActionElement.exists) {
        [logoutActionElement tap];
    }
}

- (void)tryDeleteServerProfile
{
    XCUIElement *testProfile = self.application.collectionViews.staticTexts[@"Test Profile"];
    if (testProfile.exists) {
        [testProfile pressForDuration:1.1];
        XCUIElement *deleteMenuItem = self.application.menuItems[@"Delete"];
        if (deleteMenuItem.exists) {
            [deleteMenuItem tap];
        } else {
            XCTFail(@"'Delete' menu item doesn't exist");
        }
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.alerts.count > 0"];
        [self expectationForPredicate:predicate
                  evaluatedWithObject:self.application
                              handler:nil];
        [self waitForExpectationsWithTimeout:5 handler:nil];
        
        XCUIElement *confirmationAlert = self.application.alerts[@"Confirmation"];
        if (confirmationAlert.exists) {
            XCUIElement *deleteButton = confirmationAlert.collectionViews.buttons[@"Delete"];
            if (deleteButton.exists) {
                [deleteButton tap];
            } else {
                XCTFail(@"'Delete' button doesn't exist");
            }
        } else {
            XCTFail(@"Confirmation alert doesn't exist");
        }
    } else {
        XCTFail(@"Test profile doesn't visible or exist");
    }
}

@end