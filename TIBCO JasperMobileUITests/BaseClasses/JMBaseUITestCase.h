//
//  JMBaseUITestCase.h
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 2/18/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "JMUITestConstants.h"

@interface JMBaseUITestCase : XCTestCase
@property(nonatomic, strong) XCUIApplication *application;
- (void)selectTestProfile;
- (void)loginWithTestProfile;
- (void)logout;
- (void)tryOpenServerProfilesPage;
- (void)tryOpenNewServerProfilePage;
- (void)tryCreateNewTestServerProfile;
- (void)tryBackToLoginPageFromProfilesPage;
- (void)trySelectNewTestServerProfile;
- (void)tryEnterTestCredentials;
- (void)tryTapLoginButton;
- (void)givenThatLoginPageOnScreen;
- (void)givenThatServerProfilesPageOnScreen;
- (void)givenThatNewProfilePageOnScreen;
- (void)givenThatLibraryPageOnScreen;
- (void)givenThatCellsAreVisible;
- (void)verifyIntroPageIsOnScreen;
- (void)verifyRateAlertIsShown;
- (void)tryOpenRepositoryPage;
- (void)tryOpenLibraryPage;
- (void)tryOpenFavoritePage;
- (void)givenSideMenuVisible;
- (void)givenSideMenuNotVisible;
- (void)tryOpenSideApplicationMenu;
- (BOOL)isShareButtonExists;
- (void)verifyThatCurrentPageIsLibrary;
- (void)verifyThatCurrentPageIsRepository;
@end
