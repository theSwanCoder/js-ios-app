//
//  JMBaseUITestCase.h
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 2/18/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "JMUITestConstants.h"
#import "JMLocalization.h"

extern NSTimeInterval kUITestsBaseTimeout;
extern NSTimeInterval kUITestsResourceWaitingTimeout;
extern NSTimeInterval kUITestsElementAvailableTimeout;

@protocol JMBaseUITestProtocol <NSObject>
- (BOOL) shouldLoginBeforeStartTest;
@end

@interface JMBaseUITestCase : XCTestCase <JMBaseUITestProtocol>
@property(nonatomic, strong) XCUIApplication *application;
- (void)selectTestProfile;
- (void)loginWithTestProfile;
- (void)logout;
- (void)tryBackToPreviousPage;
- (void)tryOpenServerProfilesPage;
- (void)tryOpenNewServerProfilePage;
- (void)tryCreateNewTestServerProfile;
- (void)trySelectNewTestServerProfile;
- (void)tryEnterTestCredentials;
- (void)tryTapLoginButton;
//
- (void)givenThatLoginPageOnScreen;
- (void)givenThatServerProfilesPageOnScreen;
- (void)givenThatNewProfilePageOnScreen;
- (void)givenThatLibraryPageOnScreen;
- (void)givenThatRepositoryPageOnScreen;

- (void)givenThatCellsAreVisible;
- (void)givenThatListCellsAreVisible;
- (void)givenThatGridCellsAreVisible;
- (void)givenThatReportCellsOnScreen;
- (void)givenThatDashboardCellsOnScreen;
//
- (void)skipIntroPageIfNeed;
- (void)skipRateAlertIfNeed;
//
- (void)givenLoadingPopupVisible;
- (void)givenLoadingPopupNotVisible;

- (void)enterText:(NSString *)text intoTextFieldWithAccessibilityId:(NSString *)accessibilityId
    parentElement:(XCUIElement *)parentElement
    isSecureField:(BOOL)isSecureField;
- (void)enterText:(NSString *)text
    intoTextField:(XCUIElement *)textField;

- (void)deleteTextFromTextField:(XCUIElement *)textField;

- (void)closeKeyboardWithDoneButton;

@end
