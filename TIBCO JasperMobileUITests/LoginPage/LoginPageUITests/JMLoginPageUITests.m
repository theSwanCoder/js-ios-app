//
//  JMLoginPageUITests.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 2/19/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMLoginPageUITests.h"
#import "JMBaseUITestCase+Helpers.h"
#import "JMBaseUITestCase+SideMenu.h"

@implementation JMLoginPageUITests

#pragma mark - JMBaseUITestProtocol
- (BOOL) shouldLoginBeforeStartTest
{
    return NO;
}

#pragma mark - Tests

//- Launch screen
//    - Precondition:
//      - Launch Application ->
//    - Result:
//      - User should see Launch screen
//      - Copyright should be correct
- (void)testThatUserCanSeeLaunchScreen
{
    [self verifyThatLaunchPageOnScreen];
}

//- Log In screen
//    - Precondition:
//      - Launch Application ->
//      - Wait launch screen disappears ->
//    - Result:
//      - User should see Login screen
- (void)testThatUserCanSeeLoginScreen
{
    [self verifyThatLoginPageOnScreen];
}

//- TIBCO JasperMobile logo
//    - Precondition:
//      - Launch Application ->
//      - Wait launch screen disappears ->
//    - Result:
//      - User should see TIBCO JasperMobile logo
- (void)testThatUserCanSeeCorrectTrademarksOnLoginScreen
{
    [self verifyThatLoginPageHasCorrectTrademarks];
}

//- Try Demo Button
//    - Precondition:
//      - Launch Application ->
//      - Wait launch screen disappears ->
//    - Steps:
//      - Tap ‘Try Demo’ button
//    - Result:
//      - User should connect to Mobile Demo Server
- (void)testThatUserCanSeeLoginUsingTryDemoButton
{
    [self tapTryDemoButton];
    [self waitLoginProcessDidFinish];

    [self verifyThatUserDidLoginIntoDemoServer];
}

//- Try login with empty username
//    - Precondition:
//      - Launch Application ->
//      - Wait launch screen disappears ->
//    - Steps:
//      - Make ‘username’ field empty
//      - Enter right password into ‘password’ field
//      - Select test server
//      - Tap ‘Login’ button
//    - Result:
//      - User should see error message “Error. Specify a valid username’
- (void)testThatUserCanSeeErrorWhenTryLoginWithEmptyUsername
{
    [self enterUsername:@""];
    [self enterPassword:kJMTestProfileCredentialsPassword];
    [self selectTestProfile];
    [self tapLoginButton];

    [self verifyThatErrorAlertOnScreenWithTitle:JMLocalizedString(@"dialod_title_error") message:JMLocalizedString(@"login_username_errmsg_empty")];
    
    [self closeErrorAlertWithTitle:JMLocalizedString(@"dialod_title_error")];
}

//- Try login if username includes only spaces
//    - Precondition:
//      - Launch Application ->
//      - Wait launch screen disappears ->
//    - Steps:
//      - Enter spaces into ‘username’ field
//      - Enter right password into ‘password’ field
//      - Select test server
//      - Tap ‘Login’ button
//    - Result:
//      - User should see error message “Invalid credentials supplied. Could not login to JasperReports Server”
- (void)testThatUserCanSeeErrorWhenTryLoginWithSpacesInUsername
{
    [self enterUsername:@"  "];
    [self enterPassword:kJMTestProfileCredentialsPassword];
    [self selectTestProfile];
    [self tapLoginButton];
    
    [self verifyThatErrorAlertOnScreenWithTitle:JMLocalizedString(@"error_authenication_dialog_title") message:JMLocalizedString(@"error_authenication_dialog_msg")];
    
    [self closeErrorAlertWithTitle:JMLocalizedString(@"error_authenication_dialog_title")];
}

//- Try login if username is incorrect
//    - Precondition:
//      - Launch Application ->
//      - Wait launch screen disappears ->
//    - Steps:
//      - Enter wrong username into ‘username’ field
//      - Enter right password into ‘password’ field
//      - Select test server
//      - Tap ‘Login’ button
//    - Result:
//      - User should see error message “Invalid credentials supplied. Could not login to JasperReports Server”
- (void)testThatUserCanSeeErrorWhenTryLoginWithWrongUsername
{
    [self enterUsername:@"Wrong username"];
    [self enterPassword:kJMTestProfileCredentialsPassword];
    [self selectTestProfile];
    [self tapLoginButton];
    
    [self verifyThatErrorAlertOnScreenWithTitle:JMLocalizedString(@"error_authenication_dialog_title") message:JMLocalizedString(@"error_authenication_dialog_msg")];
    
    [self closeErrorAlertWithTitle:JMLocalizedString(@"error_authenication_dialog_title")];
}

//- Try login with empty password
//    - Precondition:
//      - Launch Application ->
//      - Wait launch screen disappears ->
//    - Steps:
//      - Enter right username into ‘username’ field
//      - Make ‘password’ field empty
//      - Select test server
//      - Tap ‘Login’ button
//    - Result:
//      - User should see error message “Error. Specify a valid password”
- (void)testThatUserCanSeeErrorWhenTryLoginWithEmptyPassword
{
    [self enterUsername:kJMTestProfileCredentialsUsername];
    [self enterPassword:@""];
    [self selectTestProfile];
    [self tapLoginButton];
    
    [self verifyThatErrorAlertOnScreenWithTitle:JMLocalizedString(@"dialod_title_error") message:JMLocalizedString(@"login_password_errmsg_empty")];
    
    [self closeErrorAlertWithTitle:JMLocalizedString(@"dialod_title_error")];
}

//- Try login if password includes only spaces
//    - Precondition:
//      - Launch Application ->
//      - Wait launch screen disappears ->
//    - Steps:
//      - Enter right username into ‘username’ field
//      - Enter spaces into ‘password’ field
//      - Select test server
//      - Tap ‘Login’ button
//    - Result:
//      - User should see error message “Invalid credentials supplied. Could not login to JasperReports Server”
- (void)testThatUserCanSeeErrorWhenTryLoginWithSpacesInPassword
{
    [self enterUsername:kJMTestProfileCredentialsUsername];
    [self enterPassword:@"  "];
    [self selectTestProfile];
    [self tapLoginButton];

    [self verifyThatErrorAlertOnScreenWithTitle:JMLocalizedString(@"error_authenication_dialog_title") message:JMLocalizedString(@"error_authenication_dialog_msg")];
    
    [self closeErrorAlertWithTitle:JMLocalizedString(@"error_authenication_dialog_title")];
}

//- Try login if password is incorrect
//    - Precondition:
//    - Launch Application ->
//    - Wait launch screen disappears ->
//    - Steps:
//    - Enter right username into ‘username’ field
//    - Enter wrong password into ‘password’ field
//    - Select test server
//    - Tap ‘Login’ button
//    - Result:
//    - User should see error message “Invalid credentials supplied. Could not login to JasperReports Server”
- (void)testThatUserCanSeeErrorWhenTryLoginWithWrongPassword
{
    [self enterUsername:kJMTestProfileCredentialsUsername];
    [self enterPassword:@"Wrong password"];
    [self selectTestProfile];
    [self tapLoginButton];
    
    [self verifyThatErrorAlertOnScreenWithTitle:JMLocalizedString(@"error_authenication_dialog_title") message:JMLocalizedString(@"error_authenication_dialog_msg")];
    
    [self closeErrorAlertWithTitle:JMLocalizedString(@"error_authenication_dialog_title")];
}

//- Try login with empty server
//    - Precondition:
//    - Launch Application ->
//    - Wait launch screen disappears ->
//    - Steps:
//    - Enter right username into ‘username’ field
//    - Enter right password into ‘password’ field
//    - Don’t Select any server
//    - Tap ‘Login’ button
//    - Result:
//    - User should see error message “Error. Select a server profile”
- (void)testThatUserCanSeeErrorWhenTryLoginWithoutSelectedServer
{
    [self enterUsername:kJMTestProfileCredentialsUsername];
    [self enterPassword:kJMTestProfileCredentialsPassword];
    [self tapLoginButton];
    
    [self verifyThatErrorAlertOnScreenWithTitle:JMLocalizedString(@"dialod_title_error") message:JMLocalizedString(@"login_server_profile_errmsg_empty")];
    
    [self closeErrorAlertWithTitle:JMLocalizedString(@"dialod_title_error")];
}

//- Try login with valid credentials
//    - Precondition:
//    - Launch Application ->
//    - Wait launch screen disappears ->
//    - Steps:
//    - Enter right username into ‘username’ field
//    - Enter right password into ‘password’ field
//    - Select test server
//    - Tap ‘Login’ button
//    - Result:
//    - User should see Library screen
- (void)testThatUserCanLoginToTestServer
{
    [self enterUsername:kJMTestProfileCredentialsUsername];
    [self enterPassword:kJMTestProfileCredentialsPassword];
    [self selectTestProfile];
    [self tapLoginButton];

    [self waitLoginProcessDidFinish];
    [self verifyThatUserDidLoginIntoTestServer];
}

#pragma mark - Verifying

- (void)verifyThatLaunchPageOnScreen
{
    // Skip for now because in this point we can see only login page (launch page was gone).
}

- (void)verifyThatLoginPageOnScreen
{
    [self waitElementWithAccessibilityId:JMLoginPageAccessibilityId
                                 timeout:kUITestsBaseTimeout];
}

- (void)verifyThatLoginPageHasCorrectTrademarks
{
    XCUIElement *logoImage = [self findImageWithAccessibilityId:JMLoginPageTradeMarkImageAccessibilityId];
    if (!logoImage) {
        XCTFail(@"There isn't an trademark element on Login Page");
    }
}

- (void)verifyThatUserDidLoginIntoDemoServer
{
    [self showSideMenuInSectionWithAccessibilityId:JMLibraryPageAccessibilityId];
    [self verifyAccountWithUsername:kJMDemoServerUsername
                       organization:kJMDemoServerOrganization
                        profileName:kJMDemoServerAlias];
    [self hideSideMenuInSectionWithAccessibilityId:JMLibraryPageAccessibilityId];
}

- (void)verifyThatErrorAlertOnScreenWithTitle:(NSString *)title message:(NSString *)message
{
    XCUIElement *alert = [self waitAlertWithTitle:title
                                          timeout:kUITestsBaseTimeout];
    XCUIElement *errorMessageElement = [self findStaticTextWithText:message
                                                      parentElement:alert];
    if (!errorMessageElement) {
        XCTFail(@"Wrong message on '%@' alert", title);
    }
}

- (void)verifyThatUserDidLoginIntoTestServer
{
    [self showSideMenuInSectionWithAccessibilityId:JMLibraryPageAccessibilityId];
    [self verifyAccountWithUsername:kJMTestProfileCredentialsUsername
                       organization:kJMTestProfileCredentialsOrganization
                        profileName:kJMTestProfileName];
    [self hideSideMenuInSectionWithAccessibilityId:JMLibraryPageAccessibilityId];
}

- (void)verifyAccountWithUsername:(NSString *)username
                     organization:(NSString *)organization
                      profileName:(NSString *)profileName
{
    XCUIElement *sideMenuElement = [self waitElementWithAccessibilityId:JMSideApplicationMenuAccessibilityId
                                                                timeout:kUITestsBaseTimeout];
    XCUIElement *usernameStaticText = [self findStaticTextWithText:username
                                                     parentElement:sideMenuElement];
    if (!usernameStaticText) {
        XCTFail(@"Error of verifying 'Demo' account: username - is wrong");
    }
    if (organization && organization.length) {
        XCUIElement *organizationStaticText = [self findStaticTextWithText:organization
                                                             parentElement:sideMenuElement];
        if (!organizationStaticText) {
            XCTFail(@"Error of verifying 'Demo' account: organization - is wrong");
        }
    }
    XCUIElement *serverProfileStaticText = [self findStaticTextWithText:profileName
                                                          parentElement:sideMenuElement];
    if (!serverProfileStaticText) {
        XCTFail(@"Error of verifying 'Demo' account: server profile - is wrong");
    }
}

#pragma mark - Helpers

- (void)tapTryDemoButton
{
    XCUIElement *loginPageElement = [self findElementWithAccessibilityId:JMLoginPageAccessibilityId];
    XCUIElement *demoButton = [self findButtonWithAccessibilityId:JMLoginPageTryButtonAccessibilityId
                                                    parentElement:loginPageElement];
    if (demoButton) {
        [demoButton tap];
    } else {
        XCTFail(@"There isn't an 'Try Demo' button on Login Page");
    }
}

- (void)tapLoginButton
{
    XCUIElement *loginPageElement = [self findElementWithAccessibilityId:JMLoginPageAccessibilityId];
    XCUIElement *loginButton = [self findButtonWithAccessibilityId:JMLoginPageLoginButtonAccessibilityId
                                                    parentElement:loginPageElement];
    if (loginButton) {
        [loginButton tap];
    } else {
        XCTFail(@"There isn't an 'Login' button on Login Page");
    }
}

- (void)waitLoginProcessDidFinish
{
    [self givenLoadingPopupNotVisible];
}

- (void)enterUsername:(NSString *)username
{
    XCUIElement *loginPageElement = [self findElementWithAccessibilityId:JMLoginPageAccessibilityId];
    [self enterText:username intoTextFieldWithAccessibilityId:JMLoginPageUserNameTextFieldAccessibilityId
      parentElement:loginPageElement
      isSecureField:false];
}

- (void)enterPassword:(NSString *)password
{
    XCUIElement *loginPageElement = [self findElementWithAccessibilityId:JMLoginPageAccessibilityId];
    [self enterText:password intoTextFieldWithAccessibilityId:JMLoginPagePasswordTextFieldAccessibilityId
      parentElement:loginPageElement
      isSecureField:true];
}

- (void)closeErrorAlertWithTitle:(NSString *)title
{
    XCUIElement *alert = [self findAlertWithTitle:title];
    XCUIElement *okButton = [self findButtonWithTitle:JMLocalizedString(@"dialog_button_ok")    // Here we use localized string because AlertAction hasn't accessibilityIdentifier
                                        parentElement:alert];
    if (okButton) {
        [okButton tap];
    } else {
        XCTFail(@"Error of finding 'OK' button");
    }
}

@end
