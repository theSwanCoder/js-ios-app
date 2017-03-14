/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.0
 */

#import "JMOnboardIntroViewController.h"

@class JMIntroModel;

@interface JMIntroModelManager : NSObject
- (JMIntroModel *)modelForIntroPage:(JMOnboardIntroPage)introPage;
@end
