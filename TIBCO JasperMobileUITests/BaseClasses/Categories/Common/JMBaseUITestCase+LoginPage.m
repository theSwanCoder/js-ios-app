//
// Created by Aleksandr Dakhno on 12/10/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMBaseUITestCase+LoginPage.h"
#import "JMUITestServerProfileManager.h"
#import "JMUITestServerProfile.h"
#import "JMBaseUITestCase+Buttons.h"
#import "JMBaseUITestCase+Helpers.h"
#import "JMBaseUITestCase+SideMenu.h"
#import "JMBaseUITestCase+Section.h"
#import "JMBaseUITestCase+TextFields.h"
#import "JMBaseUITestCase+OtherElements.h"
#import "XCUIElement+Tappable.h"
#import "JMBaseUITestCase+Cells.h"
#import "JMBaseUITestCase+Alerts.h"


@implementation JMBaseUITestCase (LoginPage)

- (void)loginWithTestProfileIfNeed
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    XCUIElement *libraryPageView = [self libraryPageViewElement];
    if (libraryPageView) {
        BOOL isTestProfileWasLogged = [self isTestProfileWasLogged];
        if (isTestProfileWasLogged) {
            return;
        } else {
            [self logout];
        }
    }
    [self loginWithTestProfile];
    [self verifyThatLoginProcessWasSuccess];
}

- (void)loginWithTestProfile
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    [self givenThatLoginPageOnScreen];
    [self selectTestProfile];

    [self givenThatLoginPageOnScreen];
    [self tryEnterTestCredentials];

    [self givenThatLoginPageOnScreen];
    [self tryTapLoginButton];

    [self givenLoadingPopupNotVisible];
}

- (void)selectTestProfile
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    [self tryOpenServerProfilesPage];

    [self givenThatServerProfilesPageOnScreen];

    [self trySelectNewTestServerProfile];
}

- (XCUIElement *)findTestProfileCell
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    JMUITestServerProfile *testServerProfile = [JMUITestServerProfileManager sharedManager].testProfile;
    NSString *testProfileName = testServerProfile.alias;
    XCUIElement *testProfile = [self findCollectionViewCellWithAccessibilityId:@"JMCollectionViewServerGridAccessibilityId"
                                              containsLabelWithAccessibilityId:testProfileName
                                                                     labelText:testProfileName];
    BOOL isTestProfileExists = testProfile.exists;
    if (!isTestProfileExists) {
        [self removeAllServerProfiles];

        [self tryOpenNewServerProfilePage];
        [self givenThatNewProfilePageOnScreen];
        [self tryCreateNewTestServerProfile];

        [self givenThatServerProfilesPageOnScreen];

        testProfile = [self findCollectionViewCellWithAccessibilityId:@"JMCollectionViewServerGridAccessibilityId"
                                     containsLabelWithAccessibilityId:testProfileName
                                                            labelText:testProfileName];
        if (!testProfile.exists) {
            XCTFail(@"Can't create test profile");
        }
    }
    return testProfile;
}

- (void)removeAllServerProfiles
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    while(true) {
        NSInteger cellsCount = [self countCellsWithAccessibilityId:@"JMCollectionViewServerGridAccessibilityId"];
        if (cellsCount == 0) {
            break;
        }
        [self removeFirstServerProfile];
    }
}

- (void)removeFirstServerProfile
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    XCUIApplication *app = self.application;
    XCUIElement *profile = [app.collectionViews.cells elementBoundByIndex:0];
    if (profile) {
        [profile pressForDuration:1.1];
        XCUIElement *menu = app.menuItems[@"Delete"];
        if (menu) {
            [menu tapByWaitingHittable];
            XCUIElement *alert = [self waitAlertWithTitle:@"Confirmation"
                                                  timeout:kUITestsBaseTimeout];
            [self tapButtonWithText:@"Delete"
                      parentElement:alert
                        shouldCheck:YES];
        } else {
            XCTFail(@"Delete menu item doesn't exist.");
        }
    } else {
        XCTFail(@"Server profile cell doesn't exist.");
    }
}

- (void)verifyThatLoginProcessWasSuccess
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    NSLog(@"Verify that there isn't an error after trying to log into test JRS");

    NSArray *titles = @[@"JSHTTPErrorDomain", @"Invalid credentials supplied."];
    [self processErrorAlertsIfExistWithTitles:titles actionBlock:^{
        NSLog(@"All 'other elements': %@", [self.application.otherElements allElementsBoundByAccessibilityElement]);
        NSLog(@"All static texts: %@", [self.application.staticTexts allElementsBoundByAccessibilityElement]);
        NSLog(@"All text fields: %@", [self.application.textFields allElementsBoundByAccessibilityElement]);
        NSLog(@"All security text fields: %@", [self.application.secureTextFields allElementsBoundByAccessibilityElement]);

        NSLog(@"Try recreate test JRS profile");
        [self tryOpenServerProfilesPage];
        [self removeAllServerProfiles];
        [self trySelectNewTestServerProfile];

        NSLog(@"Try log into test JRS again");
        [self tryTapLoginButton];
        [self givenLoadingPopupNotVisible];
    }];

    [self processErrorAlertsIfExistWithTitles:titles actionBlock:^{
        XCTFail(@"Failure to log into test JRS");
    }];
}

- (BOOL)isTestProfileWasLogged
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    JMUITestServerProfile *testServerProfile = [JMUITestServerProfileManager sharedManager].testProfile;
    return [self isProfileWasLoggedWithUsername:testServerProfile.username
                                   organization:testServerProfile.organization
                                          alias:testServerProfile.alias];
}

- (BOOL)isProfileWasLoggedWithUsername:(NSString *)username
                          organization:(NSString *)organization
                                 alias:(NSString *)alias
{
    [self showSideMenuInSectionWithName:nil];

    XCUIElement *sideMenuElement = [self waitElementMatchingType:XCUIElementTypeOther
                                                      identifier:@"JMSideApplicationMenuAccessibilityId"
                                                         timeout:0];
    XCUIElement *usernameStaticText = [self waitElementMatchingType:XCUIElementTypeStaticText
                                                               text:username
                                                      parentElement:sideMenuElement
                                                            timeout:kUITestsElementAvailableTimeout];
    BOOL isUsernameCorrect = usernameStaticText.exists;

    BOOL isOrganizationCorrect = YES;
    if (organization && organization.length) {
        XCUIElement *organizationStaticText = [self waitElementMatchingType:XCUIElementTypeStaticText
                                                                       text:organization
                                                              parentElement:sideMenuElement
                                                                    timeout:kUITestsElementAvailableTimeout];
        isOrganizationCorrect = organizationStaticText.exists;
    }
    XCUIElement *aliasStaticText = [self waitElementMatchingType:XCUIElementTypeStaticText
                                                            text:alias
                                                   parentElement:sideMenuElement
                                                         timeout:kUITestsElementAvailableTimeout];
    BOOL isAliasCorrect = aliasStaticText.exists;
    [self hideSideMenuInSectionWithName:nil];

    return isUsernameCorrect && isOrganizationCorrect && isAliasCorrect;
}

- (void)logout
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    [self selectLogOut];
}

#pragma mark - Helpers Test Profile
- (void)tryOpenServerProfilesPage
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    XCUIElement *serverProfileTextField = [self waitElementMatchingType:XCUIElementTypeTextField
                                                             identifier:@"JMLoginPageServerProfileTextFieldAccessibilityId"
                                                                timeout:0];
    if (serverProfileTextField.exists) {
        [serverProfileTextField tapByWaitingHittable];
    } else {
        XCTFail(@"Server profile text field wasn't found");
    }
}

- (void)tryOpenNewServerProfilePage
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    [self tapButtonWithId:@"JMServerProfilesPageAddNewProfileButtonAccessibilityId"
            parentElement:nil
              shouldCheck:YES];
}

- (void)tryCreateNewTestServerProfile
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));

    XCUIApplication *app = self.application;
    XCUIElement *table = [app.tables elementBoundByIndex:0];

    JMUITestServerProfile *testServerProfile = [JMUITestServerProfileManager sharedManager].testProfile;
    NSLog(@"All text fields: %@", [app.textFields allElementsBoundByAccessibilityElement]);
    NSLog(@"testServerProfile.name: %@", testServerProfile.alias);
    NSLog(@"testServerProfile.url: %@", testServerProfile.url);
    NSLog(@"testServerProfile.username: %@", testServerProfile.username);
    NSLog(@"testServerProfile.password: %@", testServerProfile.password);
    NSLog(@"testServerProfile.organization: %@", testServerProfile.organization);

    // Profile Name TextField
    [self enterText:testServerProfile.alias intoTextFieldWithAccessibilityId:@"Profile name"
   placeholderValue:@"Profile name"
      parentElement:table
      isSecureField:false];

    // Profile URL TextField
    [self enterText:testServerProfile.url intoTextFieldWithAccessibilityId:@"Server address"
   placeholderValue:@"Server address"
      parentElement:table
      isSecureField:false];

    // Organization TextField
    [self enterText:testServerProfile.organization intoTextFieldWithAccessibilityId:@"Organization ID"
   placeholderValue:@"Organization ID"
      parentElement:table
      isSecureField:false];

    // Save a new created profile
    [self tapButtonWithText:@"Save"
              parentElement:nil
                shouldCheck:YES];

    // Confirm if need http end point
    [self closeSecurityWarningAlert];
}

- (void)closeSecurityWarningAlert
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    XCUIElement *securityWarningAlert = self.application.alerts[@"Warning"];
    if (securityWarningAlert.exists) {
        [self tapButtonWithText:JMLocalizedString(@"dialog_button_ok")
                  parentElement:securityWarningAlert
                    shouldCheck:YES];
    }
}

- (void)tryBackToLoginPageFromProfilesPage
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    [self tryBackToPreviousPage];
}

- (void)trySelectNewTestServerProfile
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    XCUIElement *testProfile = [self findTestProfileCell];
    if (testProfile.exists) {
        [testProfile tapByWaitingHittable];
    } else {
        XCTFail(@"Test profile doesn't visible or exist");
    }
}

- (void)tryEnterTestCredentials
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    JMUITestServerProfile *testServerProfile = [JMUITestServerProfileManager sharedManager].testProfile;

    // Enter username
    [self enterText:testServerProfile.username intoTextFieldWithAccessibilityId:@"JMLoginPageUserNameTextFieldAccessibilityId"
   placeholderValue:nil
      parentElement:nil
      isSecureField:false];

    // Enter password
    [self enterText:testServerProfile.password intoTextFieldWithAccessibilityId:@"JMLoginPagePasswordTextFieldAccessibilityId"
   placeholderValue:nil
      parentElement:nil
      isSecureField:true];
}

- (void)tryTapLoginButton
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    [self tapButtonWithId:@"JMLoginPageLoginButtonAccessibilityId"
            parentElement:nil
              shouldCheck:YES];
}

- (void)givenThatLoginPageOnScreen
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    [self verifyThatElementWithIdExist:@"JMLoginPageAccessibilityId"];
}

- (void)givenThatServerProfilesPageOnScreen
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    [self verifyThatElementWithIdExist:@"JMServerProfilesPageAccessibilityId"];
}

- (void)givenThatNewProfilePageOnScreen
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    [self verifyThatElementWithIdExist:@"JMNewServerProfilePageAccessibilityId"];
}

@end