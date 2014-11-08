/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2014 TIBCO Software, Inc. All rights reserved.
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
//  JMIntroViewController.m
//  TIBCO JasperMobile
//

#import <UIKit/UIKit.h>
#import "JMIntroViewController.h"
#import "JMIntroChildViewController.h"

@interface JMIntroViewController () <UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *skipButton;
@property (weak, nonatomic) IBOutlet UIView *childView;
@property (weak, nonatomic) IBOutlet UIView *controlView;
@property (weak, nonatomic) JMIntroChildViewController *topChildViewController;
@property (weak, nonatomic) JMIntroChildViewController *bottomChildViewController;
@property (nonatomic, copy) NSArray *pageTitles;
@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) NSUInteger topChildViewIndex;
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@end

@implementation JMIntroViewController

#pragma mark - LifeCircle

- (void)viewDidLoad {
    [super viewDidLoad];

    [UIApplication sharedApplication].statusBarHidden = YES;

    self.pageTitles = @[
            @"first",
            @"second",
            @"third"
    ];

    self.topChildViewIndex = 0;
    [self addTopChildView];
    [self addBottomChildView];

    [self addGestureRecognizer];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.skipButton setTitle:@"Skip Intro" forState:UIControlStateNormal];
}

#pragma mark - Setup


#pragma mark - Gesture Recognizer
- (void)addGestureRecognizer {
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    self.panGestureRecognizer.maximumNumberOfTouches = 1;
    [self.view addGestureRecognizer:self.panGestureRecognizer];
}

- (void)removeGestureRecognizer {
    [self.view removeGestureRecognizer:self.panGestureRecognizer];
}

- (void)handlePan:(UITapGestureRecognizer *)gestureRecognizer {

    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        self.startPoint = [gestureRecognizer locationInView:self.childView];
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {

        CGPoint point = [gestureRecognizer locationInView:self.childView];
        if (point.y < self.startPoint.y) {

            CGFloat delta = self.startPoint.y - point.y;
            BOOL isLastPage = self.topChildViewController.pageNumber == [self.pageTitles count] - 1;
            if (isLastPage) {
                CGRect childViewFrame = self.childView.frame;
                childViewFrame.origin = CGPointMake(0.0, -delta);
                self.childView.frame = childViewFrame;
//
//                CGRect childViewFrame = self.topChildViewController.view.frame;
//                childViewFrame.origin = CGPointMake(0.0, -delta);
//                self.topChildViewController.view.frame = childViewFrame;
//
//                CGRect controlViewFrame = self.controlView.frame;
//                controlViewFrame.origin = CGPointMake(0.0, controlViewFrame.origin.y - delta);
//                self.controlView.frame = controlViewFrame;
//
//                NSLog(@"controlView y: %f", controlViewFrame.origin.y);

            } else {
                CGRect childViewFrame = self.topChildViewController.view.frame;
                childViewFrame.origin = CGPointMake(0.0, -delta);
                self.topChildViewController.view.frame = childViewFrame;
            }
        }

    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint point = [gestureRecognizer locationInView:self.childView];
        CGFloat delta = self.startPoint.y - point.y;

        BOOL isLastPage = self.topChildViewController.pageNumber == [self.pageTitles count] - 1;
        if (isLastPage) {

        } else {
            if (delta / CGRectGetHeight(self.childView.bounds) > 0.2) {
                [self changeTopView];
            } else {
                [UIView animateWithDuration:0.4 animations:^{
                    CGRect frame = self.topChildViewController.view.frame;
                    frame.origin = CGPointZero;
                    self.topChildViewController.view.frame = frame;
                }];
            }
        }

    } else if (gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        NSLog(@"cancelled state");
    } else if (gestureRecognizer.state == UIGestureRecognizerStateFailed) {
        NSLog(@"failed state");
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    return YES;
}


#pragma mark - Actions
- (IBAction)skipAction:(id)sender {
    [self hideIntroView];
}

#pragma mark - Private methods
- (JMIntroChildViewController *)childVCForIndex:(NSUInteger)pageIndex {
    JMIntroChildViewController *childViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"JMIntroChildViewController"];
    childViewController.pageNumber = pageIndex;

    CGFloat childViewHeight = CGRectGetHeight(self.childView.bounds);
    CGFloat childViewWidth = CGRectGetWidth(self.childView.bounds);
    CGRect childViewFrame = CGRectMake(0, 0, childViewWidth, childViewHeight);
    childViewController.view.frame = childViewFrame;

    return childViewController;
}

- (void)addTopChildView {
    JMIntroChildViewController *childViewController = [self childVCForIndex:self.topChildViewIndex];

    [self addChildViewController:childViewController];
    [self.childView addSubview:childViewController.view];

    // setup next child view subviews
    childViewController.pageLabel.text = self.pageTitles[self.topChildViewIndex];
    [childViewController didMoveToParentViewController:self];
    self.topChildViewController = childViewController;
}

- (void)removeTopChildView {
    [self.topChildViewController willMoveToParentViewController:nil];
    [self.topChildViewController.view removeFromSuperview];
    [self.topChildViewController removeFromParentViewController];
}

- (void)addBottomChildView {
    NSUInteger bottomIndex = self.topChildViewController.pageNumber;
    bottomIndex++;

    JMIntroChildViewController *childViewController = [self childVCForIndex:bottomIndex];

    [self addChildViewController:childViewController];
    [self.childView insertSubview:childViewController.view belowSubview:self.topChildViewController.view];

    // setup next child view subviews
    childViewController.pageLabel.text = self.pageTitles[bottomIndex];
    [childViewController didMoveToParentViewController:self];
    self.bottomChildViewController = childViewController;
}

- (void)removeBottomChildView {
    [self.bottomChildViewController willMoveToParentViewController:nil];
    [self.bottomChildViewController.view removeFromSuperview];
    [self.bottomChildViewController removeFromParentViewController];
}


- (void)changeTopView {
    NSUInteger nextIndex = self.topChildViewController.pageNumber;
    nextIndex++;

    [UIView animateWithDuration:0.4 animations:^{
        CGRect frame = self.topChildViewController.view.frame;
        frame.origin = CGPointMake(0.0, -CGRectGetHeight(self.childView.frame));
        self.topChildViewController.view.frame = frame;
    } completion:^(BOOL finished) {
        // change current child to next
        [self removeTopChildView];
        [self removeBottomChildView];

        self.topChildViewIndex = nextIndex;
        [self addTopChildView];
        if (nextIndex < [self.pageTitles count] - 1) {
            [self addBottomChildView];
        }
    }];
}

- (void)hideIntroView {

    [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
}

@end
