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

#import "JMIntroViewController.h"
#import "JMIntroChildViewController.h"
#import "JMIntroModel.h"

static const CGFloat kDefaultAnimationDuration = 0.4;

@interface JMIntroViewController ()
@property (weak, nonatomic) IBOutlet UIButton *skipButton;
@property (weak, nonatomic) IBOutlet UIView *childView;
@property (weak, nonatomic) IBOutlet UIView *startTopView;
@property (weak, nonatomic) IBOutlet UIView *controlView;
@property (weak, nonatomic) JMIntroChildViewController *topChildViewController;
@property (weak, nonatomic) JMIntroChildViewController *bottomChildViewController;
@property (nonatomic, copy) NSArray *pageData;
@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) NSInteger topChildViewIndex;
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@end

@implementation JMIntroViewController

#pragma mark - LifeCircle
- (void)awakeFromNib {
    [super awakeFromNib];

    [self setupModel];
    self.topChildViewIndex = 0;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    //[self addTopChildView];
    [self addBottomChildView];

    [self addGestureRecognizer];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];

    [self setButtonTitle:@"Skip Intro"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}

#pragma mark - Setup
- (void)setupModel {
    JMIntroModel *firstPage = [[JMIntroModel alloc] initWithTitle:@"Stay Connected"
                                                      description:@"JasperMobile keeps you connected to\nyour business wherever you are."
                                                            image:[UIImage imageNamed:@"stay_connect_image"]];
    JMIntroModel *secondPage = [[JMIntroModel alloc] initWithTitle:@"Instant Access"
                                                       description:@"Get access to live interactive reports\ndriven from your operational applications."
                                                             image:[UIImage imageNamed:@"instant_access_image"]];
    JMIntroModel *thirdPage = [[JMIntroModel alloc] initWithTitle:@"Seemless Integration"
                                                      description:@"View and interact with your JasperReports\nServer v5.0 or greater environment."
                                                            image:[UIImage imageNamed:@"seemless_integration_image"]];
    self.pageData = @[
            @"zero", firstPage, secondPage, thirdPage
    ];
}

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
        // changing position of top child view
        CGPoint currentPoint = [gestureRecognizer locationInView:self.childView];
        if (currentPoint.y < self.startPoint.y) {
            // if move up
            CGFloat delta = self.startPoint.y - currentPoint.y;
            BOOL isLastPage = (self.topChildViewIndex == [self.pageData count] - 1);
            if (isLastPage) {
                [self setOrigin:CGPointMake(0.0, -delta)
                        forView:self.topChildViewController.view];

                // move control view with child view
                CGFloat controlViewOriginY = CGRectGetMaxY(self.childView.frame);
                [self setOrigin:CGPointMake(0.0, controlViewOriginY - delta)
                        forView:self.controlView];
            } else {
                BOOL isStartPage = (self.topChildViewIndex == 0);
                if (isStartPage) {
                    [self setOrigin:CGPointMake(0.0, -delta)
                            forView:self.startTopView];
                } else {
                    [self setOrigin:CGPointMake(0.0, -delta)
                            forView:self.topChildViewController.view];
                }
            }
        }

    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        // set end position with animation
        CGPoint endPoint = [gestureRecognizer locationInView:self.childView];
        CGFloat delta = self.startPoint.y - endPoint.y;

        BOOL isLastPage = (self.topChildViewIndex == [self.pageData count] - 1);
        if (isLastPage) {
            if (delta / CGRectGetHeight(self.childView.bounds) > 0.2) {
                [UIView animateWithDuration:kDefaultAnimationDuration animations:^{
                    [self setOrigin:CGPointMake(0.0, -CGRectGetHeight(self.view.frame))
                            forView:self.topChildViewController.view];

                    [self setOrigin:CGPointMake(0.0, -CGRectGetHeight(self.controlView.frame))
                            forView:self.controlView];
                } completion:^(BOOL finished) {
                    [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
                }];
            } else {
                [UIView animateWithDuration:kDefaultAnimationDuration animations:^{
                    [self setOrigin:CGPointZero
                            forView:self.topChildViewController.view];

                    // move control view with child view
                    CGFloat controlViewOriginY = CGRectGetMaxY(self.childView.frame);
                    [self setOrigin:CGPointMake(0.0, controlViewOriginY)
                            forView:self.controlView];
                }];
            }
        } else {
            BOOL isStartPage = (self.topChildViewIndex == 0);
            if (delta / CGRectGetHeight(self.childView.bounds) > 0.2) {
                if (isStartPage) {
                    NSInteger nextIndex = self.topChildViewIndex;
                    nextIndex++;

                    [UIView animateWithDuration:kDefaultAnimationDuration animations:^{
                        [self setOrigin:CGPointMake(0.0, -CGRectGetHeight(self.childView.frame))
                                forView:self.startTopView];
                    } completion:^(BOOL finished) {
                        [self.startTopView removeFromSuperview];

                        [self removeBottomChildView];

                        self.topChildViewIndex = nextIndex;
                        [self addTopChildView];
                        [self addBottomChildView];
                    }];
                } else {
                    [self changeTopView];
                }
            } else {
                [UIView animateWithDuration:kDefaultAnimationDuration animations:^{
                    if (isStartPage) {
                        [self setOrigin:CGPointZero
                                forView:self.startTopView];
                    } else {
                        [self setOrigin:CGPointZero
                                forView:self.topChildViewController.view];
                    }
                }];
            }
        }

    } else if (gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        NSLog(@"cancelled state");
    } else if (gestureRecognizer.state == UIGestureRecognizerStateFailed) {
        NSLog(@"failed state");
    }
}

#pragma mark - Actions
- (IBAction)skipAction:(id)sender {
    [self hideIntroView];
}

#pragma mark - Private methods
- (JMIntroChildViewController *)childViewControllerForIndex:(NSUInteger)pageIndex {
    JMIntroChildViewController *childViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"JMIntroChildViewController"];

    CGFloat childViewHeight = CGRectGetHeight(self.childView.frame);
    CGFloat childViewWidth = CGRectGetWidth(self.childView.frame);
    CGRect childViewFrame = CGRectMake(0, 0, childViewWidth, childViewHeight);
    childViewController.view.frame = childViewFrame;

    return childViewController;
}

- (void)addTopChildView {
    JMIntroChildViewController *childViewController = [self childViewControllerForIndex:self.topChildViewIndex];

    [self addChildViewController:childViewController];
    [self.childView addSubview:childViewController.view];

    // setup next child view subviews
    [childViewController setupWithModel:self.pageData[self.topChildViewIndex]];
    [childViewController didMoveToParentViewController:self];
    self.topChildViewController = childViewController;
}

- (void)removeTopChildView {
    [self.topChildViewController willMoveToParentViewController:nil];
    [self.topChildViewController.view removeFromSuperview];
    [self.topChildViewController removeFromParentViewController];
}

- (void)addBottomChildView {
    NSInteger bottomIndex = self.self.topChildViewIndex;
    bottomIndex++;

    JMIntroChildViewController *childViewController = [self childViewControllerForIndex:bottomIndex];

    [self addChildViewController:childViewController];
    [self.childView insertSubview:childViewController.view atIndex:0];

    // setup next child view subviews
    [childViewController setupWithModel:self.pageData[bottomIndex]];
    [childViewController didMoveToParentViewController:self];
    self.bottomChildViewController = childViewController;
}

- (void)removeBottomChildView {
    [self.bottomChildViewController willMoveToParentViewController:nil];
    [self.bottomChildViewController.view removeFromSuperview];
    [self.bottomChildViewController removeFromParentViewController];
}


- (void)changeTopView {
    NSInteger nextIndex = self.topChildViewIndex;
    nextIndex++;

    [UIView animateWithDuration:kDefaultAnimationDuration animations:^{
        [self setOrigin:CGPointMake(0.0, -CGRectGetHeight(self.topChildViewController.view.frame))
                forView:self.topChildViewController.view];
    } completion:^(BOOL finished) {
        // change current child to next
        [self removeTopChildView];
        [self removeBottomChildView];

        self.topChildViewIndex = nextIndex;
        [self addTopChildView];
        BOOL isLastPage = (nextIndex == [self.pageData count] - 1);
        if (!isLastPage) {
            [self addBottomChildView];
        } else {
            [self setButtonTitle:@"Start using JasperMobile"];
        }
    }];
}

- (void)hideIntroView {

    [UIView animateWithDuration:kDefaultAnimationDuration animations:^{
        [self setOrigin:CGPointMake(0.0, -CGRectGetHeight(self.view.frame))
                forView:self.childView];

        [self setOrigin:CGPointMake(0.0, -CGRectGetHeight(self.controlView.frame))
                forView:self.controlView];

    } completion:^(BOOL finished) {
        [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
    }];
}

- (void)setButtonTitle:(NSString *)buttonTitle {
    [self.skipButton setTitle:buttonTitle forState:UIControlStateNormal];
}

- (void)setOrigin:(CGPoint)origin forView:(UIView *)view {
    CGRect viewFrame = view.frame;
    viewFrame.origin = origin;
    view.frame = viewFrame;
}

@end
