//
//  JMServerProfilesUITests.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 2/14/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMServerProfilesUITests.h"
#import "JMBaseUITestCase+Helpers.h"
#import "JMUITestServerProfileManager.h"
#import "JMUITestServerProfile.h"
#import "JMBaseUITestCase+LoginPage.h"
#import "JMBaseUITestCase+Section.h"
#import "JMBaseUITestCase+Buttons.h"
#import "XCUIElement+Tappable.h"
#import "JMBaseUITestCase+Cells.h"
#import "JMBaseUITestCase+Alerts.h"

@implementation JMServerProfilesUITests


- (void)testThatListOfServerProfilesVisible
{
    [self tryOpenServerProfilesPage];
    [self waitCollectionViewContainsCellsWithTimeout:kUITestsBaseTimeout];
    XCUIElement *collectionView = self.application.collectionViews.allElementsBoundByIndex.firstObject;
    if (collectionView.exists) {
        [collectionView swipeUp];
        [collectionView swipeDown];
    }
    [self tryBackToPreviousPage];
}

- (void)testThatServerProfileCanBeSelected
{
    [self tryOpenServerProfilesPage];
    
    XCUIElement *testProfile = [self findTestProfileCell];
    if (testProfile.exists) {
        [testProfile tapByWaitingHittable];
    } else {
        XCTFail(@"Test profile doesn't visible or exist");
    }
    
    // verify server profile field has value that equal demo profile
    XCUIElement *serverProfileTextField = [self waitElementMatchingType:XCUIElementTypeTextField
                                                             identifier:@"JMLoginPageServerProfileTextFieldAccessibilityId"
                                                                timeout:kUITestsBaseTimeout];
    if (!serverProfileTextField.exists) {
        XCTFail(@"Server profile text field wasn't found");
    }
    NSString *stringValueInServerField = serverProfileTextField.value;
    JMUITestServerProfile *testServerProfile = [JMUITestServerProfileManager sharedManager].testProfile;
    NSString *testProfileName = testServerProfile.alias;
    BOOL hasTestProfileName = [stringValueInServerField isEqualToString:testProfileName];
    XCTAssert(hasTestProfileName, @"Value in 'Sever' field doesn't equal 'Test Profile'");
}

- (void)testThatServerProfileCanBeAdded
{
    [self tryOpenServerProfilesPage];

    JMUITestServerProfile *testServerProfile = [JMUITestServerProfileManager sharedManager].testProfile;
    NSString *testProfileName = testServerProfile.alias;
    XCUIElement *testProfile = self.application.collectionViews.staticTexts[testProfileName];
    if (testProfile.exists) {
        [self removeTestProfile];
    }

    [self givenThatServerProfilesPageOnScreen];
    NSInteger startCellsCount = [self countCellsWithAccessibilityId:@"JMCollectionViewServerGridAccessibilityId"];

    [self createTestProfile];

    NSInteger endCellsCount = [self countCellsWithAccessibilityId:@"JMCollectionViewServerGridAccessibilityId"];
    XCTAssertTrue(endCellsCount > startCellsCount, @"Start Cells Count: %@, but End Cells Count: %@", @(startCellsCount), @(endCellsCount));
    [self tryBackToPreviousPage];
}

- (void)testThatServerProfileCanBeDeleted
{
    [self tryOpenServerProfilesPage];
    
    NSInteger cellsCount = [self countCellsWithAccessibilityId:@"JMCollectionViewServerGridAccessibilityId"];
    if (!cellsCount) {
        [self createTestProfile];
        [self givenThatServerProfilesPageOnScreen];
    }

    NSInteger startCellsCount = [self countCellsWithAccessibilityId:@"JMCollectionViewServerGridAccessibilityId"];
    XCUIElement *serverProfileElement = [self cellWithAccessibilityId:@"JMCollectionViewServerGridAccessibilityId"
                                                             forIndex:0];
    if (serverProfileElement && serverProfileElement.exists) {
        [self removeProfileWithElement:serverProfileElement];
    }
    NSInteger endCellsCount = [self countCellsWithAccessibilityId:@"JMCollectionViewServerGridAccessibilityId"];
    XCTAssertTrue(endCellsCount < startCellsCount);
    [self tryBackToPreviousPage];
}

- (void)testThatServerProfileCanBeCloned
{
    [self tryOpenServerProfilesPage];
    [self removeAllServerProfiles];

    [self tryOpenNewServerProfilePage];
    [self givenThatNewProfilePageOnScreen];
    [self tryCreateNewTestServerProfile];

    [self givenThatServerProfilesPageOnScreen];

    NSInteger startCellsCount = [self countCellsWithAccessibilityId:@"JMCollectionViewServerGridAccessibilityId"];

    XCUIElement *serverProfileElement = [self findTestProfileCell];
    if (!serverProfileElement.exists) {
        XCTFail(@"Test profile doesn't visible or exist");
    }
    
    [serverProfileElement pressForDuration:1.1];
    
    XCUIElement *menu = self.application.menuItems[@"Clone Profile"];
    if (menu) {
        [menu tapByWaitingHittable];
        [self givenThatNewProfilePageOnScreen];
        // Save a new created profile
        [self verifyButtonExistWithText:@"Save"
                          parentElement:nil];

        // Confirm if need http end point
        XCUIElement *securityWarningAlert = [self waitAlertWithTitle:@"Warning"
                                                             timeout:kUITestsBaseTimeout];
        [self verifyButtonExistWithText:JMLocalizedString(@"dialog_button_ok")
                          parentElement:securityWarningAlert];
    } else {
        XCTFail(@"'Clone Profile' menu item doesn't exist.");
    }
    
    NSInteger endCellsCount = [self countCellsWithAccessibilityId:@"JMCollectionViewServerGridAccessibilityId"];
    XCTAssertTrue(endCellsCount > startCellsCount);
    
    // TODO: remove cloned profile.
    
    [self tryBackToPreviousPage];
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

- (void)removeTestProfile
{
    JMUITestServerProfile *testServerProfile = [JMUITestServerProfileManager sharedManager].testProfile;
    NSString *testProfileName = testServerProfile.alias;
    XCUIElement *testProfileElement = self.application.collectionViews.staticTexts[testProfileName];
    [self removeProfileWithElement:testProfileElement];
}

- (void)removeProfileWithElement:(XCUIElement *)element
{
    [element pressForDuration:1.0];
    [element pressForDuration:1.1];
    XCUIElement *menu = self.application.menuItems[@"Delete"];
    if (menu) {
        [menu tapByWaitingHittable];
        XCUIElement *alertView = [self waitAlertWithTitle:@"Confirmation"
                                                  timeout:kUITestsBaseTimeout];
        [self verifyButtonExistWithText:@"Delete"
                          parentElement:alertView];
    } else {
        XCTFail(@"Delete menu item doesn't exist.");
    }
}

@end
