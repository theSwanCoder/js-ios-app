/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksii Gubariev ogubarie@tibco.com
 @since 2.6
 */


#import "JMResourceViewerExternalScreenManager.h"
@class JMContentResourceViewerVC;

@interface JMContentResourceViewerExternalScreenManager : JMResourceViewerExternalScreenManager
@property (nonatomic, weak, nullable) JMContentResourceViewerVC *controller;

@end
