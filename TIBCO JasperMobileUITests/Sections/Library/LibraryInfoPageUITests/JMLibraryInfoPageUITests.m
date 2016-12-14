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

#pragma mark - JMBaseUITestCaseProtocol

- (NSInteger)testsCount
{
    return 4;
}

#pragma mark - Tests - Main
- (void)testThatReportInfoPageCanBeViewed
{
    [self openInfoPageForTestReportFromSectionWithName:JMLocalizedString(@"menuitem_library_label")];
    [self closeInfoPageForTestReport];
}

- (void)testThatReportInfoPageHasTitleAsReportLabel
{
    [self openInfoPageForTestReportFromSectionWithName:JMLocalizedString(@"menuitem_library_label")];
    [self verifyThatInfoPageForTestReportHasCorrectTitle];
    [self closeInfoPageForTestReport];
}

- (void)testThatReportInfoPageHasFullReportInfo
{
    [self openInfoPageForTestReportFromSectionWithName:JMLocalizedString(@"menuitem_library_label")];
    [self verifyThatInfoPageForTestReportContainsCorrectData];
    [self closeInfoPageForTestReport];
}

#pragma mark - Tests - Menu
- (void)testThatReportCanBeMarkAsFavorite
{
    [self openInfoPageForTestReportFromSectionWithName:JMLocalizedString(@"menuitem_library_label")];
    [self markAsFavoriteFromMenuActions];
    [self unmarkFromFavoritesFromMenuActions];
    [self closeInfoPageForTestReport];
}

@end
