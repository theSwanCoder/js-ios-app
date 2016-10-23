//
// Created by Aleksandr Dakhno on 9/16/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMBaseUITestCase+SideMenu.h"
#import "JMBaseUITestCase+Helpers.h"
#import "JMBaseUITestCase+ActionsMenu.h"


@implementation JMBaseUITestCase (SideMenu)

- (void)showSideMenuInSectionWithAccessibilityId:(NSString *)accessibilityId
{
    [self verifySideMenuNotVisible];
    [self tryTapSideApplicationMenuInSectionWithAccessibilityId:accessibilityId];
    [self verifySideMenuVisible];
}

- (void)hideSideMenuInSectionWithAccessibilityId:(NSString *)accessibilityId
{
    [self verifySideMenuVisible];
    [self tryTapSideApplicationMenuInSectionWithAccessibilityId:accessibilityId];
    [self verifySideMenuNotVisible];
}

- (void)waitNotificationOnMenuButtonWithTimeout:(NSTimeInterval)timeout
{
    XCUIElement *navBar = [self waitNavigationBarWithControllerAccessibilityId:nil
                                                   timeout:timeout];
    [self waitButtonWithAccessibilityId:JMSideApplicationMenuMenuButtonNoteAccessibilityId
                          parentElement:navBar
                                timeout:timeout];
}

- (void)openLibrarySection
{
    [self showSideMenuInSectionWithAccessibilityId:nil];
    [self selectMenuItemForPageWithAccessibilityId:JMLibraryPageAccessibilityId];
}

- (void)openRepositorySection
{
    [self showSideMenuInSectionWithAccessibilityId:nil];
    [self selectMenuItemForPageWithAccessibilityId:JMRepositoryPageAccessibilityId];
}

- (void)openSavedItemsSection
{
    [self showSideMenuInSectionWithAccessibilityId:nil];
    [self selectMenuItemForPageWithAccessibilityId:JMSavedItemsPageAccessibilityId];
}

- (void)openFavoritesSection
{
    [self showSideMenuInSectionWithAccessibilityId:nil];
    [self selectMenuItemForPageWithAccessibilityId:JMFavoritesPageAccessibilityId];
}

- (void)openSchedulesSection
{
    [self showSideMenuInSectionWithAccessibilityId:nil];
    [self selectMenuItemForPageWithAccessibilityId:JMSchedulesPageAccessibilityId];
}

- (void)selectAbout
{
    [self showSideMenuInSectionWithAccessibilityId:nil];
    [self selectMenuItemForPageWithAccessibilityId:JMAppAboutPageAccessibilityId];
}

- (void)selectSettings
{
    [self showSideMenuInSectionWithAccessibilityId:nil];
    [self selectMenuItemForPageWithAccessibilityId:JMSettingsPageAccessibilityId];
}

- (void)selectFeedback
{
    [self showSideMenuInSectionWithAccessibilityId:nil];
    [self selectMenuItemForPageWithAccessibilityId:JMFeedbackPageAccessibilityId];
}

- (void)selectLogOut
{
    [self showSideMenuInSectionWithAccessibilityId:nil];
    [self selectMenuItemForPageWithAccessibilityId:JMLogoutPageAccessibilityId];
}

- (void)selectMenuItemForPageWithAccessibilityId:(NSString *)accessibilityId
{
    XCUIElement *pageMenuItem = [self findMenuItemForPageAccessibilityId:accessibilityId];
    if (!pageMenuItem.exists) {
        NSString *pageNameWithNote = [NSString stringWithFormat:@"%@ note", accessibilityId];
        pageMenuItem = [self findMenuItemForPageAccessibilityId:pageNameWithNote];
    }
    [pageMenuItem tap];
    [self verifySideMenuNotVisible];
}

- (XCUIElement *)findMenuItemForPageAccessibilityId:(NSString *)accessibilityId
{
    XCUIElement *menuView = [self waitElementWithAccessibilityId:JMSideApplicationMenuAccessibilityId
                                                         timeout:kUITestsBaseTimeout];
    
    XCUIElementQuery *menuItemsQuery = [menuView.cells matchingType:XCUIElementTypeCell
                                                         identifier:accessibilityId];
    
    NSArray *allMenuItems = menuItemsQuery.allElementsBoundByAccessibilityElement;
    XCUIElement *pageMenuItem = allMenuItems.firstObject;
    
    return pageMenuItem;
}

#pragma mark - Helpers
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

- (void)tryTapSideApplicationMenuInSectionWithAccessibilityId:(NSString *)accessibilityId
{
    XCUIElement *menuButton = [self findMenuButtonInSectionWithAccessibilityId:accessibilityId];
    [menuButton tap];
}

- (XCUIElement *)sideMenuElement
{
    XCUIElement *menuView = [self findElementWithAccessibilityId:JMSideApplicationMenuAccessibilityId];
    return menuView;
}

@end
