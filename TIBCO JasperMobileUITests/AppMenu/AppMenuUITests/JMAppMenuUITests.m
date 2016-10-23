//
//  JMAppMenuUITests.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 2/19/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMAppMenuUITests.h"
#import "JMBaseUITestCase+Helpers.h"
#import "JMBaseUITestCase+SideMenu.h"
//#import "NSObject+Additions.h"
//#import "JaspersoftSDK/JaspersoftSDK.h"

@implementation JMAppMenuUITests

#pragma mark - Tests
- (void)testThatMenuViewCanBeViewedByTappingMenuButton
{
    [self showSideMenuInSectionWithAccessibilityId:JMLibraryPageAccessibilityId];
    [self verifySideMenuVisible];

    [self hideSideMenuInSectionWithAccessibilityId:JMLibraryPageAccessibilityId];
    [self verifySideMenuNotVisible];
}

- (void)testThatMenuViewCanBeViewedBySwipping
{
    [self tryOpenSideApplicationMenuBySwipe];
    [self verifySideMenuVisible];

    [self tryCloseSideApplicationMenuBySwipe];
    [self verifySideMenuNotVisible];
}

- (void)testThatMenuViewIsScrollable
{
    [self showSideMenuInSectionWithAccessibilityId:JMLibraryPageAccessibilityId];
    [self verifySideMenuVisible];

    XCUIElement *sideMenuElement = [self waitElementWithAccessibilityId:JMSideApplicationMenuAccessibilityId
                                                                timeout:kUITestsBaseTimeout];
    [sideMenuElement swipeUp];
    [sideMenuElement swipeDown];

    [self hideSideMenuInSectionWithAccessibilityId:JMLibraryPageAccessibilityId];
    [self verifySideMenuNotVisible];
}

- (void)testThatMenuViewCanSelectItems
{
    // Check all collection screen items
    NSArray *itemsArray = @[JMRepositoryPageAccessibilityId, JMSavedItemsPageAccessibilityId, JMFavoritesPageAccessibilityId, JMSchedulesPageAccessibilityId];
    for (NSString *itemName in itemsArray) {
        [self showSideMenuInSectionWithAccessibilityId:nil];
        [self verifySideMenuVisible];
        [self selectMenuItemForPageWithAccessibilityId:itemName];
    }

    // Check About item
    [self selectAbout];
    // Close About page
    XCUIElement *doneButton = [self waitDoneButtonWithTimeout:kUITestsBaseTimeout];
    [doneButton tap];

    // Check Settings item
    [self selectSettings];
    // Close Settings page
    XCUIElement *cancelButton = [self waitButtonWithAccessibilityId:JMButtonCancelAccessibilityId
                                                            timeout:kUITestsBaseTimeout];
    [cancelButton tap];
}

- (void)testThatServerProfileInfoIsAppeared
{
    [self showSideMenuInSectionWithAccessibilityId:JMLibraryPageAccessibilityId];
    [self verifySideMenuVisible];
    
    XCUIElement *userNameLabel = [self findStaticTextWithAccessibilityId:JMSideApplicationMenuUsernameLabelAccessibilityId];
    if (!userNameLabel.exists) {
        XCTFail(@"'Username' label doesn't exist.");
    }
    if(![userNameLabel.label isEqualToString:kJMTestProfileCredentialsUsername]){
        XCTFail(@"'Username' label text doesn't correct.");
    }
    
    NSString *fullServerNameString = [NSString stringWithFormat:@"%@ (v.%@)", kJMTestProfileName, @"6.3.0"];
    XCUIElement *serverAliasLabel = [self findStaticTextWithAccessibilityId:JMSideApplicationMenuFullServerNameLabelAccessibilityId];
    if (!serverAliasLabel.exists) {
        XCTFail(@"'Server Alias' label doesn't exist.");
    }
    if(![serverAliasLabel.label isEqualToString:fullServerNameString]){
        XCTFail(@"'Server Alias' label text doesn't correct.");
    }

    XCUIElement *organizationLabel = [self findStaticTextWithAccessibilityId:JMSideApplicationMenuOrganizationLabelAccessibilityId];
    if (!userNameLabel.exists) {
        XCTFail(@"'Organization' label doesn't exist.");
    }
    if(![organizationLabel.label isEqualToString:kJMTestProfileCredentialsOrganization]){
        XCTFail(@"'Organization' label text doesn't correct.");
    }
    
    XCUIElement *buildVersionLabel = [self findStaticTextWithAccessibilityId:JMSideApplicationMenuVersionLabelAccessibilityId];
    if (!buildVersionLabel.exists) {
        XCTFail(@"'Build&version' label doesn't exist.");
    }
    if(!buildVersionLabel.label.length){
        XCTFail(@"'Build&version' label text doesn't correct.");
    }

    [self hideSideMenuInSectionWithAccessibilityId:JMLibraryPageAccessibilityId];
}

#pragma mark - Helpers

- (void)tryOpenSideApplicationMenuBySwipe
{
    XCUIElement *mainWindow = self.application.windows.allElementsBoundByIndex[0];
    if (mainWindow.exists) {
        [mainWindow swipeRight];
    } else {
        XCTFail(@"'Main' window doesn't exist.");
    }
}

- (void)tryCloseSideApplicationMenuBySwipe
{
    XCUIElement *mainWindow = self.application.windows.allElementsBoundByIndex[0];
    if (mainWindow.exists) {
        [mainWindow swipeLeft];
    } else {
        XCTFail(@"'Main' window doesn't exist.");
    }
}
@end
