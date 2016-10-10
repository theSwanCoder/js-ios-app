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

@implementation JMAppMenuUITests

- (void)setUp
{
    [super setUp];

    [self givenThatLibraryPageOnScreen];
}

- (void)tearDown
{

    [super tearDown];
}

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
    NSArray *itemsArray = @[@"Library", @"Repository", @"Recently Viewed", @"Saved Items", @"Favorites", @"Schedules"];
    NSString *currentItemName = itemsArray.firstObject;
    for (NSString *itemName in itemsArray) {
        [self showSideMenuInSectionWithName:currentItemName];
        [self verifySideMenuVisible];
        XCUIElement *menuView = [self sideMenuElement];
        XCUIElement *pageMenuItem = menuView.cells.staticTexts[itemName];
        if (pageMenuItem.exists) {
            [pageMenuItem tap];
            currentItemName = itemName;
        }
    }

    // Check About item
    [self selectAbout];
    // Close About page
    XCUIElement *doneButton = self.application.buttons[@"Done"];
    if (doneButton.exists) {
        [doneButton tap];
    } else {
        XCTFail(@"'Done' button doesn't exist.");
    }

    // Check Settings item
    [self selectSettings];
    // Close Settings page
    XCUIElement *cancelButton = self.application.buttons[@"Cancel"];
    if (cancelButton.exists) {
        [cancelButton tap];
    } else {
        XCTFail(@"'Settings' button doesn't exist.");
    }
}

- (void)testThatServerProfileInfoIsAppeared
{
    [self showSideMenuInSectionWithName:@"Library"];
    [self verifySideMenuVisible];
    
    XCUIElement *userNameLabel = self.application.staticTexts[kJMTestProfileCredentialsUsername];
    if (!userNameLabel.exists) {
        XCTFail(@"'Username' label doesn't exist.");
    }
    
    NSString *fullServerNameString = [NSString stringWithFormat:@"%@ (v.%@)", kJMTestProfileName, @"6.3.0"];
    XCUIElement *serverAliasLabel = self.application.staticTexts[fullServerNameString];
    if (!serverAliasLabel.exists) {
        XCTFail(@"'Server Alias' label doesn't exist.");
    }
    XCUIElement *organizationLabel = self.application.staticTexts[kJMTestProfileCredentialsOrganization];
    if (!organizationLabel.exists) {
        XCTFail(@"'Organization' label doesn't exist.");
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
