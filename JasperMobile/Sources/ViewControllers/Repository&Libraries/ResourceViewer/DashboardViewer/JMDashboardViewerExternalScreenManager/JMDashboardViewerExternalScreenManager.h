/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
@author Oleksandr Dahno odahno@tibco.com
@since 2.6
*/

#import "JMResourceViewerExternalScreenManager.h"
@class JMDashboardViewerVC;

@interface JMDashboardViewerExternalScreenManager : JMResourceViewerExternalScreenManager
@property (nonatomic, weak, nullable) JMDashboardViewerVC *controller;
@end
