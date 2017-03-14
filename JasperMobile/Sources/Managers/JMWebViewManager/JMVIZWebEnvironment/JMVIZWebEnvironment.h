/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.6
 */

#import "JMWebEnvironment.h"
@class JMVisualizeManager;

@interface JMVIZWebEnvironment : JMWebEnvironment
@property (nonatomic, strong) JMVisualizeManager *visualizeManager;
@end
