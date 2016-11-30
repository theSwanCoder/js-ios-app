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
    [self openInfoPageForTestReportFromSectionWithName:@"Library"];
    [self closeInfoPageForTestReport];
}

- (void)testThatReportInfoPageHasTitleAsReportLabel
{
    [self openInfoPageForTestReportFromSectionWithName:@"Library"];
    [self verifyThatInfoPageForTestReportHasCorrectTitle];
    [self closeInfoPageForTestReport];
}

- (void)testThatReportInfoPageHasFullReportInfo
{
    [self openInfoPageForTestReportFromSectionWithName:@"Library"];
    [self verifyThatInfoPageForTestReportContainsCorrectData];
    [self closeInfoPageForTestReport];
}

#pragma mark - Tests - Menu
- (void)testThatReportCanBeMarkAsFavorite
{
    [self openInfoPageForTestReportFromSectionWithName:@"Library"];
    [self markAsFavoriteFromMenuActions];
    [self unmarkFromFavoritesFromMenuActions];
    [self closeInfoPageForTestReport];
}

@end
