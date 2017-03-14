/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
@author Oleksandr Dahno odahno@tibco.com
@since 2.1
*/

#import "JMDashboardLoader.h"

@interface JMVisDashboardLoader : NSObject <JMDashboardLoader>
@property (nonatomic, strong, readonly) JMDashboard *dashboard;
@end
