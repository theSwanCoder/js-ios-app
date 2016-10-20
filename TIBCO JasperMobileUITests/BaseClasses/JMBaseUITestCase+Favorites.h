//
// Created by Aleksandr Dakhno on 10/3/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JMBaseUITestCase.h"

@interface JMBaseUITestCase (Favorites)

- (void)givenThatFavoritesSectionIsEmpty;

// Reports
- (void)markTestReportAsFavoriteFromSectionWithAccessibilityId:(NSString *)accessibilityId;
- (void)unmarkTestReportFromFavoriteFromSectionWithAccessibilityId:(NSString *)accessibilityId;

// Dashboards
- (void)markTestDashboardAsFavoriteFromSectionWithAccessibilityId:(NSString *)accessibilityId;
- (void)unmarkTestDashboardFromFavoriteFromSectionWithAccessibilityId:(NSString *)accessibilityId;

// General methods
- (void)markAsFavoriteFromMenuActions;
- (void)unmarkFromFavoritesFromMenuActions;

- (void)markAsFavoriteFromNavigationBar:(XCUIElement *)navigationBar;
- (void)unmarkFromFavoritesFromNavigationBar:(XCUIElement *)navigationBar;
@end
