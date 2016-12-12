//
// Created by Aleksandr Dakhno on 12/10/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JMBaseUITestCase.h"

@interface JMBaseUITestCase (LoginPage)

- (void)loginWithTestProfileIfNeed;
- (void)verifyThatLoginWasSuccess;
- (void)logout;

- (void)selectTestProfile;
- (XCUIElement *)findTestProfileCell;
- (void)removeAllServerProfiles;
- (void)tryOpenServerProfilesPage;
- (void)tryOpenNewServerProfilePage;
- (void)tryCreateNewTestServerProfile;
//- (void)trySelectNewTestServerProfile;
//- (void)tryEnterTestCredentials;
//- (void)tryTapLoginButton;
- (void)givenThatLoginPageOnScreen;
- (void)givenThatServerProfilesPageOnScreen;
- (void)givenThatNewProfilePageOnScreen;

@end