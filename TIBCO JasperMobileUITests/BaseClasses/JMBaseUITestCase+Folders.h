//
// Created by Aleksandr Dakhno on 10/10/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

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