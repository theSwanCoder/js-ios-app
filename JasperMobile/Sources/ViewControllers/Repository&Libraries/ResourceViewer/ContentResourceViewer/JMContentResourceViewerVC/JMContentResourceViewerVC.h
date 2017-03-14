/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksii Gubariev ogubarie@tibco.com
 @since 2.6
 */

#import "JMResourceViewerProtocol.h"
#import "JMMenuActionsView.h"
#import "JMResourceClientHolder.h"
#import "JMExternalWindowDashboardControlsVC.h"

@class JMSavedResources;
@class JMContentResourceViewerConfigurator;
@class JMContentResourceViewerVC;
@protocol JMContentResourceViewerVCDelegate <NSObject>
@optional
- (void)resourceViewer:(JMContentResourceViewerVC *)resourceViewer didDeleteResource:(JMResource *)resource;

@end


@interface JMContentResourceViewerVC : JMBaseViewController <JMResourceClientHolder, JMResourceViewerProtocol, JMMenuActionsViewDelegate, JMMenuActionsViewProtocol, JMExternalWindowDashboardControlsVCDelegate>
@property (nonatomic, strong) JMContentResourceViewerConfigurator *configurator;
@property (nonatomic, weak) id <JMContentResourceViewerVCDelegate>delegate;

- (void)showOnTV;
- (void)switchFromTV;

@end
