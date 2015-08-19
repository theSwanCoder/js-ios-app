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

static const NSInteger kBlurViewTag = 100;

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
    if ([JMUtils isSystemVersion8]) {
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc]initWithEffect:blur];
        effectView.frame = self.view.window.bounds;
        effectView.tag = kBlurViewTag;
        [self.view addSubview:effectView];
    } else {
        UIToolbar* blur = [[UIToolbar alloc] initWithFrame:self.view.window.bounds];
        blur.barStyle = UIBarStyleBlack;
        blur.tag = kBlurViewTag;
        [self.view addSubview:blur];
    }
}

- (void)removeBlurView
{
    for (UIView *subView in self.view.subviews) {
        if (subView.tag == kBlurViewTag) {
            [subView removeFromSuperview];
        }
    }
}

@end