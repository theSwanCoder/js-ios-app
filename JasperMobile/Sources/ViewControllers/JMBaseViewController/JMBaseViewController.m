//
// Created by Aleksandr Dakhno on 8/18/15.
// Copyright (c) 2015 TIBCO JasperMobile. All rights reserved.
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    if (![JMUtils isSystemVersion8]) {
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