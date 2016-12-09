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

NSTimeInterval kUITestsBaseTimeout = 20;
NSTimeInterval kUITestsResourceWaitingTimeout = 30;
NSTimeInterval kUITestsElementAvailableTimeout = 3;

@implementation JMBaseUITestCase

- (void)setUp {
    [super setUp];
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
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

    [self skipRateAlertIfNeed];
    [self skipIntroPageIfNeed];

    if ([self shouldLoginBeforeStartTest]) {
        NSLog(@"Try to log in before starting tests");
        [self loginWithTestProfileIfNeed];
        [self givenThatLibraryPageOnScreen];
    } else {
        NSLog(@"Perform tests without logging in");
        NSLog(@"All 'other elements':\n%@", [self.application.otherElements allElementsBoundByAccessibilityElement]);
        NSLog(@"All buttons:\n%@", [self.application.buttons allElementsBoundByAccessibilityElement]);
        NSLog(@"All alerts:\n%@", [self.application.alerts allElementsBoundByAccessibilityElement]);
        XCUIElement *libraryPageView = [self libraryPageViewElement];
        if (libraryPageView.exists) {
            NSLog(@"Library page on screen");
            [self logout];
        } else {
            NSLog(@"Login page on screen");
        }
    }
}

- (void)tearDown {
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    XCUIApplication *app = self.application;
    [app terminate];
    self.application = nil;
    
    [super tearDown];
}

#pragma mark - Custom Accessors
- (XCUIApplication *)application
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    if (!_application) {
        _application = [XCUIApplication new];
    }
    return _application;
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
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    JMUITestServerProfile *testServerProfile = [JMUITestServerProfileManager sharedManager].testProfile;
    NSString *testProfileName = testServerProfile.name;
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
            [menu tap];
            XCUIElement *alert = [self waitAlertWithTitle:@"Confirmation"
                                                  timeout:kUITestsBaseTimeout];
            XCUIElement *deleteButton = [self waitElementMatchingType:XCUIElementTypeButton
                                                                 text:@"Delete"
                                                        parentElement:alert
                                                              timeout:0];
            if (deleteButton.exists) {
                [deleteButton tap];
            } else {
                XCTFail(@"Delete button wasn't found");
            }
        } else {
            XCTFail(@"Delete menu item doesn't exist.");
        }
    } else {
        XCTFail(@"Server profile cell doesn't exist.");
    }
}

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
    [self verifyThatLoginWasSuccess];
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

- (void)verifyThatLoginWasSuccess
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    NSLog(@"Verify that there isn't an error after trying to log into test JRS");

    NSLog(@"All 'other elements': %@", [self.application.otherElements allElementsBoundByAccessibilityElement]);
    NSLog(@"All static texts: %@", [self.application.staticTexts allElementsBoundByAccessibilityElement]);
    NSLog(@"All text fields: %@", [self.application.textFields allElementsBoundByAccessibilityElement]);
    NSLog(@"All security text fields: %@", [self.application.secureTextFields allElementsBoundByAccessibilityElement]);

    NSArray *titles = @[@"JSHTTPErrorDomain", @"Invalid credentials supplied."];
    [self processErrorAlertsIfExistWithTitles:titles actionBlock:^{
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

- (void)processErrorAlertsIfExistWithTitles:(NSArray *)titles
                                actionBlock:(void(^)(void))actionBlock
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    sleep(kUITestsElementAvailableTimeout);
    NSLog(@"All alerts: %@", [self.application.alerts allElementsBoundByAccessibilityElement]);

    XCUIElement *alert;

    for(NSString *title in titles) {
        alert = [self findAlertWithTitle:title];
        if (alert.exists) {
            break;
        }
    }

    if (alert.exists) {
        [self tapButtonWithText:JMLocalizedString(@"dialog_button_ok")
                  parentElement:alert];

        if (actionBlock) {
            actionBlock();
        }
    } else {
        NSLog(@"There are no any error alerts");
    }
}

- (BOOL)isTestProfileWasLogged
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    [self showSideMenuInSectionWithName:nil];
    
    JMUITestServerProfile *testServerProfile = [JMUITestServerProfileManager sharedManager].testProfile;
    // Test Profile Name
    XCUIElement *profileNameLabel = [self waitElementMatchingType:XCUIElementTypeStaticText
                                                             text:testServerProfile.name
                                                          timeout:0];
    BOOL isProfileNameLabelExist = profileNameLabel.exists;
    // Test Profile Username
    XCUIElement *profileUsernameLabel = [self waitElementMatchingType:XCUIElementTypeStaticText
                                                                 text:testServerProfile.username
                                                              timeout:0];
    BOOL isProfileUsernameLabelExist = profileUsernameLabel.exists;
    
    [self hideSideMenuInSectionWithName:nil];
    return isProfileNameLabelExist && isProfileUsernameLabelExist;
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
                                                                timeout:kUITestsBaseTimeout];
    if (serverProfileTextField.exists) {
        [serverProfileTextField tap];
    } else {
        XCTFail(@"Server profile text field wasn't found");
    }
}

- (void)tryOpenNewServerProfilePage
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    [self tapButtonWithId:@"JMServerProfilesPageAddNewProfileButtonAccessibilityId"
            parentElement:nil];
}

- (void)tryCreateNewTestServerProfile
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));

    XCUIApplication *app = self.application;
    XCUIElement *table = [app.tables elementBoundByIndex:0];

    JMUITestServerProfile *testServerProfile = [JMUITestServerProfileManager sharedManager].testProfile;
    NSLog(@"All text fields: %@", [app.textFields allElementsBoundByAccessibilityElement]);
    NSLog(@"testServerProfile.name: %@", testServerProfile.name);
    NSLog(@"testServerProfile.url: %@", testServerProfile.url);
    NSLog(@"testServerProfile.username: %@", testServerProfile.username);
    NSLog(@"testServerProfile.password: %@", testServerProfile.password);
    NSLog(@"testServerProfile.organization: %@", testServerProfile.organization);

    // Profile Name TextField
    [self enterText:testServerProfile.name intoTextFieldWithAccessibilityId:@"Profile name"
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
              parentElement:nil];
    
    // Confirm if need http end point
    [self closeSecurityWarningAlert];
}

- (void)closeSecurityWarningAlert
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    XCUIElement *securityWarningAlert = self.application.alerts[@"Warning"];
    if (securityWarningAlert.exists) {
        [self tapButtonWithText:JMLocalizedString(@"dialog_button_ok")
                  parentElement:securityWarningAlert];
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
        [testProfile tap];
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
            parentElement:nil];
}


#pragma mark - Helpers
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

- (void)givenThatLibraryPageOnScreen
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    [self skipIntroPageIfNeed];
    [self skipRateAlertIfNeed];
    
    // Verify Library Page
    [self verifyThatCurrentPageIsLibrary];
}

- (void)givenThatRepositoryPageOnScreen
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    [self verifyThatCurrentPageIsRepository];
}

- (void)givenThatCellsAreVisible
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
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
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    [self tryTapGridButton];
    [self givenThatCellsAreVisible];
}

- (void)tryTapGridButton
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    [self tapButtonWithId:@"horizontal list button"
            parentElement:nil];
}

- (void)givenThatGridCellsAreVisible
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    [self tryTapListButton];
    [self verifyThatCollectionViewContainsGridOfCells];
}


- (void)tryTapListButton
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    [self tapButtonWithId:@"grid button"
            parentElement:nil];
}

- (void)givenThatReportCellsOnScreen
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    [self selectFilterBy:@"Reports" inSectionWithTitle:@"Library"];
    [self givenThatListCellsAreVisible];
}

- (void)givenThatDashboardCellsOnScreen
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    [self selectFilterBy:@"Dashboards" inSectionWithTitle:@"Library"];
    [self givenThatListCellsAreVisible];
}

- (void)skipIntroPageIfNeed
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    NSLog(@"Try to skip intro page");
    XCUIElement *skipIntroButton;
    NSInteger attemptsCount = 2;
    for (NSInteger i = 0; i < attemptsCount; i++) {
        sleep(kUITestsElementAvailableTimeout);
        skipIntroButton = [self waitElementMatchingType:XCUIElementTypeButton
                                                   text:@"Skip Intro"
                                                timeout:0];
        if (skipIntroButton.exists) {
            NSLog(@"%@", [self.application.otherElements allElementsBoundByAccessibilityElement]);
            [skipIntroButton tap];
            break;
        }
    }
}

- (void)skipRateAlertIfNeed
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    NSLog(@"Try to skip rate dialog");
    XCUIElement *rateAlert;
    NSInteger attemptsCount = 2;
    for (NSInteger i = 0; i < attemptsCount; i++) {
        sleep(kUITestsElementAvailableTimeout);
        rateAlert = self.application.alerts[@"Rate TIBCO JasperMobile"];
        if (rateAlert.exists) {
            XCUIElement *rateAppLateButton = rateAlert.buttons[@"No, thanks"];
            if (rateAppLateButton.exists) {
                [rateAppLateButton tap];
                break;
            } else {
                XCTFail(@"There is an rate dialog, but 'No, thanks' button isn't in hierarchy");
            }
        }
    }
}

- (XCUIElement *)libraryPageViewElement
{
    XCUIElement *element = [self waitElementMatchingType:XCUIElementTypeOther
                                              identifier:@"JMBaseCollectionContentViewAccessibilityId"
                                                 timeout:0];
    return element;
}

- (void)tapButtonWithId:(NSString *)buttonId
          parentElement:(XCUIElement *)parentElement
{
    XCUIElement *button = [self waitElementMatchingType:XCUIElementTypeButton
                                             identifier:buttonId
                                          parentElement:parentElement
                                                timeout:kUITestsBaseTimeout];
    if (button.exists) {
        [button tap];
    } else {
        XCTFail(@"Button with id: %@, wasn't found", buttonId);
    }
}

- (void)tapButtonWithText:(NSString *)text
            parentElement:(XCUIElement *)parentElement
{
    XCUIElement *button = [self waitElementMatchingType:XCUIElementTypeButton
                                                   text:text
                                          parentElement:parentElement
                                                timeout:0]; // It's suggested that element on which button lies have been already found
    if (button.exists) {
        [button tap];
    } else {
        XCTFail(@"Button with text: %@, wasn't found", text);
    }
}

- (void)verifyThatElementWithIdExist:(NSString *)elementId
{
    XCUIElement *element = [self waitElementMatchingType:XCUIElementTypeOther
                                              identifier:elementId
                                                 timeout:kUITestsBaseTimeout];
    if (!element.exists) {
        XCTFail(@"Element with id: %@, wasn't found", elementId);
    }
}

#pragma mark - Helper Actions
// TODO: replace this method with 'tryBackToPreviousPageWithTitle:'
- (void)tryBackToPreviousPage
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    XCUIElement *backButton = [self waitElementMatchingType:XCUIElementTypeButton
                                                       text:@"Back"
                                                    timeout:0];
    if (!backButton.exists) {
        backButton = [self waitElementMatchingType:XCUIElementTypeButton
                                              text:@"Library"
                                           timeout:0];
    }
    [backButton tap];
}

- (void)tryBackToPreviousPageWithTitle:(NSString *)pageTitle
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    XCUIElement *navBar = [self findNavigationBarWithLabel:nil];
    XCUIElement *backButton = [self waitElementMatchingType:XCUIElementTypeButton
                                                         text:pageTitle
                                                parentElement:navBar
                                                      timeout:0];
    if (backButton.exists) {
        [backButton tap];
    } else {
        XCTFail(@"Back button with title: %@, wasn't found", pageTitle);
    }
}

#pragma mark - Verifies
- (void)verifyThatCurrentPageIsLibrary
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    // TODO: replace with specific element - JMLibraryPageAccessibilityId
    [self verifyThatElementWithIdExist:@"JMBaseCollectionContentViewAccessibilityId"];
}

- (void)verifyThatCurrentPageIsRepository
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
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
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    XCUIElement *popup = [self waitElementMatchingType:XCUIElementTypeOther
                                            identifier:@"JMCancelRequestPopupAccessibilityId"
                                         parentElement:nil
                                           shouldExist:YES
                                               timeout:kUITestsResourceWaitingTimeout];
    if (!popup.exists) {
        XCTFail(@"Loading popup isn't visible");
    }
}

- (void)givenLoadingPopupNotVisible
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    XCUIElement *popup = [self waitElementMatchingType:XCUIElementTypeOther
                                            identifier:@"JMCancelRequestPopupAccessibilityId"
                                         parentElement:nil
                                           shouldExist:NO
                                               timeout:kUITestsResourceWaitingTimeout];
    if (popup.exists) {
        XCTFail(@"Loading popup visible");
    }
}

#pragma mark - JMBaseUITestProtocol
- (BOOL) shouldLoginBeforeStartTest
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    return YES;
}

#pragma - Utils
- (void)closeKeyboardWithDoneButton
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    XCUIElement *doneButton = [self waitElementMatchingType:XCUIElementTypeButton
                                                       text:@"Done"
                                                    timeout:kUITestsBaseTimeout];
    if (doneButton.exists) {
        [doneButton tap];
    } else {
        XCTFail(@"Done button wasn't found");
    }

}

- (void)enterText:(NSString *)text intoTextFieldWithAccessibilityId:(NSString *)accessibilityId
 placeholderValue:(NSString *)placeholderValue
    parentElement:(XCUIElement *)parentElement
    isSecureField:(BOOL)isSecureField
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    XCUIElement *textField;
    if (isSecureField) {
        textField =  [self waitElementMatchingType:XCUIElementTypeSecureTextField
                                        identifier:accessibilityId
                                     parentElement:parentElement
                                           timeout:kUITestsBaseTimeout];
    } else {
        // TODO: do we need placeholder yet?
        textField =  [self waitElementMatchingType:XCUIElementTypeTextField
                                        identifier:accessibilityId
                                     parentElement:parentElement
                                           timeout:kUITestsBaseTimeout];
    }
    
    if (textField.exists) {
        [self enterText:text
          intoTextField:textField];
    } else {
        XCTFail(@"Can't find text field with id:%@ to enter text: %@", accessibilityId, text);
    }
}

- (void)enterText:(NSString *)text
    intoTextField:(XCUIElement *)textField
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
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
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    [self deleteTextFromTextField:textField];
    [textField typeText:text];
    [self closeKeyboardWithDoneButton];
}

- (void)deleteTextFromTextField:(XCUIElement *)textField
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
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
