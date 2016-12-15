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

    [self verifyThatErrorAlertOnScreenWithTitle:@"Error" message:@"Specify a valid username."];
    
    [self closeErrorAlertWithTitle:@"Error"];
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
    
    [self verifyThatErrorAlertOnScreenWithTitle:@"Invalid credentials supplied." message:@"Could not login to JasperReports Server."];
    
    [self closeErrorAlertWithTitle:@"Invalid credentials supplied."];
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
    
    [self verifyThatErrorAlertOnScreenWithTitle:@"Invalid credentials supplied." message:@"Could not login to JasperReports Server."];
    
    [self closeErrorAlertWithTitle:@"Invalid credentials supplied."];
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
    
    [self verifyThatErrorAlertOnScreenWithTitle:@"Error" message:@"Specify a valid password."];
    
    [self closeErrorAlertWithTitle:@"Error"];
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

    [self verifyThatErrorAlertOnScreenWithTitle:@"Invalid credentials supplied." message:@"Could not login to JasperReports Server."];
    
    [self closeErrorAlertWithTitle:@"Invalid credentials supplied."];
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
    
    [self verifyThatErrorAlertOnScreenWithTitle:@"Invalid credentials supplied." message:@"Could not login to JasperReports Server."];
    
    [self closeErrorAlertWithTitle:@"Invalid credentials supplied."];
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
    
    [self verifyThatErrorAlertOnScreenWithTitle:@"Error" message:@"Select a server profile."];
    
    [self closeErrorAlertWithTitle:@"Error"];
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
}

#pragma mark - Verifying

- (void)verifyThatLaunchPageOnScreen
{
    // Skip for now because in this point we can see only login page (launch page was gone).
}

- (void)verifyThatLoginPageOnScreen
{
    [self waitElementMatchingType:XCUIElementTypeOther
                       identifier:@"JMLoginPageAccessibilityId"
                          timeout:kUITestsBaseTimeout];
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
    [self showSideMenuInSectionWithName:nil];
    [self verifyAccountWithUsername:@"phoneuser"
                       organization:@"organization_1"
                        profileName:@"Jaspersoft Mobile Demo"];
    [self hideSideMenuInSectionWithName:nil];
}

- (void)verifyThatErrorAlertOnScreenWithTitle:(NSString *)title message:(NSString *)message
{
    XCUIElement *alert = [self waitAlertWithTitle:title
                                          timeout:kUITestsBaseTimeout];
    XCUIElement *errorMessageElement = [self waitElementMatchingType:XCUIElementTypeStaticText
                                                                text:message
                                                       parentElement:alert
                                                             timeout:kUITestsElementAvailableTimeout];
    if (!errorMessageElement.exists) {
        XCTFail(@"Wrong message on '%@' alert", title);
    }
}

- (void)verifyThatUserDidLoginIntoTestServer
{
    JMUITestServerProfile *testServerProfile = [JMUITestServerProfileManager sharedManager].testProfile;
    [self showSideMenuInSectionWithName:nil];
    [self verifyAccountWithUsername:testServerProfile.username
                       organization:testServerProfile.organization
                        profileName:testServerProfile.name];
    [self hideSideMenuInSectionWithName:nil];
}

- (void)verifyAccountWithUsername:(NSString *)username
                     organization:(NSString *)organization
                      profileName:(NSString *)profileName
{
    XCUIElement *sideMenuElement = [self waitElementMatchingType:XCUIElementTypeOther
                                                      identifier:@"JMSideApplicationMenuAccessibilityId"
                                                         timeout:kUITestsBaseTimeout];
    XCUIElement *usernameStaticText = [self waitElementMatchingType:XCUIElementTypeStaticText
                                                               text:username
                                                      parentElement:sideMenuElement
                                                            timeout:kUITestsElementAvailableTimeout];
    if (!usernameStaticText) {
        XCTFail(@"Error of verifying 'Demo' account: username - is wrong");
    }
    if (organization && organization.length) {
        XCUIElement *organizationStaticText = [self waitElementMatchingType:XCUIElementTypeStaticText
                                                                       text:organization
                                                              parentElement:sideMenuElement
                                                                    timeout:kUITestsElementAvailableTimeout];
        if (!organizationStaticText) {
            XCTFail(@"Error of verifying 'Demo' account: organization - is wrong");
        }
    }
    XCUIElement *serverProfileStaticText = [self waitElementMatchingType:XCUIElementTypeStaticText
                                                                    text:profileName
                                                           parentElement:sideMenuElement
                                                                 timeout:kUITestsElementAvailableTimeout];
    if (!serverProfileStaticText) {
        XCTFail(@"Error of verifying 'Demo' account: server profile - is wrong");
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
    [self verifyThatLoginWasSuccess];
}

- (void)enterUsername:(NSString *)username
{
    XCUIElement *loginPageElement = [self waitElementMatchingType:XCUIElementTypeOther
                                                       identifier:@"JMLoginPageAccessibilityId"
                                                          timeout:kUITestsElementAvailableTimeout];
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

- (void)closeErrorAlertWithTitle:(NSString *)title
{
    // TODO: move for using all tests
    XCUIElement *alert = [self findAlertWithTitle:title];
    [self tapButtonWithText:JMLocalizedString(@"dialog_button_ok")
              parentElement:alert
                shouldCheck:YES];
}

@end
