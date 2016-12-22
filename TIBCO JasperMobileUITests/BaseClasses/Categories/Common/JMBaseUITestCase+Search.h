//
// Created by Aleksandr Dakhno on 12/11/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JMBaseUITestCase.h"

@interface JMBaseUITestCase (Search)
// TODO: uncomment after implementing accessibility id for all sections
//- (void)performSearchResourceWithName:(NSString *)resourceName
//         inSectionWithAccessibilityId:(NSString *)sectionId;
- (void)performSearchResourceWithName:(NSString *)resourceName
                    inSectionWithName:(NSString *)sectionName;
// TODO: uncomment after implementing accessibility id for all sections
//- (void)clearSearchResultInSectionWithAccessibilityId:(NSString *)sectionId;
- (void)clearSearchResultInSectionWithName:(NSString *)sectionName;
@end