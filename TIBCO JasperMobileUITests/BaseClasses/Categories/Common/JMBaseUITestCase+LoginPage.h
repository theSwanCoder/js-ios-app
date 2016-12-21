//
// Created by Aleksandr Dakhno on 12/10/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JMBaseUITestCase.h"

@interface JMBaseUITestCase (LoginPage)

- (void)loginWithTestProfileIfNeed;
- (void)verifyThatLoginProcessWasSuccess;
- (BOOL)isProfileWasLoggedWithUsername:(NSString *)username
                          organization:(NSString *)organization
                                 alias:(NSString *)alias;
- (void)logout;

- (void)selectTestProfile;
- (XCUIElement *)findTestProfileCell;
- (void)removeAllServerProfiles;
- (void)tryOpenServerProfilesPage;
- (void)tryOpenNewServerProfilePage;
- (void)tryCreateNewTestServerProfile;
- (void)givenThatLoginPageOnScreen;
- (void)givenThatServerProfilesPageOnScreen;
- (void)givenThatNewProfilePageOnScreen;

@end