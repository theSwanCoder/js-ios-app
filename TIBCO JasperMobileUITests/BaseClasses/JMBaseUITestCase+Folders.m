//
// Created by Aleksandr Dakhno on 10/10/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMBaseUITestCase+Folders.h"
#import "JMBaseUITestCase+Helpers.h"
#import "JMBaseUITestCase+Section.h"
#import "JMBaseUITestCase+InfoPage.h"

NSString *const kTestFolderName = @"Public";

@implementation JMBaseUITestCase (Folders)

- (void)openFolderWithName:(NSString *)folderName
{
    XCUIElement *cell = [self folderCellWithName:folderName];
    [cell tap];
}

- (void)backToFolderWithName:(NSString *)folderName
{
    [self tryBackToPreviousPageWithTitle:folderName];
}

- (XCUIElement *)searchTestFolderInSectionWithName:(NSString *)sectionName
{
    [self searchResourceWithName:@"Samples"
               inSectionWithName:sectionName];

    [self givenThatCellsAreVisible];

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
    [self waitStaticTextWithAccessibilityId:@"Name"
                              parentElement:infoPage
                                    timeout:kUITestsBaseTimeout];
    [self waitStaticTextWithAccessibilityId:@"Description"
                              parentElement:infoPage
                                    timeout:kUITestsBaseTimeout];
    [self waitStaticTextWithAccessibilityId:@"URI"
                              parentElement:infoPage
                                    timeout:kUITestsBaseTimeout];
    [self waitStaticTextWithAccessibilityId:@"Type"
                              parentElement:infoPage
                                    timeout:kUITestsBaseTimeout];
    [self waitStaticTextWithAccessibilityId:@"Version"
                              parentElement:infoPage
                                    timeout:kUITestsBaseTimeout];
    [self waitStaticTextWithAccessibilityId:@"Creation Date"
                              parentElement:infoPage
                                    timeout:kUITestsBaseTimeout];
    [self waitStaticTextWithAccessibilityId:@"Modified Date"
                              parentElement:infoPage
                                    timeout:kUITestsBaseTimeout];
}

#pragma mark - Helpers

- (XCUIElement *)folderCellWithName:(NSString *)folderName
{
    XCUIElement *testCell = [self findCollectionViewCellWithAccessibilityId:@"JMCollectionViewListCellAccessibilityId"
                                           containsLabelWithAccessibilityId:@"JMResourceCellResourceNameLabelAccessibilityId"
                                                                  labelText:folderName];
    if (!testCell) {
        XCTFail(@"There isn't test cell");
    }
    return testCell;
}

@end
