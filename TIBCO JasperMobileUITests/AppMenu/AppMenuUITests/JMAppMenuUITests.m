//
//  JMAppMenuUITests.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 2/19/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMAppMenuUITests.h"
#import "JMBaseUITestCase+Helpers.h"

@implementation JMAppMenuUITests

#pragma mark - Tests
- (void)testThatMenuViewCanBeViewed
{
    // try to open side menu by tapping on button
    [self givenThatLibraryPageOnScreen];
    [self tryTapSideApplicationMenu];
    [self givenSideMenuVisible];
    [self tryTapSideApplicationMenu];
    [self givenThatLibraryPageOnScreen];

    // try to open side menu by swipe
    [self tryOpenSideApplicationMenuBySwipe];
    [self givenSideMenuVisible];
    [self tryCloseSideApplicationMenuBySwipe];
    [self givenThatLibraryPageOnScreen];
}

- (void)testThatMenuViewIsScrollable
{
    // try to open side menu by tapping on button
    [self givenThatLibraryPageOnScreen];
    [self tryTapSideApplicationMenu];
    [self givenSideMenuVisible];

    XCUIElement *menuView = [self findElementWithAccessibilityId:@"JMSideApplicationMenuAccessibilityId"];;
    if (menuView.exists) {
        [menuView swipeUp];
        [menuView swipeDown];
    }
    [self tryTapSideApplicationMenu];
    [self givenThatLibraryPageOnScreen];
}

- (void)testThatMenuViewCanSelectItems
{
    // try to open side menu by tapping on button
    [self givenThatLibraryPageOnScreen];
    [self tryTapSideApplicationMenu];
    [self givenSideMenuVisible];

    XCUIElement *menuView = [self findElementWithAccessibilityId:@"JMSideApplicationMenuAccessibilityId"];;
    if (menuView.exists) {
        // Check all collection screen items
        NSArray *itemsArray = @[@"Library", @"Repository", @"Recently Viewed", @"Saved Items", @"Favorites", @"Schedules"];
        for (NSString *itemName in itemsArray) {
            XCUIElement *pageMenuItem = menuView.cells.staticTexts[itemName];
            if (pageMenuItem.exists) {
                [pageMenuItem tap];
            }
            [self tryTapSideApplicationMenu];
            [self givenSideMenuVisible];
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
        [self tryTapSideApplicationMenu];
        [self givenSideMenuVisible];
        
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
    [self tryTapSideApplicationMenu];
    [self givenSideMenuVisible];
    
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
    
    [self tryTapSideApplicationMenu];
    [self givenSideMenuNotVisible];
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
