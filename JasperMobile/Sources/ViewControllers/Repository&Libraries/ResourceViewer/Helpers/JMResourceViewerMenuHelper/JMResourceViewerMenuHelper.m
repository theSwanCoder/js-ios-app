/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMResourceViewerMenuHelper.h"
#import "PopoverView.h"
#import "JMMenuActionsView.h"

@interface JMResourceViewerMenuHelper() <PopoverViewDelegate>
@property (nonatomic, weak) PopoverView *popoverView;
@end

@implementation JMResourceViewerMenuHelper

#pragma mark - Custom Accessors

- (BOOL)isMenuVisible
{
    return self.popoverView != nil;
}

#pragma mark - Public API

- (void)showMenuWithAvailableActions:(JMMenuActionsViewAction)availableActions disabledActions:(JMMenuActionsViewAction)disabledActions
{
    JMMenuActionsView *actionsView = [JMMenuActionsView new];
    actionsView.delegate = self.controller;
    [actionsView setAvailableActions:availableActions
                     disabledActions:disabledActions];
    CGPoint point = CGPointMake(CGRectGetWidth(self.controller.view.frame), -10);

    self.popoverView = [PopoverView showPopoverAtPoint:point
                                                inView:self.controller.view
                                             withTitle:nil
                                       withContentView:actionsView
                                              delegate:self];
    actionsView.popoverView = self.popoverView;
}

- (void)hideMenu
{
    [self.popoverView dismiss:NO];
}

#pragma mark - PopoverViewDelegate

- (void)popoverViewDidDismiss:(PopoverView *)popoverView
{
    self.popoverView = nil;
}

@end
