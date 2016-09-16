//
// Created by Aleksandr Dakhno on 9/16/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMBaseUITestCase+SideMenu.h"
#import "JMBaseUITestCase+Helpers.h"


@implementation JMBaseUITestCase (SideMenu)

- (void)showSideMenu;
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

- (void)openLibrarySection
{
    [self tryOpenPageWithName:@"Library"];
}

- (void)openRepositorySection
{
    [self tryOpenPageWithName:@"Repository"];
}

- (void)openRecentlyViewedSection
{
    [self tryOpenPageWithName:@"Recently Viewed"];
}

- (void)openSavedItemsSection
{
    [self tryOpenPageWithName:@"Saved Items"];
}

- (void)openFavoritesSection
{
    [self tryOpenPageWithName:@"Favorites"];
}

- (void)openSchedulesSection
{
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
    XCUIElement *menuView = [self waitElementWithAccessibilityId:@"JMSideApplicationMenuAccessibilityId"
                                                         timeout:kUITestsBaseTimeout];
    XCUIElement *pageMenuItem = menuView.cells.staticTexts[pageName];
    [self waitElement:pageMenuItem
              timeout:kUITestsBaseTimeout];
    [pageMenuItem tap];
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