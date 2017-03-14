/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */

/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.1
 */


#import "JMResourceViewerProtocol.h"
#import "JMMenuActionsView.h"
#import "JMResourceClientHolder.h"
#import "JMReportLoaderProtocol.h"

@class JMReportViewerToolBar;
@class JMReportPartViewToolbar;
@class JMReportViewerConfigurator;

@interface JMReportViewerVC : JMBaseViewController <JMResourceClientHolder, JMResourceViewerProtocol, JMMenuActionsViewDelegate, JMMenuActionsViewProtocol>
@property (nonatomic, strong) JMReportViewerConfigurator *configurator;
@property (nonatomic, strong) NSArray <JSReportParameter *> *initialReportParameters;
@property (nonatomic, strong) JSReportDestination *initialDestination;
- (JSReport *)report;

- (void)showOnTV;
- (void)switchFromTV;
@end
