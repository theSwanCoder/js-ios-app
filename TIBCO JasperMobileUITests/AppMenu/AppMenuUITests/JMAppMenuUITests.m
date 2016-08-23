//
//  JMAppMenuUITests.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 2/19/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMAppMenuUITests.h"

@implementation JMAppMenuUITests

#pragma mark - Tests
- (void)testThatMenuViewCanBeViewed
{
    // try to open side menu by tapping on button
    [self givenThatLibraryPageOnScreen];
    [self tryOpenSideApplicationMenu];
    [self verifyThatSideMenuVisible];
    [self tryCloseSideApplicationMenuByButtonTap];
    [self givenThatLibraryPageOnScreen];

    // try to open side menu by swipe
    [self tryOpenSideApplicationMenuBySwipe];
    [self verifyThatSideMenuVisible];
    [self tryCloseSideApplicationMenuBySwipe];
    [self givenThatLibraryPageOnScreen];
}

- (void)testThatMenuViewIsScrollable
{
    // try to open side menu by tapping on button
    [self givenThatLibraryPageOnScreen];
    [self tryOpenSideApplicationMenu];
    [self verifyThatSideMenuVisible];

    XCUIElement *menuView = self.application.otherElements[@"JMSideApplicationMenuAccessibilityId"];
    if (menuView.exists) {
        [menuView swipeUp];
        [menuView swipeDown];
    }
    [self tryCloseSideApplicationMenuByButtonTap];
    [self givenThatLibraryPageOnScreen];
}

- (void)testThatMenuViewCanSelectItems
{
    // try to open side menu by tapping on button
    [self givenThatLibraryPageOnScreen];
    [self tryOpenSideApplicationMenu];
    [self verifyThatSideMenuVisible];

    XCUIElement *menuView = self.application.otherElements[@"JMSideApplicationMenuAccessibilityId"];
    if (menuView.exists) {
        // Check all collection screen items
        NSArray *itemsArray = @[@"Library", @"Repository", @"Recently Viewed", @"Saved Items", @"Favorites", @"Schedules"];
        for (NSString *itemName in itemsArray) {
            XCUIElement *pageMenuItem = menuView.cells.staticTexts[itemName];
            if (pageMenuItem.exists) {
                [pageMenuItem tap];
            }
            [self tryOpenSideApplicationMenu];
            [self verifyThatSideMenuVisible];
        }
        
        // Check About item
        XCUIElement *aboutMenuItem = menuView.cells.staticTexts[@"About"];
        if (aboutMenuItem.exists) {
            [aboutMenuItem tap];
        }
        XCUIElement *doneButton = self.application.buttons[@"Done"];
        if (doneButton.exists) {
            [doneButton tap];
        } else {
            XCTFail(@"'Done' button doesn't exist.");
        }

        // Check Settings item
        [self tryOpenSideApplicationMenu];
        [self verifyThatSideMenuVisible];
        
        XCUIElement *settingsMenuItem = menuView.cells.staticTexts[@"Settings"];
        if (settingsMenuItem.exists) {
            [settingsMenuItem tap];
        }
        XCUIElement *cancelButton = self.application.buttons[@"Cancel"];
        if (cancelButton.exists) {
            [cancelButton tap];
        } else {
            XCTFail(@"'Settings' button doesn't exist.");
        }
    }
}

- (void)testThatServerProfileInfoIsAppeared
{
    // try to open side menu by tapping on button
    [self givenThatLibraryPageOnScreen];
    [self tryOpenSideApplicationMenu];
    [self verifyThatSideMenuVisible];
    
    XCUIElement *userNameLabel = self.application.staticTexts[kJMTestProfileCredentialsUsername];
    if (!userNameLabel.exists) {
        XCTFail(@"'Username' label doesn't exist.");
    }
    
    NSString *fullServerNameString = [NSString stringWithFormat:@"%@ (v.%@)", kJMTestProfileName, @"6.2.0"];
    XCUIElement *serverAliasLabel = self.application.staticTexts[fullServerNameString];
    if (!serverAliasLabel.exists) {
        XCTFail(@"'Server Alias' label doesn't exist.");
    }
    XCUIElement *organizationLabel = self.application.staticTexts[kJMTestProfileCredentialsOrganization];
    if (!organizationLabel.exists) {
        XCTFail(@"'Organization' label doesn't exist.");
    }
    
//    NSString *bundleVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
//    NSString *buildVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];
//    NSString *fullBuildVersion = [NSString stringWithFormat:@"v. %@ (%@)", bundleVersion, buildVersion];
//    XCUIElement *buildVersionLabel = self.application.staticTexts[fullBuildVersion];
//    if (!buildVersionLabel.exists) {
//        XCTFail(@"'Build Version' label doesn't exist.");
//    }
}


#pragma mark - Helpers

- (void)verifyThatSideMenuVisible
{
    XCUIElement *menuView = self.application.otherElements[@"JMSideApplicationMenuAccessibilityId"];
    if (menuView.exists) {
        [self givenThatCellsAreVisible];
    } else {
        XCTFail(@"'Side Menu' doesn't exist.");
    }
}

- (void)tryCloseSideApplicationMenuByButtonTap
{
    XCUIElement *menuButton = self.application.buttons[@"menu icon"];
    if (menuButton.exists) {
        [menuButton tap];
    } else {
        XCTFail(@"'Menu' button doesn't exist.");
    }
}

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
