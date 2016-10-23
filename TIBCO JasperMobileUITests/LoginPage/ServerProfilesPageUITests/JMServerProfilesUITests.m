//
//  JMServerProfilesUITests.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 2/14/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMServerProfilesUITests.h"
#import "JMBaseUITestCase+Helpers.h"

@implementation JMServerProfilesUITests


- (void)testThatListOfServerProfilesVisible
{
    [self tryOpenServerProfilesPage];
    [self givenThatCellsAreVisible];
    XCUIElement *collectionView = self.application.collectionViews.allElementsBoundByIndex.firstObject;
    if (collectionView.exists) {
        [collectionView swipeUp];
        [collectionView swipeDown];
    }
    [self findBackButtonWithControllerAccessibilityId:nil];
}

- (void)testThatServerProfileCanBeSelected
{
    [self tryOpenServerProfilesPage];
    
    [self trySelectNewTestServerProfile];
    
    // verify server profile field has value that equal demo profile
    XCUIElement *serverProfileTextField = [self waitTextFieldWithAccessibilityId:JMLoginPageServerProfileTextFieldAccessibilityId
                                                                         timeout:kUITestsBaseTimeout];
    NSString *stringValueInServerField = serverProfileTextField.value;
    BOOL hasTestProfileName = [stringValueInServerField isEqualToString:kJMTestProfileName];
    XCTAssert(hasTestProfileName, @"Value in 'Sever' field doesn't equal 'Test Profile'");
}

- (void)testThatServerProfileCanBeAdded
{
    [self tryOpenServerProfilesPage];
    
    XCUIElement *testProfile = [self findCollectionViewCellWithAccessibilityId:JMServerProfilesPageServerCellAccessibilityId
                                              containsLabelWithAccessibilityId:kJMTestProfileName
                                                                     labelText:kJMTestProfileName];

    if (testProfile.exists) {
        [self tryRemoveProfileWithElement:testProfile];
    }

    [self givenThatServerProfilesPageOnScreen];
    NSInteger startCellsCount = [self countCellsWithAccessibilityId:JMServerProfilesPageServerCellAccessibilityId];

    [self createTestProfile];

    NSInteger endCellsCount = [self countCellsWithAccessibilityId:JMServerProfilesPageServerCellAccessibilityId];
    XCTAssertTrue(endCellsCount > startCellsCount, @"Start Cells Count: %@, but End Cells Count: %@", @(startCellsCount), @(endCellsCount));
    [self findBackButtonWithControllerAccessibilityId:nil];
}

- (void)testThatServerProfileCanBeDeleted
{
    [self tryOpenServerProfilesPage];
    
    NSInteger cellsCount = [self countCellsWithAccessibilityId:JMServerProfilesPageServerCellAccessibilityId];
    if (!cellsCount) {
        [self createTestProfile];
        [self givenThatServerProfilesPageOnScreen];
    }

    NSInteger startCellsCount = [self countCellsWithAccessibilityId:JMServerProfilesPageServerCellAccessibilityId];
    XCUIElement *serverProfileElement = [self cellWithAccessibilityId:JMServerProfilesPageServerCellAccessibilityId
                                                             forIndex:0];
    if (serverProfileElement && serverProfileElement.exists) {
        [self tryRemoveProfileWithElement:serverProfileElement];
    }
    NSInteger endCellsCount = [self countCellsWithAccessibilityId:JMServerProfilesPageServerCellAccessibilityId];
    XCTAssertTrue(endCellsCount < startCellsCount);
    [self findBackButtonWithControllerAccessibilityId:nil];
}

- (void)testThatServerProfileCanBeCloned
{
    [self tryOpenServerProfilesPage];
    [self removeAllServerProfiles];

    [self tryOpenNewServerProfilePage];
    [self givenThatNewProfilePageOnScreen];
    [self tryCreateNewTestServerProfile];

    [self givenThatServerProfilesPageOnScreen];

    XCUIElement *serverProfileElement = [self findTestProfileCell];

    NSInteger startCellsCount = [self countCellsWithAccessibilityId:JMServerProfilesPageServerCellAccessibilityId];
    
    [serverProfileElement pressForDuration:1.1];
    
    XCUIElement *menu = self.application.menuItems[JMLocalizedString(@"servers_action_profile_clone")];
    if (menu) {
        [menu tap];
        [self givenThatNewProfilePageOnScreen];
        // Save a new created profile
        XCUIElement *saveButton = [self waitButtonWithAccessibilityId:JMNewServerProfilePageSaveAccessibilityId
                                                              timeout:kUITestsBaseTimeout];
        [saveButton tap];

        // Confirm if need http end point
        XCUIElement *securityWarningAlert = [self waitAlertWithTitle:JMLocalizedString(@"dialod_title_attention")
                                                             timeout:kUITestsBaseTimeout];
        XCUIElement *okButton = [self findButtonWithAccessibilityId:JMLocalizedString(@"dialog_button_ok")
                                            parentElement:securityWarningAlert];
        [okButton tap];
    } else {
        XCTFail(@"'Clone Profile' menu item doesn't exist.");
    }
    
    NSInteger endCellsCount = [self countCellsWithAccessibilityId:JMServerProfilesPageServerCellAccessibilityId];
    XCTAssertTrue(endCellsCount > startCellsCount);
    
    // TODO: remove cloned profile.
    
    [self findBackButtonWithControllerAccessibilityId:nil];
}


#pragma mark - JMBaseUITestProtocol
- (BOOL) shouldLoginBeforeStartTest
{
    return NO;
}

#pragma mark - Utils

- (void)createTestProfile
{
    [self tryOpenNewServerProfilePage];
    [self givenThatNewProfilePageOnScreen];
    [self tryCreateNewTestServerProfile];
}

@end
