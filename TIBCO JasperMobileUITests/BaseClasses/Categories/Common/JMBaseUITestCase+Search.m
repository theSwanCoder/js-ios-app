//
// Created by Aleksandr Dakhno on 12/11/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMBaseUITestCase+Search.h"
#import "JMBaseUITestCase+Helpers.h"
#import "JMBaseUITestCase+Buttons.h"
#import "JMBaseUITestCase+SideMenu.h"
#import "XCUIElement+Tappable.h"


@implementation JMBaseUITestCase (Search)

- (void)performSearchResourceWithName:(NSString *)resourceName
         inSectionWithAccessibilityId:(NSString *)sectionId
{
    XCUIElement *searchField = [self searchFieldFromSectionWithAccessibilityId:sectionId];
    [searchField tapByWaitingHittable];

    // Clear text if exist
    XCUIElement *clearTextButton = [self waitElementMatchingType:XCUIElementTypeButton
                                                            text:@"Clear text"
                                                   parentElement:searchField
                                                         timeout:kUITestsElementAvailableTimeout];
    if (clearTextButton.exists) {
        [clearTextButton tapByWaitingHittable];
    }

    [searchField typeText:resourceName];

    [self tapButtonWithText:@"Search"
              parentElement:nil
                shouldCheck:YES];
}

- (void)performSearchResourceWithName:(NSString *)resourceName
                    inSectionWithName:(NSString *)sectionName
{
    [self openSectionWithName:sectionName];
    [self performSearchResourceWithName:resourceName
           inSectionWithAccessibilityId:[self sectionAccessibilityIdFromSectionName:sectionName]];
}

- (void)openSectionWithName:(NSString *)sectionName
{
    if ([sectionName isEqualToString:JMLocalizedString(@"menuitem_library_label")]) {
        [self openLibrarySectionIfNeed];
    } else if ([sectionName isEqualToString:JMLocalizedString(@"menuitem_repository_label")]) {
        [self openRepositorySectionIfNeed];
    } else if ([sectionName isEqualToString:JMLocalizedString(@"menuitem_favorites_label")]) {
        [self openFavoritesSectionIfNeed];
    } else if ([sectionName isEqualToString:JMLocalizedString(@"menuitem_saveditems_label")]) {
        [self openSavedItemsSectionIfNeed];
    } else {
        XCTFail(@"Wrong section for searching: %@", sectionName);
    }
}

- (NSString *)sectionAccessibilityIdFromSectionName:(NSString *)sectionName
{
    NSString *accessibilityId;
    if ([sectionName isEqualToString:JMLocalizedString(@"menuitem_library_label")]) {
        // TODO: replace with specific element - JMLibraryPageAccessibilityId
        accessibilityId = @"JMBaseCollectionContentViewAccessibilityId";
    } else if ([sectionName isEqualToString:JMLocalizedString(@"menuitem_repository_label")]) {
        // TODO: replace with specific element - JMRepositoryPageAccessibilityId
        accessibilityId = @"JMBaseCollectionContentViewAccessibilityId";
    } else if ([sectionName isEqualToString:JMLocalizedString(@"menuitem_favorites_label")]) {
        // TODO: replace with specific element - JMRepositoryPageAccessibilityId
        accessibilityId = @"JMBaseCollectionContentViewAccessibilityId";
    } else if ([sectionName isEqualToString:JMLocalizedString(@"menuitem_saveditems_label")]) {
        // TODO: replace with specific element - JMRepositoryPageAccessibilityId
        accessibilityId = @"JMBaseCollectionContentViewAccessibilityId";
    } else {
        XCTFail(@"Wrong section for searching: %@", sectionName);
    }
    return accessibilityId;
}

- (void)clearSearchResultInSectionWithAccessibilityId:(NSString *)sectionAccessibilityId
{
    XCUIElement *searchResourcesSearchField = [self searchFieldFromSectionWithAccessibilityId:sectionAccessibilityId];
    [searchResourcesSearchField tapByWaitingHittable];

    [self tapButtonWithText:@"Clear text"
              parentElement:searchResourcesSearchField
                shouldCheck:NO];

    [self tapButtonWithText:JMLocalizedString(@"dialog_button_cancel")
              parentElement:nil
                shouldCheck:YES];
}

- (void)clearSearchResultInSectionWithName:(NSString *)sectionName
{
    [self clearSearchResultInSectionWithAccessibilityId:[self sectionAccessibilityIdFromSectionName:sectionName]];
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

- (XCUIElement *)searchFieldFromSectionWithName:(NSString *)sectionName
{
    XCUIElement *section = [self waitElementMatchingType:XCUIElementTypeOther
                                                    text:sectionName
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