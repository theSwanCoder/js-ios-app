/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.6
 */

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
