/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMResourceViewerToolbarsHelper.h"
#import "JMBaseResourceView.h"

@interface JMResourceViewerToolbarsHelper()
@property (nonatomic, assign, readwrite) JMResourceViewerToolbarState state;
@end

@implementation JMResourceViewerToolbarsHelper

#pragma mark - Public API

- (void)updatePageForToolbarState:(JMResourceViewerToolbarState)toolbarState
{
    switch(toolbarState) {
        case JMResourceViewerToolbarStateInitial: {
            [self hideTopToolbarAnimated:NO];
            [self hideBottomToolbarAnimated:NO];
            break;
        }
        case JMResourceViewerToolbarStateTopVisible: {
            [self showTopToolbarAnimated:YES];
            break;
        }
        case JMResourceViewerToolbarStateTopHidden: {
            [self hideTopToolbarAnimated:YES];
            break;
        }
        case JMResourceViewerToolbarStateBottomVisible: {
            [self showBottomToolbarAnimated:YES];
            break;
        }
        case JMResourceViewerToolbarStateBottomHidden: {
            [self hideBottomToolbarAnimated:YES];
            break;
        }
    }
}

#pragma mark - Setup Toolbars

- (void)showTopToolbarAnimated:(BOOL)animated
{
    [self setTopToolbarVisible:YES animated:animated];
}

- (void)hideTopToolbarAnimated:(BOOL)animated
{
    [self setTopToolbarVisible:NO animated:animated];
}

- (void)showBottomToolbarAnimated:(BOOL)animated
{
    [self setBottomToolbarVisible:YES animated:animated];
}

- (void)hideBottomToolbarAnimated:(BOOL)animated
{
    [self setBottomToolbarVisible:NO animated:animated];
}

#pragma mark - Toolbar Helpers
- (void)setTopToolbarVisible:(BOOL)visible animated:(BOOL)animated
{
    self.view.topViewTopConstraint.constant = visible ? 0 : - CGRectGetHeight(self.view.topView.frame);
    if (animated) {
        [UIView animateWithDuration:0.25
                         animations:^{
                             [self.view layoutIfNeeded];
                         }];
    }
}

- (void)setBottomToolbarVisible:(BOOL)visible animated:(BOOL)animated
{
    self.view.bottomViewBottomConstraint.constant = visible ? 0 : -CGRectGetHeight(self.view.bottomView.frame);
    if (animated) {
        [UIView animateWithDuration:0.25
                         animations:^{
                             [self.view layoutIfNeeded];
                         }];
    }
}

@end
