/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
@author Oleksandr Dahno odahno@tibco.com
@since 2.6
*/

#import "JMResourceViewerToolbarsHelper.h"
#import "JMResourceViewerStateManager.h"
#import "JMResourceViewerHyperlinksManager.h"

@class JMDashboardViewerVC;

@interface JMDashboardViewerStateManager : JMResourceViewerStateManager <JMResourceViewerHyperlinksManagerDelegate>
@property (nonatomic, copy, nullable) void(^minimizeDashletActionBlock)(void);
@end
