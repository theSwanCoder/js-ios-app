/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.6
 */

#import <Foundation/Foundation.h>
#import "JMBaseUITestCase.h"

extern NSString *const kTestFolderName;

@interface JMBaseUITestCase (Folders)

- (void)openFolderWithName:(NSString *)folderName;
- (void)backToFolderWithName:(NSString *)folderName;

- (XCUIElement *)searchTestFolderInSectionWithName:(NSString *)sectionName;

// Verifying
- (void)verifyCorrectTitleForFolderWithName:(NSString *)folderName;
- (void)verifyThatFolderInfoPageOnScreen;
- (void)verifyThatFolderInfoPageContainsCorrectDataForFolderWithName:(NSString *)folderName;

@end
