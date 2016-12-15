//
// Created by Aleksandr Dakhno on 12/15/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JMBaseUITestCase.h"

@interface JMBaseUITestCase (Cells)
- (NSInteger)countCellsWithAccessibilityId:(NSString *)accessibilityId;
- (XCUIElement *)cellWithAccessibilityId:(NSString *)accessibilityId forIndex:(NSUInteger)index;
- (XCUIElement *)findCollectionViewCellWithAccessibilityId:(NSString *)accessibilityId
                          containsLabelWithAccessibilityId:(NSString *)labelAccessibilityId
                                                 labelText:(NSString *)labelText;
- (XCUIElement *)waitCollectionViewCellWithAccessibilityId:(NSString *)accessibilityId
                          containsLabelWithAccessibilityId:(NSString *)labelAccessibilityId
                                                 labelText:(NSString *)labelText
                                                   timeout:(NSTimeInterval)timeout;
- (XCUIElement *)findTableViewCellWithAccessibilityId:(NSString *)accessibilityId
                                containsLabelWithText:(NSString *)labelText;
@end