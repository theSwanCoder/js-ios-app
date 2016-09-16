//
// Created by Aleksandr Dakhno on 9/16/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JMBaseUITestCase.h"

@interface JMBaseUITestCase (SideMenu)

- (void)showSideMenu;
- (void)hideSideMenu;

- (void)openLibrarySection;
- (void)openRepositorySection;
- (void)openRecentlyViewedSection;
- (void)openSavedItemsSection;
- (void)openFavoritesSection;
- (void)openSchedulesSection;

- (void)selectAbout;
- (void)selectSettings;
- (void)selectFeedback;
- (void)selectLogOut;

- (XCUIElement *)sideMenuElement;

@end