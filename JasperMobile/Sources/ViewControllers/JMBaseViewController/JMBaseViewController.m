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
#import "UIImage+Additions.h"

static const NSInteger kSplashViewTag = 100;

@implementation JMBaseViewController

#pragma mark - UIViewController LifeCycle
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // Google Analitycs
    self.screenName = NSStringFromClass(self.class);

    [self addObserversForApplicationStates];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self removeAllObservers];
}

#pragma mark - Observers
- (void)addObserversForApplicationStates
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleApplicationEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleApplicationWillEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)removeAllObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
}

#pragma mark - Application LifeCycle
- (void)handleApplicationEnterBackground
{
    [self addBlurView];
}

- (void)handleApplicationWillEnterForeground
{
    [self removeBlurView];
}

#pragma mark - Helpers
- (void)addBlurView
{
    NSString *splashImageName = [UIImage splashImageNameForOrientation:self.interfaceOrientation];
    UIImage *splashImage = [UIImage imageNamed:splashImageName];
    UIImageView *splashView = [[UIImageView alloc] initWithImage:splashImage];
    splashView.tag = kSplashViewTag;
    [self.view.window addSubview:splashView];
}

- (void)removeBlurView
{
    for (UIView *subView in self.view.window.subviews) {
        if (subView.tag == kSplashViewTag) {
            [subView removeFromSuperview];
        }
    }
}

@end