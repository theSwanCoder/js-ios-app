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
#import "JMBaseUITestCase+Buttons.h"

@implementation JMAppMenuUITests

#pragma mark - Tests
- (void)testThatMenuViewCanBeViewedByTappingMenuButton
{
    [self showSideMenuInSectionWithName:JMLocalizedString(@"menuitem_library_label")];
    [self verifySideMenuVisible];

    [self hideSideMenuInSectionWithName:JMLocalizedString(@"menuitem_library_label")];
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
    [self showSideMenuInSectionWithName:JMLocalizedString(@"menuitem_library_label")];
    [self verifySideMenuVisible];

    XCUIElement *menuView = [self sideMenuElement];
    [menuView swipeUp];
    [menuView swipeDown];

    [self hideSideMenuInSectionWithName:JMLocalizedString(@"menuitem_library_label")];
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
    [self tapDoneButtonOnNavBarWithTitle:nil];

    // Check Settings item
    [self selectSettings];
    [self closeSettingsPage];
}

- (void)testThatServerProfileInfoIsAppeared
{
    [self showSideMenuInSectionWithName:JMLocalizedString(@"menuitem_library_label")];
    [self verifySideMenuVisible];

    JMUITestServerProfile *testServerProfile = [JMUITestServerProfileManager sharedManager].testProfile;

    [self verifyLabelWithTextExist:testServerProfile.username];

    NSString *fullServerNameString = [NSString stringWithFormat:@"%@ (v.%@)", testServerProfile.name, @"6.3.0"];
    [self verifyLabelWithTextExist:fullServerNameString];

    if (testServerProfile.organization.length > 0) {
        [self verifyLabelWithTextExist:testServerProfile.organization];
    }

    [self hideSideMenuInSectionWithName:JMLocalizedString(@"menuitem_library_label")];
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

- (void)verifyLabelWithTextExist:(NSString *)labelText
{
    XCUIElement *usernameLabel = [self waitElementMatchingType:XCUIElementTypeStaticText
                                                          text:labelText
                                                       timeout:kUITestsBaseTimeout];
    if (!usernameLabel.exists) {
        XCTFail(@"Label with text: %@, wasn't fount", labelText);
    }
}

- (void)closeSettingsPage
{
    [self tapCancelButtonOnNavBarWithTitle:nil];
}

@end
