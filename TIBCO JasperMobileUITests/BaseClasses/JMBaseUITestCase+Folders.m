//
// Created by Aleksandr Dakhno on 10/10/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMBaseUITestCase+Folders.h"
#import "JMBaseUITestCase+Helpers.h"

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

- (void)verifyCorrectTitleForFolderWithName:(NSString *)folderName
{
    XCUIElement *navBar = [self findNavigationBarWithLabel:folderName];
    if (!navBar.exists) {
        XCTFail(@"Wrong title, expected: %@", folderName);
    }
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
