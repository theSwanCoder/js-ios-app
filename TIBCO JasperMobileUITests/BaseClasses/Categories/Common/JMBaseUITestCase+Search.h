//
// Created by Aleksandr Dakhno on 12/11/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JMBaseUITestCase.h"

@interface JMBaseUITestCase (Search)
- (void)performSearchResourceWithName:(NSString *)resourceName
         inSectionWithAccessibilityId:(NSString *)sectionId;
- (void)performSearchResourceWithName:(NSString *)resourceName
                    inSectionWithName:(NSString *)sectionName;
- (void)clearSearchResultInSectionWithAccessibilityId:(NSString *)sectionId;
@end