//
//  JMBaseUITestCase.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 2/18/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMBaseUITestCase.h"
#import "JMBaseUITestCase+Helpers.h"
#import "JMBaseUITestCase+SideMenu.h"
#import "JMBaseUITestCase+Section.h"
#import "JMUITestServerProfile.h"
#import "JMUITestServerProfileManager.h"

NSTimeInterval kUITestsBaseTimeout = 30;
NSTimeInterval kUITestsResourceWaitingTimeout = 60;
NSTimeInterval kUITestsElementAvailableTimeout = 2;

@implementation JMBaseUITestCase

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    XCUIApplication *app = self.application;
    @try {
        [app launch];
    } @catch(NSException *exception) {
        NSLog(@"Exception: %@", exception);
        XCTFail(@"Failed to launch application");
    }

    if ([self shouldLoginBeforeStartTest]) {
        [self loginWithTestProfileIfNeed];
        [self givenThatLibraryPageOnScreen];
    } else {
        XCUIElement *loginPageView = [self findElementWithAccessibilityId:@"JMLoginPageAccessibilityId"];
        if (!loginPageView) {
            [self skipIntroPageIfNeed];
            [self skipRateAlertIfNeed];
            [self logout];
        }
    }
}

- (void)tearDown {
//    XCUIElement *loginPageView = [self findElementWithAccessibilityId:@"JMLoginPageAccessibilityId"];
//    if (!loginPageView) {
//        [self logout];
//    }
    XCUIApplication *app = self.application;
    [app terminate];
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

    [self trySelectNewTestServerProfile];
}

- (XCUIElement *)findTestProfileCell
{
    XCUIElement *testProfile = [self findCollectionViewCellWithAccessibilityId:@"JMCollectionViewServerGridAccessibilityId"
                                 containsLabelWithAccessibilityId:@"Test Profile"
                                                        labelText:@"Test Profile"];
    BOOL isTestProfileExists = testProfile.exists;
    if (!isTestProfileExists) {
        [self removeAllServerProfiles];

        [self tryOpenNewServerProfilePage];
        [self givenThatNewProfilePageOnScreen];
        [self tryCreateNewTestServerProfile];

        [self givenThatServerProfilesPageOnScreen];
        
        testProfile = [self findCollectionViewCellWithAccessibilityId:@"JMCollectionViewServerGridAccessibilityId"
                                     containsLabelWithAccessibilityId:@"Test Profile"
                                                            labelText:@"Test Profile"];
        if (!testProfile.exists) {
            XCTFail(@"Can't create test profile");
        }
    }
    return testProfile;
}

- (void)removeAllServerProfiles
{
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
    XCUIApplication *app = self.application;
    XCUIElement *profile = [app.collectionViews.cells elementBoundByIndex:0];
    if (profile) {
        [profile pressForDuration:1.1];
        XCUIElement *menu = app.menuItems[@"Delete"];
        if (menu) {
            [menu tap];
            XCUIElement *deleteButton = [self waitButtonWithAccessibilityId:@"Delete"
                                                              parentElement:app.alerts[@"Confirmation"]
                                                                    timeout:kUITestsBaseTimeout];
            
            [deleteButton tap];
        } else {
            XCTFail(@"Delete menu item doesn't exist.");
        }
    } else {
        XCTFail(@"Server profile cell doesn't exist.");
    }
}

- (void)loginWithTestProfileIfNeed
{
    XCUIElement *loginPageView = [self findElementWithAccessibilityId:@"JMLoginPageAccessibilityId"];
    if (loginPageView) {
        [self loginWithTestProfile];
    } else {
        [self skipIntroPageIfNeed];
        [self skipRateAlertIfNeed];

        // check 'test profile' was logged
        [self showSideMenuInSectionWithName:nil];
        JMUITestServerProfile *testServerProfile = [JMUITestServerProfileManager sharedManager].testProfile;
        XCUIElement *profileNameLabel = [self findStaticTextWithText:testServerProfile.name];
        if (profileNameLabel.exists) {
            [self hideSideMenuInSectionWithName:nil];
        } else {
            [self logout];
            [self givenThatLoginPageOnScreen];
            [self loginWithTestProfile];
        }
    }
}

- (void)loginWithTestProfile
{
    [self selectTestProfile];

    [self givenThatLoginPageOnScreen];
    [self tryEnterTestCredentials];

    [self givenThatLoginPageOnScreen];
    [self tryTapLoginButton];

    [self givenLoadingPopupNotVisible];
}

- (void)logout
{
    [self selectLogOut];
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

    JMUITestServerProfile *testServerProfile = [JMUITestServerProfileManager sharedManager].testProfile;

    // Profile Name TextField
    [self enterText:testServerProfile.name intoTextFieldWithAccessibilityId:@"Profile name"
      parentElement:table
      isSecureField:false];

    // Profile URL TextField
    [self enterText:testServerProfile.url intoTextFieldWithAccessibilityId:@"Server address"
      parentElement:table
      isSecureField:false];

    // Organization TextField
    [self enterText:testServerProfile.organization intoTextFieldWithAccessibilityId:@"Organization ID"
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
        XCUIElement *okButton = [self waitButtonWithAccessibilityId:JMLocalizedString(@"dialog_button_ok")
                                                      parentElement:securityWarningAlert
                                                            timeout:kUITestsBaseTimeout];
        [okButton tap];
    }
}

- (void)tryBackToLoginPageFromProfilesPage
{
    [self tryBackToPreviousPage];
}

- (void)trySelectNewTestServerProfile
{
    XCUIElement *testProfile = [self findTestProfileCell];
    if (testProfile.exists) {
        [testProfile tap];
    } else {
        XCTFail(@"Test profile doesn't visible or exist");
    }
}

- (void)tryEnterTestCredentials
{
    JMUITestServerProfile *testServerProfile = [JMUITestServerProfileManager sharedManager].testProfile;

    // Enter username
    [self enterText:testServerProfile.username intoTextFieldWithAccessibilityId:@"JMLoginPageUserNameTextFieldAccessibilityId"
      parentElement:nil
      isSecureField:false];

    // Enter password
    [self enterText:testServerProfile.password intoTextFieldWithAccessibilityId:@"JMLoginPagePasswordTextFieldAccessibilityId"
      parentElement:nil
      isSecureField:true];
}

- (void)tryTapLoginButton
{
    XCUIElement *loginButton = [self waitButtonWithAccessibilityId:@"JMLoginPageLoginButtonAccessibilityId"
                                                           timeout:kUITestsBaseTimeout];
    [loginButton tap];
}


#pragma mark - Helpers
- (void)givenThatLoginPageOnScreen
{
    [self waitElementWithAccessibilityId:@"JMLoginPageAccessibilityId"
                                 timeout:kUITestsBaseTimeout];
}

- (void)givenThatServerProfilesPageOnScreen
{
    [self waitElementWithAccessibilityId:@"JMServerProfilesPageAccessibilityId"
                                 timeout:kUITestsBaseTimeout];
}

- (void)givenThatNewProfilePageOnScreen
{
    [self waitElementWithAccessibilityId:@"JMNewServerProfilePageAccessibilityId"
                                 timeout:kUITestsBaseTimeout];
}

- (void)givenThatLibraryPageOnScreen
{
    [self skipIntroPageIfNeed];
    [self skipRateAlertIfNeed];
    
    // Verify Library Page
    [self verifyThatCurrentPageIsLibrary];
}

- (void)givenThatRepositoryPageOnScreen
{
    [self verifyThatCurrentPageIsRepository];
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

- (void)givenThatListCellsAreVisible
{
    [self tryTapGridButton];
    [self givenThatCellsAreVisible];
}

- (void)tryTapGridButton
{
    XCUIElement *button = [self findButtonWithAccessibilityId:@"horizontal list button"];
    if (button) {
        [button tap];
    }
}

- (void)givenThatGridCellsAreVisible
{
    [self tryTapListButton];
    [self verifyThatCollectionViewContainsGridOfCells];
}


- (void)tryTapListButton
{
    XCUIElement *button = [self findButtonWithAccessibilityId:@"grid button"];
    if (button) {
        [button tap];
    }
}

- (void)givenThatReportCellsOnScreen
{
    [self selectFilterBy:@"Reports" inSectionWithTitle:@"Library"];
    [self givenThatListCellsAreVisible];
}

- (void)givenThatDashboardCellsOnScreen
{
    [self selectFilterBy:@"Dashboards" inSectionWithTitle:@"Library"];
    [self givenThatListCellsAreVisible];
}

- (void)skipIntroPageIfNeed
{
    XCUIElement *skipIntroButton;
    NSInteger attemptsCount = 3;
    for (NSInteger i = 0; i < attemptsCount; i++) {
        sleep(kUITestsElementAvailableTimeout);
        skipIntroButton = [self findButtonWithTitle:@"Skip Intro"];
        if (skipIntroButton.exists) {
            [skipIntroButton tap];
            break;
        }
    }
}

- (void)skipRateAlertIfNeed
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
// TODO: replace this method with 'tryBackToPreviousPageWithTitle:'
- (void)tryBackToPreviousPage
{
    XCUIElement *backButton = [self findBackButtonWithAccessibilityId:@"Back"];
    if (!backButton) {
        backButton = [self findBackButtonWithAccessibilityId:@"Library"];
    }
    [backButton tap];
}

- (void)tryBackToPreviousPageWithTitle:(NSString *)pageTitle
{
    XCUIElement *backButton = [self findBackButtonWithAccessibilityId:pageTitle];
    if (!backButton) {
        XCTFail(@"There isn't back button with title: %@", pageTitle);
    }
    [backButton tap];
}

#pragma mark - Verifies
- (void)verifyThatCurrentPageIsLibrary
{
    // TODO: replace with specific element - JMLibraryPageAccessibilityId
    [self waitElementWithAccessibilityId:@"JMBaseCollectionContentViewAccessibilityId"
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
- (void)givenLoadingPopupVisible
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [self waitElementWithAccessibilityId:@"JMCancelRequestPopupAccessibilityId"
                           parentElement:nil
                                 visible:true
                                 timeout:kUITestsResourceWaitingTimeout];
}

- (void)givenLoadingPopupNotVisible
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [self waitElementWithAccessibilityId:@"JMCancelRequestPopupAccessibilityId"
                           parentElement:nil
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

    [self enterText:text
      intoTextField:textField];
}

- (void)enterText:(NSString *)text
    intoTextField:(XCUIElement *)textField
{
    [textField tap];
    NSString *oldValueString = textField.value;
    BOOL isTextFieldContainText = oldValueString.length > 0;
    BOOL isTextFieldContainTheSameText = [oldValueString isEqualToString:text];
    
    if (isTextFieldContainText) {
        if (isTextFieldContainTheSameText) {
            [self closeKeyboardWithDoneButton];
        } else {
            [self replaceTextInTextField:textField 
                                withText:text];                        
        }
    } else {
        [textField typeText:text];
        [self closeKeyboardWithDoneButton];        
    }
}

- (void)replaceTextInTextField:(XCUIElement *)textField 
                      withText:(NSString *)text
{
    [self deleteTextFromTextField:textField];
    [textField typeText:text];
    [self closeKeyboardWithDoneButton];
}

- (void)deleteTextFromTextField:(XCUIElement *)textField
{
    NSString *oldValueString = textField.value;
    XCUIElement *keyboard = [self.application.keyboards elementBoundByIndex:0];
    XCUIElement *deleteSymbolButton = keyboard.keys[@"delete"];
    if (deleteSymbolButton.exists) {
        for (int i = 0; i < oldValueString.length; ++i) {
            [deleteSymbolButton tap];
        }
    }
}

@end
