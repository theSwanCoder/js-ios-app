//
// Created by Aleksandr Dakhno on 10/10/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMBaseUITestCase+Folders.h"
#import "JMBaseUITestCase+Helpers.h"
#import "JMBaseUITestCase+Section.h"
#import "JMBaseUITestCase+InfoPage.h"
#import "JMBaseUITestCase+Search.h"
#import "XCUIElement+Tappable.h"

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
                             text:@"Name"
                    parentElement:infoPage
                          timeout:kUITestsBaseTimeout];
    [self waitElementMatchingType:XCUIElementTypeStaticText
                             text:@"Description"
                    parentElement:infoPage
                          timeout:kUITestsBaseTimeout];
    [self waitElementMatchingType:XCUIElementTypeStaticText
                             text:@"URI"
                    parentElement:infoPage
                          timeout:kUITestsBaseTimeout];
    [self waitElementMatchingType:XCUIElementTypeStaticText
                             text:@"Type"
                    parentElement:infoPage
                          timeout:kUITestsBaseTimeout];
    [self waitElementMatchingType:XCUIElementTypeStaticText
                             text:@"Version"
                    parentElement:infoPage
                          timeout:kUITestsBaseTimeout];
    [self waitElementMatchingType:XCUIElementTypeStaticText
                             text:@"Creation Date"
                    parentElement:infoPage
                          timeout:kUITestsBaseTimeout];
    [self waitElementMatchingType:XCUIElementTypeStaticText
                             text:@"Modified Date"
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
