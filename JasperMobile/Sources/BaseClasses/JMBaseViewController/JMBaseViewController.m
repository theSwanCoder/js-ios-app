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
        self.externalWindow = [UIWindow new];

        UIScreen *externalScreen = [UIScreen screens][1];
        UIScreenMode *desiredMode = externalScreen.availableModes.firstObject;
        externalScreen.currentMode = desiredMode;

        // Setup external window
        self.externalWindow.screen = externalScreen;
        self.externalWindow.backgroundColor = [UIColor whiteColor];

        CGRect rect = CGRectZero;
        rect.size = desiredMode.size;
        self.externalWindow.frame = rect;
        self.externalWindow.clipsToBounds = YES;

        UIView *viewForAdding = [self viewForAddingToExternalWindow];
        viewForAdding.frame = rect;
        [self.externalWindow addSubview:viewForAdding];

        self.externalWindow.hidden = YES;

        return YES;
    } else {
        return NO;
    }
}

- (void)showExternalWindow
{
    self.externalWindow.hidden = NO;
}

- (void)hideExternalWindow
{
    self.externalWindow.hidden = YES;
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

@end