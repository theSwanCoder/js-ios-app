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
@required
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
- (void)tryOpenRepositoryPage;
- (void)tryOpenLibraryPage;
- (void)tryOpenFavoritePage;
- (void)tryCreateNewTestServerProfile;
- (void)trySelectNewTestServerProfile;
- (void)tryEnterTestCredentials;
- (void)tryTapLoginButton;
//
- (void)givenThatLoginPageOnScreen;
- (void)givenThatServerProfilesPageOnScreen;
- (void)givenThatNewProfilePageOnScreen;
- (void)givenThatLibraryPageOnScreen;
- (void)givenThatCellsAreVisible;
- (void)givenThatReportCellsOnScreen;
- (void)givenThatDashboardCellsOnScreen;
//
- (void)skipIntroPageIfNeed;
- (void)skipRateAlertIfNeed;
//
- (void)givenSideMenuVisible;
- (void)givenSideMenuNotVisible;
- (void)tryTapSideApplicationMenu;
- (BOOL)isShareButtonExists;
//- (void)verifyThatCurrentPageIsLibrary;
//- (void)verifyThatCurrentPageIsRepository;
//
- (void)givenLoadingPopupVisible;
- (void)givenLoadingPopupNotVisible;

- (void)closeKeyboardWithDoneButton;
- (void)openMenuActions;
- (void)openMenuActionsOnNavBarWithLabel:(NSString *)label;

@end
