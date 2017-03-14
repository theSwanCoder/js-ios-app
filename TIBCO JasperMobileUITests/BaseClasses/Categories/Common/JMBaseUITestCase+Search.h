/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.6
 */

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
