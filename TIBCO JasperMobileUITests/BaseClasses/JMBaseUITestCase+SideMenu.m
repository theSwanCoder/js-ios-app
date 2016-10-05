//
// Created by Aleksandr Dakhno on 9/16/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMBaseUITestCase+SideMenu.h"
#import "JMBaseUITestCase+Helpers.h"


@implementation JMBaseUITestCase (SideMenu)

- (void)showSideMenu
{
    [self givenSideMenuNotVisible];
    [self tryTapSideApplicationMenu];
    [self givenSideMenuVisible];
}

- (void)hideSideMenu
{
    [self givenSideMenuVisible];
    [self tryTapSideApplicationMenu];
    [self givenSideMenuNotVisible];
}

- (void)waitNotificationOnMenuButtonWithTimeout:(NSTimeInterval)timeout
{
    XCUIElement *navBar = [self waitNavigationBarWithLabel:nil
                                                   timeout:timeout];
    [self waitButtonWithAccessibilityId:@"menu icon note"
                          parentElement:navBar
                                timeout:timeout];
}

- (void)openLibrarySection
{
    XCUIElement *navigationBar = [self findNavigationBarWithLabel:@"Library"];
    if (navigationBar.exists) {
        return;
    }
    [self tryOpenPageWithName:@"Library"];
}

- (void)openRepositorySection
{
    XCUIElement *navigationBar = [self findNavigationBarWithLabel:@"Repository"];
    if (navigationBar.exists) {
        return;
    }
    [self tryOpenPageWithName:@"Repository"];
}

- (void)openRecentlyViewedSection
{
    XCUIElement *navigationBar = [self findNavigationBarWithLabel:@"Recently Viewed"];
    if (navigationBar.exists) {
        return;
    }
    [self tryOpenPageWithName:@"Recently Viewed"];
}

- (void)openSavedItemsSection
{
    XCUIElement *navigationBar = [self findNavigationBarWithLabel:@"Saved Items"];
    if (navigationBar.exists) {
        return;
    }
    [self tryOpenPageWithName:@"Saved Items"];
}

- (void)openFavoritesSection
{
    XCUIElement *navigationBar = [self findNavigationBarWithLabel:@"Favorites"];
    if (navigationBar.exists) {
        return;
    }
    [self tryOpenPageWithName:@"Favorites"];
}

- (void)openSchedulesSection
{
    XCUIElement *navigationBar = [self findNavigationBarWithLabel:@"Schedules"];
    if (navigationBar.exists) {
        return;
    }
    [self tryOpenPageWithName:@"Schedules"];
}

- (void)selectAbout
{
    [self tryOpenPageWithName:@"About"];
}

- (void)selectSettings
{
    [self tryOpenPageWithName:@"Settings"];
}

- (void)selectFeedback
{
    [self tryOpenPageWithName:@"Feedback by email"];
}

- (void)selectLogOut
{
    [self tryOpenPageWithName:@"Log Out"];
}

- (XCUIElement *)sideMenuElement
{
    XCUIElement *menuView = [self findElementWithAccessibilityId:@"JMSideApplicationMenuAccessibilityId"];
    return menuView;
}

#pragma mark - Helpers

- (void)tryOpenPageWithName:(NSString *)pageName
{
    [self givenSideMenuNotVisible];
    [self tryTapSideApplicationMenu];
    
    XCUIElement *pageMenuItem = [self findMenuItemForPageName:pageName];
    if (!pageMenuItem) {
        NSString *pageNameWithNote = [NSString stringWithFormat:@"%@ note", pageName];
        pageMenuItem = [self findMenuItemForPageName:pageNameWithNote];
    }
    [pageMenuItem tap];
}

- (XCUIElement *)findMenuItemForPageName:(NSString *)pageName
{
    XCUIElement *menuView = [self waitElementWithAccessibilityId:@"JMSideApplicationMenuAccessibilityId"
                                                         timeout:kUITestsBaseTimeout];
    XCUIElement *pageMenuItem;
    NSArray *allMenuItems = menuView.cells.allElementsBoundByAccessibilityElement;
    for (XCUIElement *menuItem in allMenuItems) {
        XCUIElement *label = [self findStaticTextWithText:pageName
                                            parentElement:menuItem];
        if (label.exists) {
            pageMenuItem = menuItem;
            break;
        }
    }
    return pageMenuItem;
}

- (void)givenSideMenuVisible
{
    [self waitElementWithAccessibilityId:@"JMSideApplicationMenuAccessibilityId"
                                 timeout:kUITestsBaseTimeout];
}

- (void)givenSideMenuNotVisible
{
    XCUIElement *sideMenu = [self findElementWithAccessibilityId:@"JMSideApplicationMenuAccessibilityId"];
    if (sideMenu) {
        XCTFail(@"Side menu should not be visible");
    }
}

- (void)tryTapSideApplicationMenu
{
    XCUIElement *menuButton = [self waitMenuButtonWithTimeout:kUITestsBaseTimeout];
    [menuButton tap];
}

@end
