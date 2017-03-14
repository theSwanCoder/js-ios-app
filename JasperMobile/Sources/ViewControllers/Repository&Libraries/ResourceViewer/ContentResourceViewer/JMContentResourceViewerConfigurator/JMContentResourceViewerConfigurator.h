/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksii Gubariev ogubarie@tibco.com
 @since 2.6
 */


#import "JMResourceViewerConfigurator.h"
@class JMContentResourceLoader;

@interface JMContentResourceViewerConfigurator : JMResourceViewerConfigurator
@property (nonatomic, strong, readonly, nonnull) JMContentResourceLoader * contentResourceLoader;

@end
