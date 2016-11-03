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
#import "JMUITestServerProfileManager.h"
#import "JMUITestServerProfile.h"

@implementation JMAppMenuUITests

#pragma mark - Tests
- (void)testThatMenuViewCanBeViewedByTappingMenuButton
{
    [self showSideMenuInSectionWithName:@"Library"];
    [self verifySideMenuVisible];

    [self hideSideMenuInSectionWithName:@"Library"];
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
    [self showSideMenuInSectionWithName:@"Library"];
    [self verifySideMenuVisible];

    XCUIElement *menuView = [self sideMenuElement];
    [menuView swipeUp];
    [menuView swipeDown];

    [self hideSideMenuInSectionWithName:@"Library"];
    [self verifySideMenuNotVisible];
}

- (void)verifySideMenuVisible
{
    XCUIElement *menuView = [self sideMenuElement];
    if (!menuView.exists) {
        XCTFail(@"Menu Should be visible");
    }
}

- (void)verifySideMenuNotVisible
{
    XCUIElement *menuView = [self sideMenuElement];
    if (menuView.exists) {
        XCTFail(@"Menu Should not be visible");
    }
}

- (void)testThatMenuViewCanSelectItems
{
    // Check all collection screen items
    NSArray *itemsArray = @[@"Repository", @"Saved Items", @"Favorites", @"Schedules"];
    for (NSString *itemName in itemsArray) {
        [self showSideMenuInSectionWithName:nil];
        [self verifySideMenuVisible];
        [self selectMenuItemForPageWithName:itemName];
    }

    // Check About item
    [self selectAbout];
    // Close About page
    XCUIElement *doneButton = [self waitDoneButtonWithTimeout:kUITestsBaseTimeout];
    [doneButton tap];

    // Check Settings item
    [self selectSettings];
    // Close Settings page
    XCUIElement *cancelButton = [self waitButtonWithTitle:@"Cancel"
                                                  timeout:kUITestsBaseTimeout];
    [cancelButton tap];
}

- (void)testThatServerProfileInfoIsAppeared
{
    [self showSideMenuInSectionWithName:@"Library"];
    [self verifySideMenuVisible];

    JMUITestServerProfile *testServerProfile = [JMUITestServerProfileManager sharedManager].testProfile;

    [self waitStaticTextWithText:testServerProfile.username
                   parentElement:nil
                         timeout:kUITestsBaseTimeout];

    NSString *fullServerNameString = [NSString stringWithFormat:@"%@ (v.%@)", testServerProfile.name, @"6.3.0"];
    [self waitStaticTextWithText:fullServerNameString
                   parentElement:nil
                         timeout:kUITestsBaseTimeout];

    if (testServerProfile.organization.length > 0) {
        [self waitStaticTextWithText:testServerProfile.organization
                       parentElement:nil
                             timeout:kUITestsBaseTimeout];
    }

    [self hideSideMenuInSectionWithName:@"Library"];
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
