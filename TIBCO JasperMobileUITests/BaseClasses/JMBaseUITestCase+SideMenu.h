//
// Created by Aleksandr Dakhno on 9/16/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JMBaseUITestCase.h"

@interface JMBaseUITestCase (SideMenu)

- (void)showSideMenuInSectionWithAccessibilityId:(NSString *)accessibilityId;
- (void)hideSideMenuInSectionWithAccessibilityId:(NSString *)accessibilityId;

- (void)waitNotificationOnMenuButtonWithTimeout:(NSTimeInterval)timeout;

- (void)openLibrarySection;
- (void)openRepositorySection;
- (void)openSavedItemsSection;
- (void)openFavoritesSection;
- (void)openSchedulesSection;

- (void)selectAbout;
- (void)selectSettings;
- (void)selectFeedback;
- (void)selectLogOut;

- (void)selectMenuItemForPageWithAccessibilityId:(NSString *)accessibilityId;

- (XCUIElement *)findMenuItemForPageAccessibilityId:(NSString *)accessibilityId;

- (void)verifySideMenuVisible;

- (void)verifySideMenuNotVisible;
@end
