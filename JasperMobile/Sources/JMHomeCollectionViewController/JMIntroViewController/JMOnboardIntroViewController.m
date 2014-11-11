//
//  JMOnboardIntroViewController.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 11/11/14.
//  Copyright (c) 2014 Tibco JasperMobile. All rights reserved.
//

#import "JMOnboardIntroViewController.h"

static const CGFloat kDefaultAnimationDuration = 0.4;

@interface JMOnboardIntroViewController ()
@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIImageView *homeScreenImage;
@property (weak, nonatomic) IBOutlet UIImageView *reportScreenIphoneImage;
@property (weak, nonatomic) IBOutlet UIImageView *reportScreenIpadImage;
@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, weak) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, weak) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, assign) CGRect startFrameTitleView;
@property (nonatomic, assign) CGRect endFrameTitleView;
@property (nonatomic, assign) CGRect startFrameContentView;
@property (nonatomic, assign) CGRect endFrameContentView;
@property (nonatomic, assign) CGRect startFrameHomeScreenImage;
@property (nonatomic, assign) CGRect endFrameHomeScreenImage;
@property (nonatomic, assign) NSUInteger currentPageIndex;
@end

@implementation JMOnboardIntroViewController

#pragma mark - LifeCircle
- (void)awakeFromNib {
    [super awakeFromNib];

    self.currentPageIndex = 0;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self addGestureRecognizer];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];

    CGRect titleViewFrame = self.titleView.frame;
    CGRect contentViewFrame = self.contentView.frame;
    CGRect homeScreenImageFrame = self.homeScreenImage.frame;
    CGRect viewBounds = self.view.bounds;
    CGFloat titleViewMinHeight = 100;
    CGFloat homeScreenTopPadding = 10;

    self.startFrameTitleView = titleViewFrame;
    self.endFrameTitleView = CGRectMake(
            titleViewFrame.origin.x,
            titleViewFrame.origin.y,
            titleViewFrame.size.width,
            titleViewMinHeight);
    self.startFrameContentView = contentViewFrame;
    self.endFrameContentView = CGRectMake(
            contentViewFrame.origin.x,
            titleViewMinHeight,
            contentViewFrame.size.width,
            viewBounds.size.height - titleViewMinHeight);

    self.startFrameHomeScreenImage = homeScreenImageFrame;
    self.endFrameHomeScreenImage = CGRectMake(
            homeScreenImageFrame.origin.x,
            self.endFrameTitleView.origin.y + homeScreenTopPadding,
            homeScreenImageFrame.size.width,
            homeScreenImageFrame.size.height);

    CGRect reportScreenIpadImageFrame = self.reportScreenIpadImage.frame;
    CGFloat reportScreenIpadImageFrameOriginX = -viewBounds.size.width - reportScreenIpadImageFrame.size.width;
    CGFloat reportScreenIpadImageFrameOriginY = 100;
    reportScreenIpadImageFrame.origin = CGPointMake(reportScreenIpadImageFrameOriginX, reportScreenIpadImageFrameOriginY);
    self.reportScreenIpadImage.frame = reportScreenIpadImageFrame;

    CGRect reportScreenIphoneImageFrame = self.reportScreenIphoneImage.frame;
    CGFloat reportScreenIphoneImageFrameOriginX = viewBounds.size.width + reportScreenIphoneImageFrame.size.width;
    CGFloat reportScreenIphoneImageFrameOriginY = 200;
    reportScreenIphoneImageFrame.origin = CGPointMake(reportScreenIphoneImageFrameOriginX, reportScreenIphoneImageFrameOriginY);
    self.reportScreenIphoneImage.frame = reportScreenIphoneImageFrame;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}

#pragma mark - Gesture Recognizer
- (void)addGestureRecognizer {
//    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
//    panGestureRecognizer.maximumNumberOfTouches = 1;
//    [self.view addGestureRecognizer:panGestureRecognizer];
//    self.panGestureRecognizer = panGestureRecognizer;

    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tapGestureRecognizer];
    self.tapGestureRecognizer = tapGestureRecognizer;
}

- (void)removeGestureRecognizer {
    [self.view removeGestureRecognizer:self.panGestureRecognizer];
    [self.view removeGestureRecognizer:self.tapGestureRecognizer];
}

- (void)handleTap:(UITapGestureRecognizer *)tapGestureRecognizer {

    if (self.currentPageIndex == 0) {
        [UIView animateWithDuration:kDefaultAnimationDuration animations:^{
            self.titleView.frame = self.endFrameTitleView;
            self.contentView.frame = self.endFrameContentView;

            self.homeScreenImage.frame = self.endFrameHomeScreenImage;
        } completion:^(BOOL finished) {
            self.currentPageIndex++;
        }];
    } else if (self.currentPageIndex == 1) {
        CGRect homeScreenImageFrame = self.homeScreenImage.frame;
        CGRect viewBounds = self.view.bounds;
        CGFloat titleViewMinHeight = 100;
        CGFloat bottomViewHeight = 50;
        CGFloat newHomeSrceenImageOriginX = viewBounds.size.width/2 - homeScreenImageFrame.size.width/10;
        CGFloat newHomeSrceenImageOriginY = viewBounds.size.height - titleViewMinHeight - bottomViewHeight - homeScreenImageFrame.size.height/5;
        self.endFrameHomeScreenImage = CGRectMake(
                newHomeSrceenImageOriginX,
                newHomeSrceenImageOriginY,
                homeScreenImageFrame.size.width/5,
                homeScreenImageFrame.size.height/5);

        [UIView animateWithDuration:kDefaultAnimationDuration animations:^{
            self.homeScreenImage.frame = self.endFrameHomeScreenImage;


            CGRect reportScreenIpadImageFrame = self.reportScreenIpadImage.frame;
            CGFloat reportScreenIpadImageFrameOriginX = viewBounds.size.width/2 - reportScreenIpadImageFrame.size.width/2;
            CGFloat reportScreenIpadImageFrameOriginY = 100;
            reportScreenIpadImageFrame.origin = CGPointMake(reportScreenIpadImageFrameOriginX, reportScreenIpadImageFrameOriginY);
            self.reportScreenIpadImage.frame = reportScreenIpadImageFrame;

            CGRect reportScreenIphoneImageFrame = self.reportScreenIphoneImage.frame;
            CGFloat reportScreenIphoneImageFrameOriginX = reportScreenIpadImageFrameOriginX + 150;
            CGFloat reportScreenIphoneImageFrameOriginY = 230;
            reportScreenIphoneImageFrame.origin = CGPointMake(reportScreenIphoneImageFrameOriginX, reportScreenIphoneImageFrameOriginY);
            self.reportScreenIphoneImage.frame = reportScreenIphoneImageFrame;

        } completion:^(BOOL finished) {

            [UIView animateWithDuration:kDefaultAnimationDuration animations:^{
                CGRect newFrameHomeScreen = self.homeScreenImage.frame;
                newFrameHomeScreen.origin.y += newFrameHomeScreen.size.height;
                self.homeScreenImage.frame = newFrameHomeScreen;
            } completion:^(BOOL finished) {
                self.currentPageIndex++;
            }];
        }];
    }

}

- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer {

    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        self.startPoint = [gestureRecognizer locationInView:self.view];
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {

    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint endPoint = [gestureRecognizer locationInView:self.view];
        CGFloat delta = self.startPoint.y - endPoint.y;

        if (delta / CGRectGetHeight(self.contentView.bounds) > 0.2) {
            [UIView animateWithDuration:kDefaultAnimationDuration animations:^{
                self.titleView.frame = self.endFrameTitleView;
                self.contentView.frame = self.endFrameContentView;

                self.homeScreenImage.frame = self.endFrameHomeScreenImage;
            }];
        } else {
            [UIView animateWithDuration:kDefaultAnimationDuration animations:^{
                self.titleView.frame = self.startFrameTitleView;
                self.contentView.frame = self.startFrameContentView;

                self.homeScreenImage.frame = self.startFrameHomeScreenImage;
            }];
        }

    } else if (gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        NSLog(@"cancelled state");
    } else if (gestureRecognizer.state == UIGestureRecognizerStateFailed) {
        NSLog(@"failed state");
    }
}

#pragma mark - Private methods




@end
