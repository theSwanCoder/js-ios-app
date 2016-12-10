//
// Created by Aleksandr Dakhno on 9/16/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMBaseUITestCase+SideMenu.h"
#import "JMBaseUITestCase+Helpers.h"
#import "JMBaseUITestCase+ActionsMenu.h"


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
    XCUIElement *menuIconNote = [self waitElementMatchingType:XCUIElementTypeButton
                                                   identifier:@"menu icon note"
                                                parentElement:navBar
                                                      timeout:timeout];
    if (!menuIconNote.exists) {
        XCTFail(@"Menu icon with note wasn't appeared");
    }
}

- (void)openLibrarySection
{
    XCUIElement *navigationBar = [self findNavigationBarWithLabel:@"Library"];
    if (navigationBar.exists) {
        return;
    }
    [self tryOpenPageWithName:@"Library"
          fromSectionWithName:nil];
}

- (void)openRepositorySection
{
    XCUIElement *navigationBar = [self findNavigationBarWithLabel:@"Repository"];
    if (navigationBar.exists) {
        return;
    }
    [self tryOpenPageWithName:@"Repository"
          fromSectionWithName:nil];
}

- (void)openRecentlyViewedSection
{
    XCUIElement *navigationBar = [self findNavigationBarWithLabel:@"Recently Viewed"];
    if (navigationBar.exists) {
        return;
    }
    [self tryOpenPageWithName:@"Recently Viewed"
          fromSectionWithName:nil];
}

- (void)openSavedItemsSection
{
    XCUIElement *navigationBar = [self findNavigationBarWithLabel:@"Saved Items"];
    if (navigationBar.exists) {
        return;
    }
    [self tryOpenPageWithName:@"Saved Items"
          fromSectionWithName:nil];
}

- (void)openFavoritesSection
{
    XCUIElement *navigationBar = [self findNavigationBarWithLabel:@"Favorites"];
    if (navigationBar.exists) {
        return;
    }
    [self tryOpenPageWithName:@"Favorites"
          fromSectionWithName:nil];
}

- (void)openSchedulesSection
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
                                                  timeout:kUITestsBaseTimeout];
    if (sideMenu.exists) {
        XCTFail(@"Side menu should not be visible");
    }
}

- (void)tryTapSideApplicationMenuInSectionWithName:(NSString *)sectionName
{
    XCUIElement *navBar = [self waitNavigationBarWithLabel:sectionName
                                                   timeout:kUITestsBaseTimeout];
    XCUIElement *menuButton = [self findMenuButtonOnParentElement:navBar];
    if (menuButton.exists) {
        [menuButton tap];
    } else {
        XCTFail(@"Menu button wasn't found");
    }
}

@end
