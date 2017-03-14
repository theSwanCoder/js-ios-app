/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.6
 */

#import "JMBaseUITestCase+Folders.h"
#import "JMBaseUITestCase+Helpers.h"
#import "JMBaseUITestCase+Section.h"
#import "JMBaseUITestCase+InfoPage.h"
#import "JMBaseUITestCase+Search.h"
#import "XCUIElement+Tappable.h"
#import "JMBaseUITestCase+Cells.h"

NSString *const kTestFolderName = @"Public";

@implementation JMBaseUITestCase (Folders)

- (void)openFolderWithName:(NSString *)folderName
{
    XCUIElement *cell = [self folderCellWithName:folderName];
    [cell tapByWaitingHittable];
}

- (void)backToFolderWithName:(NSString *)folderName
{
    [self tryBackToPreviousPageWithTitle:folderName];
}

- (XCUIElement *)searchTestFolderInSectionWithName:(NSString *)sectionName
{
    [self performSearchResourceWithName:@"Samples"
                      inSectionWithName:sectionName];

    [self waitCollectionViewContainsCellsWithTimeout:kUITestsBaseTimeout];

    XCUIElement *testCell = [self folderCellWithName:@"Samples"];
    return testCell;
}


- (void)verifyCorrectTitleForFolderWithName:(NSString *)folderName
{
    XCUIElement *navBar = [self findNavigationBarWithLabel:folderName];
    if (!navBar.exists) {
        XCTFail(@"Wrong title, expected: %@", folderName);
    }
}

- (void)verifyThatFolderInfoPageOnScreen
{
    [self verifyInfoPageOnScreenForPageWithAccessibilityId:@"JMRepositoryResourceInfoViewControllerAccessibilityId"];
}

- (void)verifyThatFolderInfoPageContainsCorrectDataForFolderWithName:(NSString *)folderName
{
    XCUIElement *infoPage = self.application.otherElements[@"JMRepositoryResourceInfoViewControllerAccessibilityId"];
    [self waitElementMatchingType:XCUIElementTypeStaticText
                             text:JMLocalizedString(@"resource_label_title")
                    parentElement:infoPage
                          timeout:kUITestsBaseTimeout];
    [self waitElementMatchingType:XCUIElementTypeStaticText
                             text:JMLocalizedString(@"resource_description_title")
                    parentElement:infoPage
                          timeout:kUITestsBaseTimeout];
    [self waitElementMatchingType:XCUIElementTypeStaticText
                             text:JMLocalizedString(@"resource_uri_title")
                    parentElement:infoPage
                          timeout:kUITestsBaseTimeout];
    [self waitElementMatchingType:XCUIElementTypeStaticText
                             text:JMLocalizedString(@"resource_type_title")
                    parentElement:infoPage
                          timeout:kUITestsBaseTimeout];
    [self waitElementMatchingType:XCUIElementTypeStaticText
                             text:JMLocalizedString(@"resource_version_title")
                    parentElement:infoPage
                          timeout:kUITestsBaseTimeout];
    [self waitElementMatchingType:XCUIElementTypeStaticText
                             text:JMLocalizedString(@"resource_creationDate_title")
                    parentElement:infoPage
                          timeout:kUITestsBaseTimeout];
    [self waitElementMatchingType:XCUIElementTypeStaticText
                             text:JMLocalizedString(@"resource_modifiedDate_title")
                    parentElement:infoPage
                          timeout:kUITestsBaseTimeout];
}

#pragma mark - Helpers

- (XCUIElement *)folderCellWithName:(NSString *)folderName
{
    XCUIElement *testCell = [self waitCollectionViewCellWithAccessibilityId:@"JMCollectionViewListCellAccessibilityId"
                                           containsLabelWithAccessibilityId:@"JMResourceCellResourceNameLabelAccessibilityId"
                                                                  labelText:folderName
                                                                    timeout:kUITestsElementAvailableTimeout];
    return testCell;
}

@end
