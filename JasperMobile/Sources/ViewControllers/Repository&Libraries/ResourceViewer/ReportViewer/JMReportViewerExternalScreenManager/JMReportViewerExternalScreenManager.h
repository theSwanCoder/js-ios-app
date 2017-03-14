/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.6
 */

#import "JMResourceViewerExternalScreenManager.h"
#import "JMReportViewerVC.h"

@interface JMReportViewerExternalScreenManager : JMResourceViewerExternalScreenManager
@property (nonatomic, weak, nullable) JMReportViewerVC *controller;
@end
