//
//  JMServerProfilesUITests.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 2/14/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMServerProfilesUITests.h"

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
    [self tryBackToPreviousPage];
}

- (void)testThatServerProfileCanBeSelected
{
    [self tryOpenServerProfilesPage];
    
    NSInteger cellsCount = self.application.collectionViews.cells.count;
    if (cellsCount) {
        [self givenThatCellsAreVisible];
        XCUIElement *serverProfileCell = self.application.collectionViews.cells.allElementsBoundByIndex.firstObject;
        if (serverProfileCell.exists) {
            [serverProfileCell tap];
        }
    } else {
        [self tryOpenNewServerProfilePage];
        [self givenThatNewProfilePageOnScreen];
        [self tryCreateNewTestServerProfile];
        
        [self givenThatServerProfilesPageOnScreen];
    }
    [self tryBackToPreviousPage];
}

- (void)testThatServerProfileCanBeAdded
{
    [self tryOpenServerProfilesPage];
    XCUIElement *testProfile = self.application.collectionViews.staticTexts[@"Test Profile"];
    if (testProfile.exists) {
        [testProfile pressForDuration:1.0];
        [testProfile pressForDuration:1.1];
        XCUIElement *menu = self.application.menuItems[@"Delete"];
        if (menu) {
            [menu tap];
            XCUIElement *deleteButton = self.application.alerts[@"Confirmation"].collectionViews.buttons[@"Delete"];
            if (deleteButton) {
                [deleteButton tap];
            } else {
                XCTFail(@"Delete button doesn't exist.");
            }
        } else {
            XCTFail(@"Delete menu item doesn't exist.");
        }
    }
    
    NSInteger startCellsCount = self.application.collectionViews.cells.count;
    [self tryOpenNewServerProfilePage];
    [self givenThatNewProfilePageOnScreen];
    [self tryCreateNewTestServerProfile];
    NSInteger endCellsCount = self.application.collectionViews.cells.count;
    XCTAssertTrue(endCellsCount > startCellsCount);
    [self tryBackToPreviousPage];
}

- (void)testThatServerProfileCanBeDeleted
{
    [self tryOpenServerProfilesPage];
    
    NSInteger cellsCount = self.application.collectionViews.cells.count;
    if (!cellsCount) {
        [self tryOpenNewServerProfilePage];
        [self givenThatNewProfilePageOnScreen];
        [self tryCreateNewTestServerProfile];
        
        [self givenThatServerProfilesPageOnScreen];
    }
    
    NSInteger startCellsCount = self.application.collectionViews.cells.count;
    XCUIElement *serverProfile = self.application.collectionViews.cells.allElementsBoundByIndex.firstObject;
    if (serverProfile.exists) {
        [serverProfile pressForDuration:1.0];
        [serverProfile pressForDuration:1.1];
        XCUIElement *menu = self.application.menuItems[@"Delete"];
        if (menu) {
            [menu tap];
            XCUIElement *deleteButton = self.application.alerts[@"Confirmation"].collectionViews.buttons[@"Delete"];
            if (deleteButton) {
                [deleteButton tap];
            } else {
                XCTFail(@"Delete button doesn't exist.");
            }
        } else {
            XCTFail(@"Delete menu item doesn't exist.");
        }
    }

    NSInteger endCellsCount = self.application.collectionViews.cells.count;
    XCTAssertTrue(endCellsCount < startCellsCount);
    [self tryBackToPreviousPage];
}

- (void)testThatServerProfileCanBeCloned
{
    [self tryOpenServerProfilesPage];
    
    NSInteger cellsCount = self.application.collectionViews.cells.count;
    if (!cellsCount) {
        [self tryOpenNewServerProfilePage];
        [self givenThatNewProfilePageOnScreen];
        [self tryCreateNewTestServerProfile];
        
        [self givenThatServerProfilesPageOnScreen];
    }
    
    NSInteger startCellsCount = self.application.collectionViews.cells.count;
    XCUIElement *serverProfile = self.application.collectionViews.cells.allElementsBoundByIndex.firstObject;
    if (serverProfile.exists) {
        [serverProfile pressForDuration:1.0];
        [serverProfile pressForDuration:1.1];
        XCUIElement *menu = self.application.menuItems[@"Clone"];
        if (menu) {
            [menu tap];
            [self givenThatNewProfilePageOnScreen];
            // Save a new created profile
            XCUIElement *saveButton = self.application.buttons[@"Save"];
            if (saveButton.exists) {
                [saveButton tap];
            } else {
                XCTFail(@"Create new profile button doesn't exist.");
            }
            
            // Confirm if need http end point
            XCUIElement *securityWarningAlert = self.application.alerts[@"Warning"];
            if (securityWarningAlert.exists) {
                NSString *okButtonTitle = JMLocalizedString(@"dialog_button_ok");
                NSLog(@"okButtonTitle: %@", okButtonTitle);
                XCUIElement *securityWarningAlertOkButton = securityWarningAlert.collectionViews.buttons[okButtonTitle];
                if (securityWarningAlertOkButton.exists) {
                    [securityWarningAlertOkButton tap];
                } else {
                    XCTFail(@"'Ok' button on security warning alert doesn't exist.");
                }
            }
        } else {
            XCTFail(@"Delete menu item doesn't exist.");
        }
    }
    
    NSInteger endCellsCount = self.application.collectionViews.cells.count;
    XCTAssertTrue(endCellsCount > startCellsCount);
    [self tryBackToPreviousPage];
}


#pragma mark - JMBaseUITestProtocol
- (BOOL) shouldLoginBeforeStartTest
{
    return NO;
}

@end
