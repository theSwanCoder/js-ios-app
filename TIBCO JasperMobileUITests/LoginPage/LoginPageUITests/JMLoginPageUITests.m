/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.6
 */

#import "JMLoginPageUITests.h"
#import "JMBaseUITestCase+Helpers.h"
#import "JMBaseUITestCase+SideMenu.h"
#import "JMUITestServerProfileManager.h"
#import "JMUITestServerProfile.h"
#import "JMBaseUITestCase+LoginPage.h"
#import "JMBaseUITestCase+TextFields.h"
#import "JMBaseUITestCase+Buttons.h"
#import "JMBaseUITestCase+Alerts.h"

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
    [self logout];
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
    JMUITestServerProfile *testServerProfile = [JMUITestServerProfileManager sharedManager].testProfile;
    [self enterUsername:@""];
    [self enterPassword:testServerProfile.password];
    [self selectTestProfile];
    [self tapLoginButton];

    [self processErrorAlertIfExistWithTitle:@"Error"
                                    message:@"Specify a valid username."
                                actionBlock:nil];
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
    JMUITestServerProfile *testServerProfile = [JMUITestServerProfileManager sharedManager].testProfile;
    [self enterUsername:@"  "];
    [self enterPassword:testServerProfile.password];
    [self selectTestProfile];
    [self tapLoginButton];

    [self processErrorAlertIfExistWithTitle:JMLocalizedString(@"error_authenication_dialog_title")
                                    message:JMLocalizedString(@"error_authenication_dialog_msg")
                                actionBlock:nil];
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
    JMUITestServerProfile *testServerProfile = [JMUITestServerProfileManager sharedManager].testProfile;
    [self enterUsername:@"Wrong username"];
    [self enterPassword:testServerProfile.password];
    [self selectTestProfile];
    [self tapLoginButton];

    [self processErrorAlertIfExistWithTitle:JMLocalizedString(@"error_authenication_dialog_title")
                                    message:JMLocalizedString(@"error_authenication_dialog_msg")
                                actionBlock:nil];
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
    JMUITestServerProfile *testServerProfile = [JMUITestServerProfileManager sharedManager].testProfile;
    [self enterUsername:testServerProfile.username];
    [self enterPassword:@""];
    [self selectTestProfile];
    [self tapLoginButton];

    [self processErrorAlertIfExistWithTitle:JMLocalizedString(@"dialod_title_error")
                                    message:JMLocalizedString(@"login_password_errmsg_empty")
                                actionBlock:nil];
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
    JMUITestServerProfile *testServerProfile = [JMUITestServerProfileManager sharedManager].testProfile;
    [self enterUsername:testServerProfile.username];
    [self enterPassword:@"  "];
    [self selectTestProfile];
    [self tapLoginButton];

    [self processErrorAlertIfExistWithTitle:JMLocalizedString(@"error_authenication_dialog_title")
                                    message:JMLocalizedString(@"error_authenication_dialog_msg")
                                actionBlock:nil];
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
    JMUITestServerProfile *testServerProfile = [JMUITestServerProfileManager sharedManager].testProfile;
    [self enterUsername:testServerProfile.username];
    [self enterPassword:@"Wrong password"];
    [self selectTestProfile];
    [self tapLoginButton];

    [self processErrorAlertIfExistWithTitle:JMLocalizedString(@"error_authenication_dialog_title")
                                    message:JMLocalizedString(@"error_authenication_dialog_msg")
                                actionBlock:nil];
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
    JMUITestServerProfile *testServerProfile = [JMUITestServerProfileManager sharedManager].testProfile;
    [self enterUsername:testServerProfile.username];
    [self enterPassword:testServerProfile.password];
    [self tapLoginButton];

    [self processErrorAlertIfExistWithTitle:JMLocalizedString(@"dialod_title_error")
                                    message:JMLocalizedString(@"login_server_profile_errmsg_empty")
                                actionBlock:nil];
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
    JMUITestServerProfile *testServerProfile = [JMUITestServerProfileManager sharedManager].testProfile;
    [self enterUsername:testServerProfile.username];
    [self enterPassword:testServerProfile.password];
    [self selectTestProfile];
    [self tapLoginButton];

    [self waitLoginProcessDidFinish];
    [self verifyThatUserDidLoginIntoTestServer];
    [self logout];
}

#pragma mark - Verifying

- (void)verifyThatLaunchPageOnScreen
{
    // Skip for now because in this point we can see only login page (launch page was gone).
}

- (void)verifyThatLoginPageOnScreen
{
    XCUIElement *loginPage = [self waitElementMatchingType:XCUIElementTypeOther
                                                identifier:@"JMLoginPageAccessibilityId"
                                                   timeout:kUITestsBaseTimeout];
    if (!loginPage.exists) {
        XCTFail(@"Login Page isn't on screen");
    }
}

- (void)verifyThatLoginPageHasCorrectTrademarks
{
    XCUIElement *logoImage = [self findImageWithAccessibilityId:@"im_full_name"];
    if (!logoImage) {
        XCTFail(@"There isn't an trademark element on Login Page");
    }
}

- (void)verifyThatUserDidLoginIntoDemoServer
{
    BOOL isSuccess = [self isProfileWasLoggedWithUsername:@"phoneuser"
                                             organization:@"organization_1"
                                                    alias:@"Jaspersoft Mobile Demo"];
    if (!isSuccess) {
        XCTFail(@"Login within incorrect account");
    }
}

- (void)verifyThatUserDidLoginIntoTestServer
{
    JMUITestServerProfile *testServerProfile = [JMUITestServerProfileManager sharedManager].testProfile;
    BOOL isSuccess = [self isProfileWasLoggedWithUsername:testServerProfile.username
                                             organization:testServerProfile.organization
                                                    alias:testServerProfile.alias];
    if (!isSuccess) {
        XCTFail(@"Login within incorrect account");
    }
}

#pragma mark - Helpers

- (void)tapTryDemoButton
{
    XCUIElement *loginPageElement = [self waitElementMatchingType:XCUIElementTypeOther
                                                       identifier:@"JMLoginPageAccessibilityId"
                                                          timeout:kUITestsElementAvailableTimeout];
    [self tapButtonWithId:@"JMLoginPageTryButtonAccessibilityId"
            parentElement:loginPageElement
              shouldCheck:YES];
}

- (void)tapLoginButton
{
    XCUIElement *loginPageElement = [self waitElementMatchingType:XCUIElementTypeOther
                                                       identifier:@"JMLoginPageAccessibilityId"
                                                          timeout:kUITestsElementAvailableTimeout];
    [self tapButtonWithId:@"JMLoginPageLoginButtonAccessibilityId"
            parentElement:loginPageElement
              shouldCheck:YES];
}

- (void)waitLoginProcessDidFinish
{
    [self givenLoadingPopupNotVisible];
    [self verifyThatLoginProcessWasSuccess];
}

- (void)enterUsername:(NSString *)username
{
    XCUIElement *loginPageElement = [self waitElementMatchingType:XCUIElementTypeOther
                                                       identifier:@"JMLoginPageAccessibilityId"
                                                          timeout:0];
    [self enterText:username intoTextFieldWithAccessibilityId:@"JMLoginPageUserNameTextFieldAccessibilityId"
   placeholderValue:nil
      parentElement:loginPageElement
      isSecureField:false];
}

- (void)enterPassword:(NSString *)password
{
    XCUIElement *loginPageElement = [self waitElementMatchingType:XCUIElementTypeOther
                                                       identifier:@"JMLoginPageAccessibilityId"
                                                          timeout:kUITestsElementAvailableTimeout];
    [self enterText:password intoTextFieldWithAccessibilityId:@"JMLoginPagePasswordTextFieldAccessibilityId"
   placeholderValue:nil
      parentElement:loginPageElement
      isSecureField:true];
}

@end
