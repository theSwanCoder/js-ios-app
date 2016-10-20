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
    [self givenSideMenuNotVisible];
    [self tryTapSideApplicationMenuInSectionWithAccessibilityId:accessibilityId];
    [self givenSideMenuVisible];
}

- (void)hideSideMenuInSectionWithAccessibilityId:(NSString *)accessibilityId
{
    [self givenSideMenuVisible];
    [self tryTapSideApplicationMenuInSectionWithAccessibilityId:accessibilityId];
    [self givenSideMenuNotVisible];
}

- (void)waitNotificationOnMenuButtonWithTimeout:(NSTimeInterval)timeout
{
    XCUIElement *navBar = [self waitNavigationBarWithLabel:nil
                                                   timeout:timeout];
    [self waitButtonWithAccessibilityId:JMSideApplicationMenuMenuButtonNoteAccessibilityId
                          parentElement:navBar
                                timeout:timeout];
}

- (void)openLibrarySection
{
    XCUIElement *navigationBar = [self findNavigationBarWithLabel:JMLibraryPageAccessibilityId];
    if (navigationBar.exists) {
        return;
    }
    [self tryOpenPageWithAccessibilityId:JMLibraryPageAccessibilityId
          fromSectionWithAccessibilityId:nil];
}

- (void)openRepositorySection
{
    XCUIElement *navigationBar = [self findNavigationBarWithLabel:JMRepositoryPageAccessibilityId];
    if (navigationBar.exists) {
        return;
    }
    [self tryOpenPageWithAccessibilityId:JMRepositoryPageAccessibilityId
          fromSectionWithAccessibilityId:nil];
}

- (void)openSavedItemsSection
{
    XCUIElement *navigationBar = [self findNavigationBarWithLabel:JMSavedItemsPageAccessibilityId];
    if (navigationBar.exists) {
        return;
    }
    [self tryOpenPageWithAccessibilityId:JMSavedItemsPageAccessibilityId
          fromSectionWithAccessibilityId:nil];
}

- (void)openFavoritesSection
{
    XCUIElement *navigationBar = [self findNavigationBarWithLabel:JMFavoritesPageAccessibilityId];
    if (navigationBar.exists) {
        return;
    }
    [self tryOpenPageWithAccessibilityId:JMFavoritesPageAccessibilityId
          fromSectionWithAccessibilityId:nil];
}

- (void)openSchedulesSection
{
    XCUIElement *navigationBar = [self findNavigationBarWithLabel:JMSchedulesPageAccessibilityId];
    if (navigationBar.exists) {
        return;
    }
    [self tryOpenPageWithAccessibilityId:JMSchedulesPageAccessibilityId
          fromSectionWithAccessibilityId:nil];
}

- (void)selectAbout
{
    [self tryOpenPageWithAccessibilityId:JMAppAboutPageAccessibilityId
          fromSectionWithAccessibilityId:nil];
}

- (void)selectSettings
{
    [self tryOpenPageWithAccessibilityId:JMSettingsPageAccessibilityId
          fromSectionWithAccessibilityId:nil];
}

- (void)selectFeedback
{
    [self tryOpenPageWithAccessibilityId:JMFeedbackPageAccessibilityId
          fromSectionWithAccessibilityId:nil];
}

- (void)selectLogOut
{
    [self tryOpenPageWithAccessibilityId:JMLogoutPageAccessibilityId
          fromSectionWithAccessibilityId:nil];
}

- (XCUIElement *)sideMenuElement
{
    XCUIElement *menuView = [self findElementWithAccessibilityId:JMSideApplicationMenuAccessibilityId];
    return menuView;
}

#pragma mark - Helpers

- (void)tryOpenPageWithAccessibilityId:(NSString *)accessibilityId
        fromSectionWithAccessibilityId:(NSString *)currentSectionAccessibilityId
{
    [self givenSideMenuNotVisible];
    [self tryTapSideApplicationMenuInSectionWithAccessibilityId:currentSectionAccessibilityId];
    [self selectMenuItemForPageWithAccessibilityId:accessibilityId];
}

- (void)selectMenuItemForPageWithAccessibilityId:(NSString *)accessibilityId
{
    XCUIElement *pageMenuItem = [self findMenuItemForPageAccessibilityId:accessibilityId];
    if (!pageMenuItem.exists) {
        NSString *pageNameWithNote = [NSString stringWithFormat:@"%@ note", accessibilityId];
        pageMenuItem = [self findMenuItemForPageAccessibilityId:pageNameWithNote];
    }
    [pageMenuItem tap];
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

- (void)givenSideMenuVisible
{
    [self waitElementWithAccessibilityId:JMSideApplicationMenuAccessibilityId
                                 timeout:kUITestsBaseTimeout];
}

- (void)givenSideMenuNotVisible
{
    XCUIElement *sideMenu = [self findElementWithAccessibilityId:JMSideApplicationMenuAccessibilityId];
    if (sideMenu.exists) {
        XCTFail(@"Side menu should not be visible");
    }
}

- (void)tryTapSideApplicationMenuInSectionWithAccessibilityId:(NSString *)accessibilityId
{
    XCUIElement *menuButton = [self findMenuButtonInSectionWithAccessibilityId:accessibilityId];
    [menuButton tap];
}

@end
