/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.6
 */

#import <Foundation/Foundation.h>
#import "JMBaseUITestCase.h"

@interface JMBaseUITestCase (SideMenu)

- (void)showSideMenuInSectionWithName:(NSString *)sectionName;
- (void)hideSideMenuInSectionWithName:(NSString *)sectionName;

- (void)waitNotificationOnMenuButtonWithTimeout:(NSTimeInterval)timeout;

- (void)openLibrarySectionIfNeed;
- (void)openRepositorySectionIfNeed;
- (void)openRecentlyViewedSectionIfNeed;
- (void)openSavedItemsSectionIfNeed;
- (void)openFavoritesSectionIfNeed;
- (void)openSchedulesSectionIfNeed;

- (void)selectAbout;
- (void)selectSettings;
- (void)selectFeedback;
- (void)selectLogOut;

- (XCUIElement *)sideMenuElement;

- (void)selectMenuItemForPageWithName:(NSString *)pageName;

- (XCUIElement *)findSideMenuItemForActionName:(NSString *)pageName;
@end
