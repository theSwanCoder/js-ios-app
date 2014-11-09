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
#import "JMIntroModelManager.h"

static const CGFloat kDefaultAnimationDuration = 0.4;

@interface JMIntroViewController ()
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *controlView;
@property (weak, nonatomic) IBOutlet UIView *startChildView;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;
@property (weak, nonatomic) JMIntroChildViewController *topChildViewController;
@property (weak, nonatomic) JMIntroChildViewController *bottomChildViewController;
@property (nonatomic, strong) JMIntroModelManager *modelManager;
@property (nonatomic, assign) BOOL isFirstPage;
@property (nonatomic, assign) BOOL isLastPage;
@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, weak) UIPanGestureRecognizer *panGestureRecognizer;
@end

@implementation JMIntroViewController

#pragma mark - LifeCircle
- (void)awakeFromNib {
    [super awakeFromNib];

    _isFirstPage = YES;
    _isLastPage = NO;
    self.modelManager = [JMIntroModelManager new];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // after loading view, there is start top view
    // need add bottom view
    [self addChildViewController];
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

#pragma mark - Gesture Recognizer
- (void)addGestureRecognizer {
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    panGestureRecognizer.maximumNumberOfTouches = 1;
    [self.view addGestureRecognizer:panGestureRecognizer];
    self.panGestureRecognizer = panGestureRecognizer;
}

- (void)removeGestureRecognizer {
    [self.view removeGestureRecognizer:self.panGestureRecognizer];
}

- (void)handlePan:(UITapGestureRecognizer *)gestureRecognizer {

    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        self.startPoint = [gestureRecognizer locationInView:self.contentView];
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        // changing position of top child view
        CGPoint currentPoint = [gestureRecognizer locationInView:self.contentView];
        if (currentPoint.y < self.startPoint.y) {
            // move top view up
            CGFloat delta = self.startPoint.y - currentPoint.y;

            if (self.isFirstPage) {
                [self setOrigin:CGPointMake(0.0, -delta)
                        forView:self.startChildView];
            } else if (self.isLastPage) {
                [self setOrigin:CGPointMake(0.0, -delta)
                        forView:self.topChildViewController.view];

                // move control view with child view
                CGFloat controlViewOriginY = CGRectGetMaxY(self.contentView.frame);
                [self setOrigin:CGPointMake(0.0, controlViewOriginY - delta)
                        forView:self.controlView];
            } else {
                [self setOrigin:CGPointMake(0.0, -delta)
                        forView:self.topChildViewController.view];
            }
        }

    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint endPoint = [gestureRecognizer locationInView:self.contentView];
        CGFloat delta = self.startPoint.y - endPoint.y;

        if (delta / CGRectGetHeight(self.contentView.bounds) > 0.2) {
            // change top view
            if (self.isFirstPage) {
                [UIView animateWithDuration:kDefaultAnimationDuration animations:^{
                    [self setOrigin:CGPointMake(0.0, -CGRectGetHeight(self.contentView.frame))
                            forView:self.startChildView];
                } completion:^(BOOL finished) {
                    self.isFirstPage = NO;
                    [self.startChildView removeFromSuperview];

                    self.topChildViewController = self.bottomChildViewController;
                    [self addChildViewController];
                }];
            } else if (self.isLastPage) {
                [UIView animateWithDuration:kDefaultAnimationDuration animations:^{
                    [self setOrigin:CGPointMake(0.0, -CGRectGetHeight(self.view.frame))
                            forView:self.topChildViewController.view];

                    [self setOrigin:CGPointMake(0.0, -CGRectGetHeight(self.controlView.frame))
                            forView:self.controlView];
                } completion:^(BOOL finished) {
                    [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
                }];
            } else {
                [self changeTopView];
            }
        } else {
            // back to origin position with animation
            if (self.isFirstPage) {
                [UIView animateWithDuration:kDefaultAnimationDuration animations:^{
                    [self setOrigin:CGPointZero
                            forView:self.startChildView];
                }];
            } else if (self.isLastPage) {
                [UIView animateWithDuration:kDefaultAnimationDuration animations:^{
                    [self setOrigin:CGPointZero
                            forView:self.topChildViewController.view];

                    // move control view with child view
                    CGFloat controlViewOriginY = CGRectGetMaxY(self.contentView.frame);
                    [self setOrigin:CGPointMake(0.0, controlViewOriginY)
                            forView:self.controlView];
                }];
            } else {
                [UIView animateWithDuration:kDefaultAnimationDuration animations:^{
                    [self setOrigin:CGPointZero
                            forView:self.topChildViewController.view];
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
- (JMIntroChildViewController *)createChildViewController {
    JMIntroChildViewController *childViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"JMIntroChildViewController"];

    CGFloat childViewHeight = CGRectGetHeight(self.contentView.frame);
    CGFloat childViewWidth = CGRectGetWidth(self.contentView.frame);
    CGRect childViewFrame = CGRectMake(0, 0, childViewWidth, childViewHeight);
    childViewController.view.frame = childViewFrame;

    return childViewController;
}

- (void)addChildViewController {
    self.bottomChildViewController = [self createChildViewController];
    [self.bottomChildViewController setupWithModel:[self.modelManager nextModel]];

    [self addChildViewController:self.bottomChildViewController];
    [self.contentView insertSubview:self.bottomChildViewController.view atIndex:0];
    [self.bottomChildViewController didMoveToParentViewController:self];
}

- (void)removeChildViewController {
    [self.topChildViewController willMoveToParentViewController:nil];
    [self.topChildViewController.view removeFromSuperview];
    [self.topChildViewController removeFromParentViewController];
}

- (void)changeTopView {
    [UIView animateWithDuration:kDefaultAnimationDuration animations:^{
        [self setOrigin:CGPointMake(0.0, -CGRectGetHeight(self.topChildViewController.view.frame))
                forView:self.topChildViewController.view];
    } completion:^(BOOL finished) {
        [self removeChildViewController];
        self.topChildViewController = self.bottomChildViewController;

        if (self.modelManager.isLastPage) {
            [self setButtonTitle:@"Start using JasperMobile"];
            self.isLastPage = YES;
        } else {
            [self addChildViewController];
        }
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

- (void)hideIntroView {

    [UIView animateWithDuration:kDefaultAnimationDuration animations:^{
        [self setOrigin:CGPointMake(0.0, -CGRectGetHeight(self.view.frame))
                forView:self.contentView];

        [self setOrigin:CGPointMake(0.0, -CGRectGetHeight(self.controlView.frame))
                forView:self.controlView];

    } completion:^(BOOL finished) {
        [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
    }];
}

@end
