/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.6
 */

#import "JMBaseUITestCase+SideMenu.h"
#import "JMBaseUITestCase+Helpers.h"
#import "JMBaseUITestCase+Buttons.h"
#import "XCUIElement+Tappable.h"


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
    [self verifyButtonExistWithId:@"menu icon note" // We don't have translation for this button
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
    XCUIElement *navigationBar = [self findNavigationBarWithLabel:JMLocalizedString(@"menuitem_repository_label")];
    if (navigationBar.exists) {
        return;
    }
    [self tryOpenPageWithName:JMLocalizedString(@"menuitem_repository_label")
          fromSectionWithName:nil];
}

- (void)openRecentlyViewedSectionIfNeed
{
    XCUIElement *navigationBar = [self findNavigationBarWithLabel:JMLocalizedString(@"menuitem_recentviews_label")];
    if (navigationBar.exists) {
        return;
    }
    [self tryOpenPageWithName:JMLocalizedString(@"menuitem_recentviews_label")
          fromSectionWithName:nil];
}

- (void)openSavedItemsSectionIfNeed
{
    XCUIElement *navigationBar = [self findNavigationBarWithLabel:JMLocalizedString(@"menuitem_saveditems_label")];
    if (navigationBar.exists) {
        return;
    }
    [self tryOpenPageWithName:JMLocalizedString(@"menuitem_saveditems_label")
          fromSectionWithName:nil];
}

- (void)openFavoritesSectionIfNeed
{
    XCUIElement *navigationBar = [self findNavigationBarWithLabel:JMLocalizedString(@"menuitem_favorites_label")];
    if (navigationBar.exists) {
        return;
    }
    [self tryOpenPageWithName:JMLocalizedString(@"menuitem_favorites_label")
          fromSectionWithName:nil];
}

- (void)openSchedulesSectionIfNeed
{
    XCUIElement *navigationBar = [self findNavigationBarWithLabel:JMLocalizedString(@"menuitem_schedules_label")];
    if (navigationBar.exists) {
        return;
    }
    [self tryOpenPageWithName:JMLocalizedString(@"menuitem_schedules_label")
          fromSectionWithName:nil];
}

- (void)selectAbout
{
    [self tryOpenPageWithName:JMLocalizedString(@"menuitem_about_label")
          fromSectionWithName:nil];
}

- (void)selectSettings
{
    [self tryOpenPageWithName:JMLocalizedString(@"menuitem_settings_label")
          fromSectionWithName:nil];
}

- (void)selectFeedback
{
    [self tryOpenPageWithName:JMLocalizedString(@"menuitem_feedback_label")
          fromSectionWithName:nil];
}

- (void)selectLogOut
{
    [self tryOpenPageWithName:JMLocalizedString(@"menuitem_logout_label")
          fromSectionWithName:nil];
}

- (XCUIElement *)sideMenuElement
{
    XCUIElement *menuView = [self waitElementMatchingType:XCUIElementTypeOther
                                               identifier:@"JMSideApplicationMenuAccessibilityId"
                                                  timeout:kUITestsElementAvailableTimeout];
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
    [self givenSideMenuVisible];
    [self selectMenuItemForPageWithName:pageName];
}

- (void)selectMenuItemForPageWithName:(NSString *)pageName
{
    XCUIElement *pageMenuItem = [self findSideMenuItemForActionName:pageName];
    if (!pageMenuItem.exists) {
        NSString *pageNameWithNote = [NSString stringWithFormat:@"%@ note", pageName];
        pageMenuItem = [self findSideMenuItemForActionName:pageNameWithNote];
    }
    [pageMenuItem tapByWaitingHittable];
}

- (XCUIElement *)findSideMenuItemForActionName:(NSString *)pageName
{
    XCUIElement *menuView = [self waitElementMatchingType:XCUIElementTypeOther
                                               identifier:@"JMSideApplicationMenuAccessibilityId"
                                                  timeout:0];

    XCUIElement *label = [self waitElementMatchingType:XCUIElementTypeStaticText
                                                  text:pageName
                                         parentElement:menuView
                                               timeout:kUITestsElementAvailableTimeout];
    return label;
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
                                          filterPredicate:nil
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
        [menuButton tapByWaitingHittable];
    } else {
        XCTFail(@"Menu button wasn't found");
    }
}

@end
