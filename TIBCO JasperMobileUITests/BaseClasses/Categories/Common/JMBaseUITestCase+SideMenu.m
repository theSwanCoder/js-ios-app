//
// Created by Aleksandr Dakhno on 9/16/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMBaseUITestCase+SideMenu.h"
#import "JMBaseUITestCase+Helpers.h"
#import "JMBaseUITestCase+Buttons.h"


@implementation JMBaseUITestCase (SideMenu)

- (void)showSideMenuInSectionWithName:(NSString *)sectionName
{
    [self givenSideMenuNotVisible];
    [self tryTapSideApplicationMenuInSectionWithName:sectionName];
    [self givenSideMenuVisible];
}

- (void)hideSideMenuInSectionWithName:(NSString *)sectionName
{
    [self givenSideMenuVisible];
    [self tryTapSideApplicationMenuInSectionWithName:sectionName];
    [self givenSideMenuNotVisible];
}

- (void)waitNotificationOnMenuButtonWithTimeout:(NSTimeInterval)timeout
{
    XCUIElement *navBar = [self waitNavigationBarWithLabel:nil
                                                   timeout:timeout];
    [self verifyButtonExistWithId:@"menu icon note"
                    parentElement:navBar];
}

- (void)openLibrarySectionIfNeed
{
    XCUIElement *navigationBar = [self findNavigationBarWithLabel:JMLocalizedString(@"menuitem_library_label")];
    if (navigationBar.exists) {
        return;
    }
    [self tryOpenPageWithName:JMLocalizedString(@"menuitem_library_label")
          fromSectionWithName:nil];
}

- (void)openRepositorySectionIfNeed
{
    XCUIElement *navigationBar = [self findNavigationBarWithLabel:@"Repository"];
    if (navigationBar.exists) {
        return;
    }
    [self tryOpenPageWithName:@"Repository"
          fromSectionWithName:nil];
}

- (void)openRecentlyViewedSectionIfNeed
{
    XCUIElement *navigationBar = [self findNavigationBarWithLabel:@"Recently Viewed"];
    if (navigationBar.exists) {
        return;
    }
    [self tryOpenPageWithName:@"Recently Viewed"
          fromSectionWithName:nil];
}

- (void)openSavedItemsSectionIfNeed
{
    XCUIElement *navigationBar = [self findNavigationBarWithLabel:@"Saved Items"];
    if (navigationBar.exists) {
        return;
    }
    [self tryOpenPageWithName:@"Saved Items"
          fromSectionWithName:nil];
}

- (void)openFavoritesSectionIfNeed
{
    XCUIElement *navigationBar = [self findNavigationBarWithLabel:@"Favorites"];
    if (navigationBar.exists) {
        return;
    }
    [self tryOpenPageWithName:@"Favorites"
          fromSectionWithName:nil];
}

- (void)openSchedulesSectionIfNeed
{
    XCUIElement *navigationBar = [self findNavigationBarWithLabel:@"Schedules"];
    if (navigationBar.exists) {
        return;
    }
    [self tryOpenPageWithName:@"Schedules"
          fromSectionWithName:nil];
}

- (void)selectAbout
{
    [self tryOpenPageWithName:@"About"
          fromSectionWithName:nil];
}

- (void)selectSettings
{
    [self tryOpenPageWithName:@"Settings"
          fromSectionWithName:nil];
}

- (void)selectFeedback
{
    [self tryOpenPageWithName:@"Feedback by email"
          fromSectionWithName:nil];
}

- (void)selectLogOut
{
    [self tryOpenPageWithName:@"Log Out"
          fromSectionWithName:nil];
}

- (XCUIElement *)sideMenuElement
{
    XCUIElement *menuView = [self waitElementMatchingType:XCUIElementTypeOther
                                               identifier:@"JMSideApplicationMenuAccessibilityId"
                                                  timeout:0];
    if (!menuView.exists) {
        XCTFail(@"Menu view wasn't found");
    }
    return menuView;
}

#pragma mark - Helpers

- (void)tryOpenPageWithName:(NSString *)pageName
        fromSectionWithName:(NSString *)sectionName
{
    [self givenSideMenuNotVisible];
    [self tryTapSideApplicationMenuInSectionWithName:sectionName];
    [self selectMenuItemForPageWithName:pageName];
}

- (void)selectMenuItemForPageWithName:(NSString *)pageName
{
    XCUIElement *pageMenuItem = [self findSideMenuItemForActionName:pageName];
    if (!pageMenuItem.exists) {
        NSString *pageNameWithNote = [NSString stringWithFormat:@"%@ note", pageName];
        pageMenuItem = [self findSideMenuItemForActionName:pageNameWithNote];
    }
    [pageMenuItem tap];
}

- (XCUIElement *)findSideMenuItemForActionName:(NSString *)pageName
{
    XCUIElement *menuView = [self waitElementMatchingType:XCUIElementTypeOther
                                               identifier:@"JMSideApplicationMenuAccessibilityId"
                                                  timeout:kUITestsBaseTimeout];
    XCUIElement *pageMenuItem;
    NSArray *allMenuItems = menuView.cells.allElementsBoundByAccessibilityElement;
    for (XCUIElement *menuItem in allMenuItems) {
        XCUIElement *label = [self waitElementMatchingType:XCUIElementTypeStaticText
                                                      text:pageName
                                             parentElement:menuItem
                                                   timeout:0];;
        if (label.exists) {
            pageMenuItem = menuItem;
            break;
        }
    }
    return pageMenuItem;
}

- (void)givenSideMenuVisible
{
    XCUIElement *menuView = [self waitElementMatchingType:XCUIElementTypeOther
                                               identifier:@"JMSideApplicationMenuAccessibilityId"
                                                  timeout:kUITestsBaseTimeout];
    if (!menuView.exists) {
        XCTFail(@"Side menu should be visible");
    }
}

- (void)givenSideMenuNotVisible
{
    XCUIElement *sideMenu = [self waitElementMatchingType:XCUIElementTypeOther
                                               identifier:@"JMSideApplicationMenuAccessibilityId"
                                            parentElement:nil
                                      shouldBeInHierarchy:NO
                                                  timeout:kUITestsBaseTimeout];
    if (sideMenu.exists) {
        XCTFail(@"Side menu should not be visible");
    }
}

- (void)tryTapSideApplicationMenuInSectionWithName:(NSString *)sectionName
{
    XCUIElement *menuButton = [self findMenuButtonOnNavBarWithTitle:sectionName];
    if (menuButton.exists) {
        [menuButton tap];
    } else {
        XCTFail(@"Menu button wasn't found");
    }
}

@end
