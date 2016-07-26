/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2015 TIBCO Software, Inc. All rights reserved.
 * http://community.jaspersoft.com/project/jaspermobile-ios
 *
 * Unless you have purchased a commercial license agreement from Jaspersoft,
 * the following license terms apply:
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/lgpl>.
 */


//
//  JMBaseViewController.m
//  TIBCO JasperMobile
//

#import "JMBaseViewController.h"
#import "JMAnalyticsManager.h"

@interface JMBaseViewController()
@property (nonatomic, strong) UIWindow *externalWindow;
@end

@implementation JMBaseViewController

- (void)dealloc
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
}

#pragma mark - UIViewController LifeCycle
- (void)viewDidAppear:(BOOL)animated
{
    self.screenName = [self screenNameForAnalytics];

    [super viewDidAppear:animated];

    [self setupScreenConnectionNotifications];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    [self discardScreenConnectionNotifications];
}

#pragma mark - Work with external screens
- (BOOL)isExternalScreenAvailable
{
    return [UIScreen screens].count > 1;
}

- (BOOL)createExternalWindow
{
    NSArray *screens = [UIScreen screens];

    if (screens.count > 1) {
        [self setupExternalWindow];

        return YES;
    } else {
        return NO;
    }
}

- (void)showExternalWindowWithCompletion:(void(^)(BOOL success))completion
{
    if (!completion) {
        return;
    }

    if ([self isExternalScreenAvailable] && [self createExternalWindow] ) {
        self.externalWindow.hidden = NO;

        // TODO: need other approach for detecting end of
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            completion(YES);
        });
    } else {
        completion(NO);
    }
}

- (void)hideExternalWindowWithCompletion:(void(^)(void))completion
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.externalWindow.hidden = YES;
        self.externalWindow = nil;
        if (completion) {
            completion();
        }
    });
}

- (UIView *)viewToShowOnExternalWindow
{
    // override
    return nil;
}

- (BOOL)isContentOnTV
{
    BOOL isContentOnTV = _externalWindow && !_externalWindow.hidden;
    JMLog(@"is content on tv: %@", isContentOnTV ? @"YES" : @"NO");
    return isContentOnTV;
}

#pragma mark - Custom accessors

- (UIWindow *)externalWindow
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    if (!_externalWindow) {
        JMLog(@"creating new window");
        _externalWindow = [UIWindow new];
        _externalWindow.clipsToBounds = YES;
        _externalWindow.backgroundColor = [UIColor whiteColor];
    }
    return _externalWindow;
}

- (void)setupExternalWindow
{
    UIScreen *externalScreen = [UIScreen screens][1];
    UIScreenMode *desiredMode = externalScreen.availableModes.firstObject;

    // Setup external window
    self.externalWindow.screen = externalScreen;

    CGRect rect = CGRectZero;
    rect.size = desiredMode.size;
    self.externalWindow.frame = rect;

    UIView *viewForAdding = [self viewToShowOnExternalWindow];
    viewForAdding.frame = rect;
    [self.externalWindow addSubview:viewForAdding];

    self.externalWindow.hidden = YES;
}
- (void)switchFromTV
{
    // override in childs
}

#pragma mark - Notifications
- (void)setupScreenConnectionNotifications
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

    [center addObserver:self
               selector:@selector(handleScreenDidConnectNotification:)
                   name:UIScreenDidConnectNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(handleScreenDidDisconnectNotification:)
                   name:UIScreenDidDisconnectNotification
                 object:nil];
}

- (void)discardScreenConnectionNotifications
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self
                      name:UIScreenDidConnectNotification
                    object:nil];
    [center removeObserver:self
                      name:UIScreenDidDisconnectNotification
                    object:nil];
}

- (void)handleScreenDidConnectNotification:(NSNotification *)notification
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    JMLog(@"notification: %@", notification);
    // TODO: update working with TV with this
}

- (void)handleScreenDidDisconnectNotification:(NSNotification *)notification
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    // TODO: update working with TV with this
    JMLog(@"notification: %@", notification);
    [self switchFromTV];
}

#pragma mark - Work with navigation items
- (UIBarButtonItem *)backButtonWithTitle:(NSString *)title
                                  target:(id)target
                                  action:(SEL)action
{
    NSString *backItemTitle = title;
    if (!backItemTitle) {
        NSArray *viewControllers = self.navigationController.viewControllers;
        NSUInteger index = [viewControllers indexOfObject:self];
        if ((index != NSNotFound) && (viewControllers.count - 1) >= index) {
            UIViewController *previousViewController = viewControllers[index - 1];
            backItemTitle = previousViewController.title;
        } else {
            backItemTitle = JMCustomLocalizedString(@"back_button_title", nil);
        }
    }

    UIImage *backButtonImage = [UIImage imageNamed:@"back_item"];
    UIImage *resizebleBackButtonImage = [backButtonImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, backButtonImage.size.width, 0, backButtonImage.size.width) resizingMode:UIImageResizingModeStretch];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:[self croppedBackButtonTitle:backItemTitle]
                                                                 style:UIBarButtonItemStylePlain
                                                                target:target
                                                                action:action];
    [backItem setBackgroundImage:resizebleBackButtonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    return backItem;
}

- (NSString *)croppedBackButtonTitle:(NSString *)backButtonTitle
{
    // detect backButton text width to truncate with '...'
    NSDictionary *textAttributes = @{NSFontAttributeName : [[JMThemesManager sharedManager] navigationBarTitleFont]};
    CGSize titleTextSize = [self.title sizeWithAttributes:textAttributes];
    CGFloat titleTextWidth = ceilf(titleTextSize.width);
    CGSize backItemTextSize = [backButtonTitle sizeWithAttributes:textAttributes];
    CGFloat backItemTextWidth = ceilf(backItemTextSize.width);
    CGFloat backItemOffset = 12;

    CGFloat viewWidth = CGRectGetWidth(self.navigationController.navigationBar.frame);

    if (( (backItemOffset + backItemTextWidth) > (viewWidth - titleTextWidth) / 2 ) && ![backButtonTitle isEqualToString:JMCustomLocalizedString(@"back_button_title", nil)]) {
        return [self croppedBackButtonTitle:JMCustomLocalizedString(@"back_button_title", nil)];
    }
    return backButtonTitle;
}

#pragma mark - Analytics
- (NSString *)screenNameForAnalytics
{
    NSString *screenName = [[JMAnalyticsManager sharedManager] mapClassNameToReadableName:NSStringFromClass(self.class)];
    return [screenName stringByAppendingString:[self additionalsToScreenName]];
}

- (NSString *)additionalsToScreenName
{
    return @"";
}

@end