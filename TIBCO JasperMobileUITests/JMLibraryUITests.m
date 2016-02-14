//
//  JMLibraryUITests.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 2/11/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import <XCTest/XCTest.h>

//NSString *const kJMTestProfileURL = @"http://192.168.88.55:8088/jasperserver-pro-62";
NSString *const kJMTestProfileURL = @"http://mobiledemo2.jaspersoft.com/jasperserver-pro";
NSString *const kJMTestProfileName = @"Test Profile";
//NSString *const kJMTestProfileCredentialsUsername = @"superuser";
//NSString *const kJMTestProfileCredentialsPassword = @"superuser";

NSString *const kJMTestProfileCredentialsUsername = @"phoneuser";
NSString *const kJMTestProfileCredentialsPassword = @"phoneuser";

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
//    [[[XCUIApplication alloc] init] launch];

    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    
    self.application = [[XCUIApplication alloc] init];
    [self.application launch];
    [self createTestProfile];
    [self loginWithTestProfile];
}

- (void)testThatLibraryPageHasTitleLibrary
{
    [self givenThatLibraryPageOnScreen];

    XCUIElement *libraryNavBar = self.application.navigationBars[@"Library"];
    if (!libraryNavBar.exists) {
        XCTFail(@"Library page isn't on screen.");
    }
}

- (void)tearDown {
    [self logout];
    [self removeTestProfile];
    self.application = nil;
    
    [super tearDown];
}

#pragma mark - High level Helpers
- (void)createTestProfile
{
    [self givenThatLoginPageOnScreen];
    [self tryOpenServerProfilesPage];
    
    [self givenThatServerProfilesPageOnScreen];
    [self tryOpenNewServerProfilePage];
    
    [self givenThatNewProfilePageOnScreen];
    [self tryCreateNewTestServerProfile];
    
    [self givenThatServerProfilesPageOnScreen];
    [self tryBackToLoginPageFromProfilesPage];
}

- (void)loginWithTestProfile
{
    [self givenThatLoginPageOnScreen];
    [self tryOpenServerProfilesPage];
    
    [self givenThatServerProfilesPageOnScreen];
    [self trySelectNewTestServerProfile];
    
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
    if (loginPageView.exists) {
        NSLog(@"Login page on screen");
    } else {
        NSLog(@"Login page isn't on screen");
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.navigationBars.count == 0"];
    [self expectationForPredicate:predicate
              evaluatedWithObject:self.application
                          handler:nil];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)givenThatServerProfilesPageOnScreen
{
    XCUIElement *serverProfilesPageView = self.application.otherElements[@"JMServerProfilesPageAccessibilityId"];
    if (serverProfilesPageView.exists) {
        NSLog(@"Server Profiles page on screen");
    } else {
        NSLog(@"Server Profiles page isn't on screen");
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.navigationBars.count > 0"];
    [self expectationForPredicate:predicate
              evaluatedWithObject:self.application
                          handler:nil];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)givenThatNewProfilePageOnScreen
{
    XCUIElement *newServerProfilePageView = self.application.otherElements[@"JMNewServerProfilePageAccessibilityId"];
    if (newServerProfilePageView.exists) {
        NSLog(@"New Server Profile page on screen");
    } else {
        NSLog(@"New Server Profile page isn't on screen");
    }
    
    // TODO: add expectation
}

- (void)givenThatLibraryPageOnScreen
{
    XCUIElement *skipIntroButton = self.application.buttons[@"Skip Intro"];
    if (skipIntroButton.exists) {
        [skipIntroButton tap];
    }
    
    XCUIElement *rateAppLateButton = self.application.buttons[@"Skip Intro"];
    if (rateAppLateButton.exists) {
        [rateAppLateButton tap];
    }
    
    XCUIElement *libraryPageView = self.application.otherElements[@"JMLibraryPageAccessibilityId"];
    if (libraryPageView.exists) {
        NSLog(@"Library page on screen");
    } else {
        NSLog(@"Library page isn't on screen");
    }
    
    // wait if need when view in navigation view will appear
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.navigationBars.count > 0"];
    [self expectationForPredicate:predicate
              evaluatedWithObject:self.application
                          handler:nil];
    [self waitForExpectationsWithTimeout:5 handler:nil];
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
