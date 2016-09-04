//
//  JMBaseUITestCase.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 2/18/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMBaseUITestCase.h"
#import "JMBaseUITestCase+Helpers.h"

NSTimeInterval kUITestsBaseTimeout = 10;
NSTimeInterval kUITestsResourceWaitingTimeout = 30;
NSTimeInterval kUITestsElementAvailableTimeout = 1;

@implementation JMBaseUITestCase

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    
    [self.application launch];
    
    XCUIElement *loginPageView = [self findElementWithAccessibilityId:@"JMLoginPageAccessibilityId"];
    if (!loginPageView) {
        [self logout];
    }
    
    if ([self shouldLoginBeforeStartTest]) {
        [self loginWithTestProfile];
    }
}

- (void)tearDown {
    XCUIElement *loginPageView = [self findElementWithAccessibilityId:@"JMLoginPageAccessibilityId"];
    if (!loginPageView) {
        [self logout];
    }
    self.application = nil;
    
    [super tearDown];
}

#pragma mark - Custom Accessors
- (XCUIApplication *)application
{
    return [XCUIApplication new];
}

#pragma mark - Setup Helpers
- (void)selectTestProfile
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    [self tryOpenServerProfilesPage];
    
    [self givenThatServerProfilesPageOnScreen];
    
    XCUIElement *testProfile = self.application.collectionViews.staticTexts[@"Test Profile"];
    BOOL isTestProfileExists = testProfile.exists;
    if (!isTestProfileExists) {
        [self removeAllServerProfiles];
        
        [self tryOpenNewServerProfilePage];
        [self givenThatNewProfilePageOnScreen];
        [self tryCreateNewTestServerProfile];
        
        [self givenThatServerProfilesPageOnScreen];
    }
    [self trySelectNewTestServerProfile];
}

- (void)removeAllServerProfiles
{
    NSInteger cellsCount = self.application.collectionViews.cells.count;
    
    while(cellsCount--) {
        [self removeFirstServerProfile];
    }
}

- (void)removeFirstServerProfile
{
    XCUIElement *profile = [self.application.collectionViews.cells elementBoundByIndex:0];
    if (profile) {
        [profile pressForDuration:1.0];
        [profile pressForDuration:1.1];
        XCUIElement *menu = self.application.menuItems[@"Delete"];
        if (menu) {
            [menu tap];
            XCUIElement *deleteButton = [self findButtonWithAccessibilityId:@"Delete"
                                                              parentElement:self.application.alerts[@"Confirmation"]];
            if (deleteButton) {
                [deleteButton tap];
            } else {
                XCTFail(@"Delete button doesn't exist.");
            }
        } else {
            XCTFail(@"Delete menu item doesn't exist.");
        }
    } else {
        XCTFail(@"Server profile cell doesn't exist.");
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
    [self tryOpenPageWithName:@"Log Out"];
}

#pragma mark - Helpers Test Profile
- (void)tryOpenServerProfilesPage
{
    XCUIElement *serverProfileTextField = [self waitTextFieldWithAccessibilityId:@"JMLoginPageServerProfileTextFieldAccessibilityId"
                                                                         timeout:kUITestsBaseTimeout];
    [serverProfileTextField tap];
}

- (void)tryOpenNewServerProfilePage
{
    XCUIElement *addProfileButton = [self waitButtonWithAccessibilityId:@"JMServerProfilesPageAddNewProfileButtonAccessibilityId"
                                                                timeout:kUITestsBaseTimeout];
    [addProfileButton tap];
}

- (void)tryCreateNewTestServerProfile
{
    XCUIApplication *app = self.application;
    XCUIElement *table = [app.tables elementBoundByIndex:0];

    // Profile Name TextField
    [self enterText:kJMTestProfileName intoTextFieldWithAccessibilityId:@"Profile name"
      parentElement:table
      isSecureField:false];

    // Profile URL TextField
    [self enterText:kJMTestProfileURL intoTextFieldWithAccessibilityId:@"Server address"
      parentElement:table
      isSecureField:false];

    // Organization TextField
    [self enterText:kJMTestProfileCredentialsOrganization intoTextFieldWithAccessibilityId:@"Organization ID"
      parentElement:table
      isSecureField:false];

    // Save a new created profile
    XCUIElement *saveButton = [self waitButtonWithAccessibilityId:@"Save"
                                                          timeout:kUITestsBaseTimeout];
    [saveButton tap];
    
    // Confirm if need http end point
    [self closeSecurityWarningAlert];
}

- (void)closeSecurityWarningAlert
{
    XCUIElement *securityWarningAlert = self.application.alerts[@"Warning"];
    if (securityWarningAlert.exists) {
        XCUIElement *okButton = [self findButtonWithAccessibilityId:JMLocalizedString(@"dialog_button_ok")
                                                      parentElement:securityWarningAlert];
        if (okButton.exists) {
            // HACK - We need add sleep here, because sometimes the button isn't 'tappable', right after getting it
            sleep(kUITestsElementAvailableTimeout);
            [okButton tap];
        } else {
            XCTFail(@"'Ok' button on security warning alert doesn't exist.");
        }
    }
}

- (void)tryBackToLoginPageFromProfilesPage
{
    [self tryBackToPreviousPage];
}

- (void)trySelectNewTestServerProfile
{
    XCUIElement *testProfile = self.application.collectionViews.staticTexts[@"Test Profile"];
    if (testProfile.exists) {
        [testProfile tap];
    } else {
        XCTFail(@"Test profile doesn't visible or exist");
    }
}

- (void)tryEnterTestCredentials
{
    // Enter username
    [self enterText:kJMTestProfileCredentialsUsername intoTextFieldWithAccessibilityId:@"JMLoginPageUserNameTextFieldAccessibilityId"
      parentElement:nil
      isSecureField:false];

    // Enter password
    [self enterText:kJMTestProfileCredentialsPassword intoTextFieldWithAccessibilityId:@"JMLoginPagePasswordTextFieldAccessibilityId"
      parentElement:nil
      isSecureField:true];
}

- (void)tryTapLoginButton
{
    XCUIElement *loginButton = [self waitButtonWithAccessibilityId:@"JMLoginPageLoginButtonAccessibilityId"
                                                           visible:true
                                                           timeout:kUITestsBaseTimeout];
    [loginButton tap];
}


#pragma mark - Helpers
- (void)givenThatLoginPageOnScreen
{
    [self waitElementWithAccessibilityId:@"JMLoginPageAccessibilityId"
                                 visible:true
                                 timeout:kUITestsBaseTimeout];
}

- (void)givenThatServerProfilesPageOnScreen
{
    [self waitElementWithAccessibilityId:@"JMServerProfilesPageAccessibilityId"
                                 visible:true
                                 timeout:kUITestsBaseTimeout];
}

- (void)givenThatNewProfilePageOnScreen
{
    [self waitElementWithAccessibilityId:@"JMNewServerProfilePageAccessibilityId"
                                 visible:true
                                 timeout:kUITestsBaseTimeout];
}

- (void)givenThatLibraryPageOnScreen
{
    [self verifyRateAlertIsShown];
    [self verifyIntroPageIsOnScreen];
    
    // Verify Library Page
    [self verifyThatCurrentPageIsLibrary];
}

- (void)givenThatCellsAreVisible
{
    // wait until collection view will fill.
    NSPredicate *cellsCountPredicate = [NSPredicate predicateWithFormat:@"self.cells.count > 0"];
    [self expectationForPredicate:cellsCountPredicate
              evaluatedWithObject:self.application
                          handler:nil];
    [self waitForExpectationsWithTimeout:kUITestsBaseTimeout
                                 handler:nil];
}

- (void)verifyIntroPageIsOnScreen
{
    sleep(kUITestsElementAvailableTimeout);
    XCUIElement *skipIntroButton = self.application.buttons[@"Skip Intro"];
    if (skipIntroButton.exists) {
        [skipIntroButton tap];
    }
}

- (void)verifyRateAlertIsShown
{
    sleep(kUITestsElementAvailableTimeout);
    XCUIElement *rateAlert = self.application.alerts[@"Rate TIBCO JasperMobile"];
    if (rateAlert.exists) {
        XCUIElement *rateAppLateButton = rateAlert.buttons[@"No, thanks"];
        if (rateAppLateButton.exists) {
            [rateAppLateButton tap];
        }
    }
}

#pragma mark - Helper Actions
- (void)tryBackToPreviousPage
{
    XCUIElement *backButton = [self waitBackButtonWithAccessibilityId:@"Back"
                                                              timeout:kUITestsBaseTimeout];
    if (!backButton) {
        backButton = [self waitBackButtonWithAccessibilityId:@"Library"
                                                     timeout:kUITestsBaseTimeout];
    }
    [backButton tap];
}

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

- (void)tryOpenFavoritePage
{
    NSString *libraryPageName = @"Favorites";
    [self tryOpenPageWithName:libraryPageName];
}

- (void)tryOpenPageWithName:(NSString *)pageName
{
    [self givenSideMenuNotVisible];
    [self tryTapSideApplicationMenu];
    XCUIElement *menuView = [self waitElementWithAccessibilityId:@"JMSideApplicationMenuAccessibilityId"
                                                         visible:true
                                                         timeout:kUITestsBaseTimeout];
    XCUIElement *pageMenuItem = menuView.cells.staticTexts[pageName];
    [self waitElement:pageMenuItem
              visible:true
              timeout:kUITestsBaseTimeout];
    [pageMenuItem tap];
}

#pragma mark - Helpers - Side (App) Menu

- (void)givenSideMenuVisible
{
    // Verify that side bar is already visible
    [self waitElementWithAccessibilityId:@"JMSideApplicationMenuAccessibilityId"
                                 visible:true
                                 timeout:kUITestsBaseTimeout];
}

- (void)givenSideMenuNotVisible
{
    // Verify that side bar isn't visible yet
    XCUIElement *sideMenu = [self findElementWithAccessibilityId:@"JMSideApplicationMenuAccessibilityId"];
    if (sideMenu) {
        XCTFail(@"Side menu should not be visible");
    }
}

- (void)tryTapSideApplicationMenu
{
    XCUIElement *menuButton = [self waitMenuButtonWithTimeout:kUITestsBaseTimeout];
    [menuButton tap];
}

#pragma mark - Helpers - Menu
- (BOOL)isShareButtonExists
{
    XCUIElement *actionsButton = [self findActionsButton];
    return actionsButton.exists;
}

#pragma mark - Verifies
- (void)verifyThatCurrentPageIsLibrary
{
    [self waitElementWithAccessibilityId:@"JMLibraryPageAccessibilityId"
                                 visible:true
                                 timeout:kUITestsBaseTimeout];
}

- (void)verifyThatCurrentPageIsRepository
{
    XCUIElement *repositoryNavBar = self.application.navigationBars[@"Repository"];
    NSPredicate *repositoryPagePredicate = [NSPredicate predicateWithFormat:@"self.exists == true"];
    
    [self expectationForPredicate:repositoryPagePredicate
              evaluatedWithObject:repositoryNavBar
                          handler:nil];
    [self waitForExpectationsWithTimeout:kUITestsBaseTimeout
                                 handler:nil];
}

#pragma mark - Verifies - Loading Popup
- (void)verifyThatLoadingPopupVisible
{
    [self waitElementWithAccessibilityId:@"JMCancelRequestPopupAccessibilityId"
                                 visible:true
                                 timeout:kUITestsResourceWaitingTimeout];
}

- (void)verifyThatLoadingPopupNotVisible
{
    [self waitElementWithAccessibilityId:@"JMCancelRequestPopupAccessibilityId"
                                 visible:false
                                 timeout:kUITestsResourceWaitingTimeout];
}

#pragma mark - JMBaseUITestProtocol
- (BOOL) shouldLoginBeforeStartTest
{
    return YES;
}

#pragma - Utils
- (void)closeKeyboardWithDoneButton
{
    XCUIElement *doneButton = [self waitDoneButtonWithTimeout:kUITestsBaseTimeout];
    [doneButton tap];
}

- (void)openMenuActions
{
    [self openMenuActionsOnNavBarWithLabel:nil];
}

- (void)openMenuActionsOnNavBarWithLabel:(NSString *)label
{
    XCUIElement *actionsButton = [self waitActionsButtonOnNavBarWithLabel:label
                                                                  timeout:kUITestsBaseTimeout];
    [actionsButton tap];
}

- (void)enterText:(NSString *)text intoTextFieldWithAccessibilityId:(NSString *)accessibilityId
    parentElement:(XCUIElement *)parentElement
    isSecureField:(BOOL)isSecureField
{
    XCUIElement *textField;
    if (isSecureField) {
        textField = [self waitSecureTextFieldWithAccessibilityId:accessibilityId
                                                   parentElement:parentElement
                                                         timeout:kUITestsBaseTimeout];
    } else {
        textField = [self waitTextFieldWithAccessibilityId:accessibilityId
                                             parentElement:parentElement
                                                   timeout:kUITestsBaseTimeout];
    }

    NSString *oldValueString = textField.value;
    if (oldValueString.length > 0 && [oldValueString isEqualToString:text]) {
        XCUIElement *deleteSymbolButton = self.application.keys[@"delete"];
        if (deleteSymbolButton.exists) {
            for (int i = 0; i < oldValueString.length; ++i) {
                [deleteSymbolButton tap];
            }
        }
    }

    [textField tap];
    [textField typeText:text];
    [self closeKeyboardWithDoneButton];
}

@end
