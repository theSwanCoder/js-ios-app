//
// Created by Aleksandr Dakhno on 9/16/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JMBaseUITestCase.h"

@interface JMBaseUITestCase (SavedItems)

- (void)removeAllExportedResourcesIfNeed;
- (void)removeExportedResourceWithAccessibilityId:(NSString *)accessibilityId;
- (void)verifyExistExportedResourceWithName:(NSString *)resourceName format:(NSString *)format;

@end