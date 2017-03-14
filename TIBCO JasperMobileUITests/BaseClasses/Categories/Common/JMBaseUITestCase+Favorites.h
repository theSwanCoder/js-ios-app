/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.6
 */

#import <Foundation/Foundation.h>
#import "JMBaseUITestCase.h"

@interface JMBaseUITestCase (Favorites)

- (void)givenThatFavoritesSectionIsEmpty;

// Reports
- (void)markTestReportAsFavoriteFromSectionWithName:(NSString *)sectionName;
- (void)unmarkTestReportFromFavoriteFromSectionWithName:(NSString *)sectionName;

// Dashboards
- (void)markTestDashboardAsFavoriteFromSectionWithName:(NSString *)sectionName;
- (void)unmarkTestDashboardFromFavoriteFromSectionWithName:(NSString *)sectionName;

// General methods
- (void)markAsFavoriteFromMenuActions;
- (void)unmarkFromFavoritesFromMenuActions;

- (void)markAsFavoriteFromNavigationBar:(XCUIElement *)navigationBar;
- (void)unmarkFromFavoritesFromNavigationBar:(XCUIElement *)navigationBar;
@end
