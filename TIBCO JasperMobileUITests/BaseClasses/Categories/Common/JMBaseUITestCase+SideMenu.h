//
// Created by Aleksandr Dakhno on 9/16/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

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
