//
// Created by Aleksandr Dakhno on 9/16/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMBaseUITestCase+SavedItems.h"
#import "JMBaseUITestCase+SideMenu.h"
#import "JMBaseUITestCase+Helpers.h"
#import "JMBaseUITestCase+Resource.h"
#import "JMBaseUITestCase+ActionsMenu.h"


@implementation JMBaseUITestCase (SavedItems)

- (void)removeAllExportedResourcesIfNeed
{
    NSInteger countOfSavedItems = [self countCellsWithAccessibilityId:@"JMCollectionViewListCellAccessibilityId"];
    if (countOfSavedItems > 0) {
        [self removeFirstExportedResource];
    }
}

- (void)removeExportedResourceWithAccessibilityId:(NSString *)accessibilityId
{

}

- (void)verifyExistExportedResourceWithName:(NSString *)resourceName format:(NSString *)format
{
    NSString *fullSavedItemName = [NSString stringWithFormat:@"%@.%@", resourceName, format.lowercaseString];
    XCUIElement *savedItem = [self findCollectionViewCellWithAccessibilityId:@"JMCollectionViewListCellAccessibilityId"
                                            containsLabelWithAccessibilityId:@"JMResourceCellResourceNameLabelAccessibilityId"
                                                                   labelText:fullSavedItemName];
    if (!savedItem) {
        XCTFail(@"Resource with name '%@' should exist", resourceName);
    }
}

#pragma mark - Helpers

- (void)removeFirstExportedResource
{
    XCUIElement *firstItem = [self cellWithAccessibilityId:@"JMCollectionViewListCellAccessibilityId"
                                                  forIndex:0];
    [self openInfoPageForResource:firstItem];
    [self verifyInfoPageOnScreenForPageWithAccessibilityId:@"JMSavedItemsInfoViewControllerAccessibilityId"];

    [self openMenuActions];
    [self selectActionWithName:@"Delete"];
    [self confirmDeleteAction];

    [self removeAllExportedResourcesIfNeed];
}

- (void)confirmDeleteAction
{
    XCUIElement *okButton = [self waitButtonWithAccessibilityId:@"OK"
                                                        timeout:kUITestsBaseTimeout];
    [okButton tap];
}

@end
