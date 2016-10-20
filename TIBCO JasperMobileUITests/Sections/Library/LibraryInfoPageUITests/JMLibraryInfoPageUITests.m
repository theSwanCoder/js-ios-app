//
//  JMReportInfoPageUITests.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 2/19/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMLibraryInfoPageUITests.h"
#import "JMBaseUITestCase+InfoPage.h"
#import "JMBaseUITestCase+Favorites.h"

@implementation JMLibraryInfoPageUITests

#pragma mark - Tests - Main
- (void)testThatReportInfoPageCanBeViewed
{
    [self openInfoPageForTestReportFromSectionWithAccessibilityId:JMLibraryPageAccessibilityId];
    [self closeInfoPageForTestReport];
}

- (void)testThatReportInfoPageHasTitleAsReportLabel
{
    [self openInfoPageForTestReportFromSectionWithAccessibilityId:JMLibraryPageAccessibilityId];
    [self verifyThatInfoPageForTestReportHasCorrectTitle];
    [self closeInfoPageForTestReport];
}

- (void)testThatReportInfoPageHasFullReportInfo
{
    [self openInfoPageForTestReportFromSectionWithAccessibilityId:JMLibraryPageAccessibilityId];
    [self verifyThatInfoPageForTestReportContainsCorrectData];
    [self closeInfoPageForTestReport];
}

#pragma mark - Tests - Menu
- (void)testThatReportCanBeMarkAsFavorite
{
    [self openInfoPageForTestReportFromSectionWithAccessibilityId:JMLibraryPageAccessibilityId];
    [self markAsFavoriteFromMenuActions];
    [self unmarkFromFavoritesFromMenuActions];
    [self closeInfoPageForTestReport];
}

@end
