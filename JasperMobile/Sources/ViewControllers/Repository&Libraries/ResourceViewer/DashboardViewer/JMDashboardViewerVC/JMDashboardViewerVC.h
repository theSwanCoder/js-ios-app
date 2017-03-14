/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
@author Oleksandr Dahno odahno@tibco.com
@since 2.1
*/

#import "JMResourceViewerProtocol.h"
#import "JMMenuActionsView.h"
#import "JMResourceClientHolder.h"
#import "JMExternalWindowDashboardControlsVC.h"

@class JMDashboard;
@class JMDashboardViewerConfigurator;

@interface JMDashboardViewerVC : JMBaseViewController <JMResourceClientHolder, JMResourceViewerProtocol, JMMenuActionsViewDelegate, JMMenuActionsViewProtocol, JMExternalWindowDashboardControlsVCDelegate>
@property (nonatomic, strong) JMDashboardViewerConfigurator *configurator;
- (JMDashboard *)dashboard;

- (void)showOnTV;
- (void)switchFromTV;
@end
