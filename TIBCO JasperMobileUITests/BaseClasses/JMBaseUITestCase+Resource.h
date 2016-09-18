//
// Created by Aleksandr Dakhno on 9/16/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JMBaseUITestCase.h"

@interface JMBaseUITestCase (Resource)

- (void)openInfoPageForResource:(XCUIElement *)resource;
- (void)closeInfoPage;
- (void)verifyInfoPageOnScreenForPageWithAccessibilityId:(NSString *)accessibilityId;

@end
