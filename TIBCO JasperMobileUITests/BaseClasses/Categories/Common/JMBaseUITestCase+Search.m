//
// Created by Aleksandr Dakhno on 12/11/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMBaseUITestCase+Search.h"
#import "JMBaseUITestCase+Helpers.h"
#import "JMBaseUITestCase+Buttons.h"
#import "JMBaseUITestCase+SideMenu.h"


@implementation JMBaseUITestCase (Search)

- (void)performSearchResourceWithName:(NSString *)resourceName
         inSectionWithAccessibilityId:(NSString *)sectionId
{
    XCUIElement *searchField = [self searchFieldFromSectionWithAccessibilityId:sectionId];
    [searchField tap];

    // Clear text if exist
    XCUIElement *clearTextButton = [self waitElementMatchingType:XCUIElementTypeButton
                                                            text:@"Clear text"
                                                   parentElement:searchField
                                                         timeout:0];
    if (clearTextButton.exists) {
        [clearTextButton tap];
    }

    [searchField typeText:resourceName];

    [self tapButtonWithText:@"Search"
              parentElement:nil
                shouldCheck:YES];
}

- (void)performSearchResourceWithName:(NSString *)resourceName
                    inSectionWithName:(NSString *)sectionName
{
    if ([sectionName isEqualToString:JMLocalizedString(@"menuitem_library_label")]) {
        [self openLibrarySectionIfNeed];
        // TODO: replace with specific element - JMLibraryPageAccessibilityId
        [self performSearchResourceWithName:resourceName
               inSectionWithAccessibilityId:@"JMBaseCollectionContentViewAccessibilityId"];
    } else if ([sectionName isEqualToString:@"Repository"]) {
        [self openRepositorySectionIfNeed];
        // TODO: replace with specific element - JMRepositoryPageAccessibilityId
        [self performSearchResourceWithName:resourceName
               inSectionWithAccessibilityId:@"JMBaseCollectionContentViewAccessibilityId"];
    } else if ([sectionName isEqualToString:@"Favorites"]) {
        [self openFavoritesSectionIfNeed];
        // TODO: replace with specific element - JMRepositoryPageAccessibilityId
        [self performSearchResourceWithName:resourceName
               inSectionWithAccessibilityId:@"JMBaseCollectionContentViewAccessibilityId"];
    } else {
        XCTFail(@"Wrong section for searching test dashboard: %@", sectionName);
    }
}

- (void)clearSearchResultInSectionWithAccessibilityId:(NSString *)sectionAccessibilityId
{
    XCUIElement *searchResourcesSearchField = [self searchFieldFromSectionWithAccessibilityId:sectionAccessibilityId];
    [searchResourcesSearchField tap];

    [self tapButtonWithText:@"Clear text"
              parentElement:searchResourcesSearchField
                shouldCheck:NO];

    [self tapCancelButtonOnNavBarWithTitle:nil];
}

- (XCUIElement *)searchFieldFromSectionWithAccessibilityId:(NSString *)accessibilityId
{
    XCUIElement *section = [self waitElementMatchingType:XCUIElementTypeOther
                                              identifier:accessibilityId
                                                 timeout:kUITestsBaseTimeout];
    XCUIElement *searchField;
    if (section.exists) {
        searchField = [self waitElementMatchingType:XCUIElementTypeSearchField
                                               text:@"Search resources"
                                      parentElement:section
                                            timeout:kUITestsBaseTimeout];
        if (!searchField.exists) {
            XCTFail(@"Search field wasn't found");
        }
    } else {
        XCTFail(@"Section wasn't found");
    }

    return searchField;
}

@end