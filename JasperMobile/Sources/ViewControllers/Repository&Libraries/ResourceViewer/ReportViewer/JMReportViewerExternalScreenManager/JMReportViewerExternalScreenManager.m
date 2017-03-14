/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMReportViewerExternalScreenManager.h"
#import "JMUtils.h"
#import "JMExternalWindowControlsVC.h"
#import "JMBaseResourceView.h"
#import "JMVisualizeReportLoader.h"
#import "JMReportViewerConfigurator.h"

@interface JMReportViewerExternalScreenManager()
@property (nonatomic, strong) JMExternalWindowControlsVC *controlsVC;
@end

@implementation JMReportViewerExternalScreenManager

#pragma mark - Public API

- (void)showContentOnTV
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));

    [super showContentOnTV];
    [self showControlsViewOnDevice];
}

- (void)backContentOnDevice
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));

    [super backContentOnDevice];
    [self removeControlsViewFromDevice];
}

#pragma mark - Overridden

- (JMBaseResourceView *)resourceView
{
    return (JMBaseResourceView *) self.controller.view;
}

- (void)handleExternalScreenWillBeDestroy
{
    [self.controller switchFromTV];
}

- (void)handleContentIsOnExternalScreen
{
    JMVisualizeReportLoader *reportLoader = self.controller.configurator.reportLoader;
    [reportLoader fitReportViewToScreen];
}

- (void)handleContentIsOnDevice
{
#warning CORRECT!!!!
    JMVisualizeReportLoader *reportLoader = self.controller.configurator.reportLoader;
    [reportLoader fitReportViewToScreen];
}

#pragma mark - Helpers

- (void)showControlsViewOnDevice
{
    self.controlsVC = [[JMExternalWindowControlsVC alloc] initWithContentView:[self.controller contentView]];

    CGRect controlViewFrame = self.controller.view.frame;
    controlViewFrame.origin.y = 0;
    self.controlsVC.view.frame = controlViewFrame;

    [self.controller.view addSubview:self.controlsVC.view];
}

- (void)removeControlsViewFromDevice
{
    [self.controlsVC.view removeFromSuperview];
    self.controlsVC = nil;
}

@end
