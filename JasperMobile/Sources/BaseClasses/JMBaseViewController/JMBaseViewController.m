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

@interface JMBaseViewController()
@property (nonatomic, strong) UIWindow *externalWindow;
@end

@implementation JMBaseViewController

- (void)dealloc
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
}

#pragma mark - UIViewController LifeCycle
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // Google Analitycs
    self.screenName = NSStringFromClass(self.class);
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

- (void)showExternalWindow
{
    if ([self isExternalScreenAvailable] && [self createExternalWindow] ) {
        self.externalWindow.hidden = NO;
    } else {
        // TODO: add handling this situation
    }
}

- (void)hideExternalWindow
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.externalWindow.hidden = YES;
    });
}

- (UIView *)viewForAddingToExternalWindow
{
    // override
    return nil;
}

- (UIView *)viewForRemovingFromExternalWindow
{
    return self.externalWindow.subviews.firstObject;
}

- (BOOL)isContentOnTV
{
    BOOL isContentOnTV = self.externalWindow && !self.externalWindow.hidden;
    JMLog(@"is content on tv: %@", isContentOnTV ? @"YES" : @"NO");
    return isContentOnTV;
}

#pragma mark - Custom accessors

- (UIWindow *)externalWindow
{
    if (!_externalWindow) {
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

    UIView *viewForAdding = [self viewForAddingToExternalWindow];
    viewForAdding.frame = rect;
    [self.externalWindow addSubview:viewForAdding];

    self.externalWindow.hidden = YES;
}

@end