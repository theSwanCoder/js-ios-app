//
//  JMOnboardIntroViewController.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 11/11/14.
//  Copyright (c) 2014 Tibco JasperMobile. All rights reserved.
//

#import "JMOnboardIntroViewController.h"
#import "UIView+Additions.h"
#import "JMIntroModelManager.h"
#import "JMIntroModel.h"

typedef NS_ENUM(NSInteger, JMOnboardIntroPage) {
    JMOnboardIntroPageWelcome,
    JMOnboardIntroPageStayConnected,
    JMOnboardIntroPageInstanceAccess,
    JMOnboardIntroPageSeemlessIntegration
};

static const CGFloat kDefaultAnimationDuration = 0.4f;
static const CGFloat kDefaultStepValue = 1.0f;

@interface JMOnboardIntroViewController ()
@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *welcomeView;
@property (weak, nonatomic) IBOutlet UIView *messageView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIImageView *homeScreenImage;
@property (weak, nonatomic) IBOutlet UIImageView *reportScreenIphoneImage;
@property (weak, nonatomic) IBOutlet UIImageView *reportScreenIpadImage;
@property (weak, nonatomic) IBOutlet UIImageView *serverScreenImage;
@property (nonatomic, strong) JMIntroModelManager *modelManager;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;
@property (weak, nonatomic) IBOutlet UILabel *titlePageLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionPageLabel;
@property (nonatomic, weak) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, weak) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, assign) JMOnboardIntroPage introPage;
@property (nonatomic, assign) BOOL isUnderRedLine;
@end

@implementation JMOnboardIntroViewController

#pragma mark - LifeCircle
- (void)awakeFromNib {
    [super awakeFromNib];

    self.introPage = JMOnboardIntroPageWelcome;
    self.modelManager = [JMIntroModelManager new];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self addGestureRecognizer];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];

    [self setButtonTitle:@"Skip Intro"];

    UIImage *homeScreenImage = [UIImage imageNamed:@"home_screen"];
    self.homeScreenImage.image = homeScreenImage;
    UIImage *serversScreenImage = [UIImage imageNamed:@"server_screen"];
    self.serverScreenImage.image = serversScreenImage;

    [self setupTitleViewStartPosition];
    [self setupContentViewStartPosition];

    [self setupHomeScreenImageStartPosition];
    [self setupReportScreenIphoneImageStartPosition];
    [self setupReportScreenIpadImageStartPosition];
    [self setupServerScreenImageStartPosition];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}

- (BOOL)shouldAutorotate {
    return NO;
}

#pragma mark - Actions
- (IBAction)skipAction:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Setup
- (void)setupTitleViewStartPosition {
    CGFloat newHeight = CGRectGetHeight(self.welcomeView.frame);
    [self.titleView updateHeightWithValue:newHeight];
}

- (void)setupTitleViewEndPosition {
    CGFloat newHeight = CGRectGetHeight(self.messageView.frame);
    [self.titleView updateHeightWithValue:newHeight];
}

- (void)setupContentViewStartPosition {
    CGFloat contentViewStartHeight;
    if ([JMUtils isIphone]) {
        contentViewStartHeight = 290;
    } else {
        contentViewStartHeight = 610;
    }
    [self.contentView updateOriginYWithValue:contentViewStartHeight];
}

- (void)setupContentViewEndPosition {
    CGFloat titleViewHeight = CGRectGetHeight(self.titleView.frame);
    [self.contentView updateOriginWithOrigin:CGPointMake(0, titleViewHeight)];
}

- (void)setupHomeScreenImageStartPosition {
    CGFloat homeScreenTopPadding = 10;

    UIImage *homeScreenImage = self.homeScreenImage.image;
    CGFloat homeScreenImageWidth = homeScreenImage.size.width;
    CGFloat homeScreenImageHeight = homeScreenImage.size.height;

    CGFloat mainViewWidth = CGRectGetWidth(self.view.bounds);
    CGFloat newOriginX = mainViewWidth/2 - homeScreenImageWidth/2;
    CGFloat newOriginY = homeScreenTopPadding;
    [self.homeScreenImage updateFrameWithOrigin:CGPointMake(newOriginX, newOriginY)
                                           size:CGSizeMake(homeScreenImageWidth, homeScreenImageHeight)];
}

- (void)setupHomeScreenImageSmallSizeOutScreen {
    CGFloat titleViewEndPositionHeight = CGRectGetHeight(self.messageView.frame);
    CGFloat bottomViewHeight = CGRectGetHeight(self.bottomView.frame);

    UIImage *homeScreenImage = self.homeScreenImage.image;
    CGFloat homeScreenImageWidth = homeScreenImage.size.width;
    CGFloat homeScreenImageHeight = homeScreenImage.size.height;

    CGFloat contentViewWidth = CGRectGetWidth(self.contentView.frame);
    CGFloat mainViewHeight = CGRectGetHeight(self.view.bounds);
    CGFloat newOriginX = contentViewWidth/2 - homeScreenImageWidth/(2*5.0f);
    CGFloat newOriginY = mainViewHeight - titleViewEndPositionHeight - bottomViewHeight;
    [self.homeScreenImage updateFrameWithOrigin:CGPointMake(newOriginX, newOriginY)
                                           size:CGSizeMake(homeScreenImageWidth/5.0f, homeScreenImageHeight/5.0f)];
}

- (void)setupReportScreenIpadImageStartPosition {
    CGFloat bottomViewHeight = CGRectGetHeight(self.bottomView.frame);
    CGFloat reportScreenIpadImageWidth = CGRectGetWidth(self.reportScreenIpadImage.frame);
    CGFloat newOriginX = -reportScreenIpadImageWidth;
    CGFloat newOriginY = bottomViewHeight;
    [self.reportScreenIpadImage updateOriginWithOrigin:CGPointMake(newOriginX, newOriginY)];
}

- (void)setupReportScreenIpadImageEndPosition {
    CGFloat bottomViewHeight = CGRectGetHeight(self.bottomView.frame);
    CGFloat contentViewWidth = CGRectGetWidth(self.contentView.frame);
    CGFloat reportScreenIpadImageWidth = CGRectGetWidth(self.reportScreenIpadImage.frame);
    CGFloat newOriginX = contentViewWidth/2 - reportScreenIpadImageWidth/2;
    CGFloat newOriginY = bottomViewHeight;
    [self.reportScreenIpadImage updateOriginWithOrigin:CGPointMake(newOriginX, newOriginY)];
}

- (void)setupReportScreenIphoneImageStartPosition {
    CGFloat contentViewWidth = CGRectGetWidth(self.contentView.frame);
    CGFloat newOriginX = contentViewWidth;
    CGFloat newOriginY = 170;
    [self.reportScreenIphoneImage updateOriginWithOrigin:CGPointMake(newOriginX, newOriginY)];
}

- (void)setupReportScreenIphoneImageEndPosition {
    CGFloat newOriginX = self.contentView.frame.size.width/2 - self.reportScreenIphoneImage.frame.size.width/2 + 100;
    CGFloat newOriginY = 170;
    [self.reportScreenIphoneImage updateOriginWithOrigin:CGPointMake(newOriginX, newOriginY)];
}

- (void)setupServerScreenImageStartPosition {
    CGFloat titleViewEndPositionHeight = CGRectGetHeight(self.messageView.frame);
    CGFloat bottomViewHeight = CGRectGetHeight(self.bottomView.frame);

    UIImage *serverScreenImage = self.serverScreenImage.image;
    CGFloat serverScreenImageWidth = serverScreenImage.size.width;
    CGFloat serverScreenImageHeight = serverScreenImage.size.height;

    CGFloat newOriginX = self.view.bounds.size.width/2 - serverScreenImageWidth/(2*5.0f);
    CGFloat newOriginY = self.view.bounds.size.height - titleViewEndPositionHeight - bottomViewHeight;
    [self.serverScreenImage updateFrameWithOrigin:CGPointMake(newOriginX, newOriginY)
                                             size:CGSizeMake(serverScreenImageWidth/5.0f, serverScreenImageHeight/5.0f)];
}

- (void)setupServerScreenImageFullSizePosition {
    CGFloat serverScreenImageTopPadding = 10;
    UIImage *serverScreenImage = self.serverScreenImage.image;
    CGFloat serverScreenImageWidth = serverScreenImage.size.width;
    CGFloat serverScreenImageHeight = serverScreenImage.size.height;

    CGFloat newOriginX = self.view.bounds.size.width/2 - serverScreenImageWidth/2;
    CGFloat newOriginY = serverScreenImageTopPadding;
    [self.serverScreenImage updateFrameWithOrigin:CGPointMake(newOriginX, newOriginY)
                                             size:CGSizeMake(serverScreenImageWidth, serverScreenImageHeight)];
}

#pragma mark - Animations

#pragma mark - Gesture Recognizer
- (void)addGestureRecognizer {
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    panGestureRecognizer.maximumNumberOfTouches = 1;
    [self.view addGestureRecognizer:panGestureRecognizer];
    self.panGestureRecognizer = panGestureRecognizer;

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
    if (self.introPage == JMOnboardIntroPageWelcome) {
        [UIView animateWithDuration:kDefaultAnimationDuration animations:^{
            [self setupTitleViewEndPosition];
            [self setupContentViewEndPosition];
        } completion:^(BOOL finished) {
            self.welcomeView.hidden = YES;
            self.messageView.hidden = NO;
            // now page is
            self.introPage = JMOnboardIntroPageStayConnected;
            [self setButtonTitle:@"Skip Intro"];

            JMIntroModel *model = [self.modelManager modelAtIndex:0];
            self.titlePageLabel.text = model.pageTitle;
            self.descriptionPageLabel.text = model.pageDescription;
        }];
    } else if (self.introPage == JMOnboardIntroPageStayConnected) {
        [UIView animateWithDuration:kDefaultAnimationDuration animations:^{
            [self setupHomeScreenImageSmallSizeOutScreen];
            [self setupReportScreenIpadImageEndPosition];
            [self setupReportScreenIphoneImageEndPosition];
        } completion:^(BOOL finished) {
            // now page is
            self.introPage = JMOnboardIntroPageInstanceAccess;
            [self setButtonTitle:@"Skip Intro"];

            JMIntroModel *model = [self.modelManager modelAtIndex:1];
            self.titlePageLabel.text = model.pageTitle;
            self.descriptionPageLabel.text = model.pageDescription;
        }];
    } else if (self.introPage == JMOnboardIntroPageInstanceAccess) {
        [UIView animateWithDuration:kDefaultAnimationDuration animations:^{
            [self setupServerScreenImageFullSizePosition];
            [self setupReportScreenIphoneImageStartPosition];
            [self setupReportScreenIpadImageStartPosition];
        } completion:^(BOOL finished) {
            // now page is
            self.introPage = JMOnboardIntroPageSeemlessIntegration;
            [self setButtonTitle:@"Start using JasperMobile"];

            JMIntroModel *model = [self.modelManager modelAtIndex:2];
            self.titlePageLabel.text = model.pageTitle;
            self.descriptionPageLabel.text = model.pageDescription;
        }];
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer {

    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        // start point
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint velocity = [gestureRecognizer velocityInView:self.view];
        switch (self.introPage) {
            case JMOnboardIntroPageWelcome : {
                [self changeWelcomePageViewsWithVelocity:velocity];
                break;
            }
            case JMOnboardIntroPageStayConnected : {
                [self changeStayConnectedViewsWithVelocity:velocity];
                break;
            }
            case JMOnboardIntroPageInstanceAccess : {
                [self changeInstanceAccessViewsWithVelocity:velocity];
                break;
            }
            case JMOnboardIntroPageSeemlessIntegration : {
                [self changeSeemlessIntegrationPageViewsWithVelocity:velocity];
                break;
            }
        }
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint velocity = [gestureRecognizer velocityInView:self.view];
        switch (self.introPage) {
            case JMOnboardIntroPageWelcome : {
                [self updateWelcomePageViewsWithVelocity:velocity];
                break;
            }
            case JMOnboardIntroPageStayConnected : {
                [self updateStayConnectedPageViewsWithVelocity:velocity];
                break;
            }
            case JMOnboardIntroPageInstanceAccess : {
                [self updateInstanceAccessPageViewsWithVelocity:velocity];
                break;
            }
            case JMOnboardIntroPageSeemlessIntegration : {
                [self updateSeemlessIntegrationViewsPageWithVelocity:velocity];
                break;
            }
        }
    } else if (gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        NSLog(@"cancelled state");
    } else if (gestureRecognizer.state == UIGestureRecognizerStateFailed) {
        NSLog(@"failed state");
    }
}

#pragma mark - Private methods
- (void)setButtonTitle:(NSString *)buttonTitle {
    [self.skipButton setTitle:buttonTitle forState:UIControlStateNormal];
}


#pragma mark - Welcome Page
- (void)changeWelcomePageViewsWithVelocity:(CGPoint)velocity {
    CGPoint contentViewOrigin = self.contentView.frame.origin;
    CGFloat contentViewStartOriginY = 290;
    CGFloat contentViewBeginUpdateOriginY = 230;
    CGFloat contentViewUpperValueOriginY = 200;
    CGFloat contentViewBottomValueOriginY = 350;

    if (velocity.y > 0) {
        // move down
        if (contentViewOrigin.y == contentViewStartOriginY) {
            self.isUnderRedLine = YES;
        }

        if (self.isUnderRedLine) {
            if (contentViewOrigin.y < contentViewBottomValueOriginY) {
                [self.contentView updateOriginYWithValue:(contentViewOrigin.y + kDefaultStepValue)];
            }
        } else {
            [self.contentView updateOriginYWithValue:(contentViewOrigin.y + kDefaultStepValue)];
            if (contentViewOrigin.y == contentViewBeginUpdateOriginY) {
                // update title view
                self.welcomeView.hidden = !self.welcomeView.hidden;
                self.messageView.hidden = !self.messageView.hidden;
            }
        }
    } else {
        // move up
        if (contentViewOrigin.y == contentViewStartOriginY) {
            self.isUnderRedLine = NO;
        }

        if (self.isUnderRedLine) {
            [self.contentView updateOriginYWithValue:(contentViewOrigin.y - kDefaultStepValue)];
        } else {
            if (contentViewOrigin.y > contentViewUpperValueOriginY) {
                [self.contentView updateOriginYWithValue:(contentViewOrigin.y - kDefaultStepValue)];
                if (contentViewOrigin.y == contentViewBeginUpdateOriginY) {
                    // update title view
                    self.welcomeView.hidden = !self.welcomeView.hidden;
                    self.messageView.hidden = !self.messageView.hidden;
                }
            }
        }
    }
}

- (void)updateWelcomePageViewsWithVelocity:(CGPoint)velocity {
    CGFloat velocityY = fabsf(velocity.y);
    CGFloat contentViewBeginUpdateOriginY = 230;

    if (velocity.y > 0) {
        // move down

        // restore previous state
        [UIView animateWithDuration:kDefaultAnimationDuration animations:^{
            [self setupContentViewStartPosition];
        }];
    } else {
        // move up

        if (self.contentView.frame.origin.y < contentViewBeginUpdateOriginY || velocityY > 500) {
            // begin move to next page
            [UIView animateWithDuration:kDefaultAnimationDuration animations:^{
                [self setupTitleViewEndPosition];
                [self setupContentViewEndPosition];
            } completion:^(BOOL finished) {
                self.welcomeView.hidden = YES;
                self.messageView.hidden = NO;

                // titles
                JMIntroModel *model = [self.modelManager modelAtIndex:0];
                self.titlePageLabel.text = model.pageTitle;
                self.descriptionPageLabel.text = model.pageDescription;

                [self setButtonTitle:@"Skip Intro"];

                // now page is
                self.introPage = JMOnboardIntroPageStayConnected;
            }];
        } else {
            // restore previous state
            [UIView animateWithDuration:kDefaultAnimationDuration animations:^{
                [self setupContentViewStartPosition];
            }];
        }
    }
}

#pragma mark - Stay Connected Page
- (void)changeStayConnectedViewsWithVelocity:(CGPoint)velocity {

    CGPoint homeScreenImageOrigin = self.homeScreenImage.frame.origin;
    CGSize homeScreenImageSize = self.homeScreenImage.frame.size;
    CGFloat homeScreenImageSizeProportion = homeScreenImageSize.height / homeScreenImageSize.width;
    CGFloat homeScreenImageStartOriginY = 10;
    CGFloat homeScreenImageBeginUpdateOriginY = 70;
    CGFloat homeScreenImageBottomValueOriginY = 90;

    if (velocity.y > 0) {
        // move down
        if (homeScreenImageOrigin.y == homeScreenImageStartOriginY ) {
            self.isUnderRedLine = YES;
        }

        if (self.isUnderRedLine) {
            if (homeScreenImageOrigin.y < homeScreenImageBottomValueOriginY) {
                [self.homeScreenImage updateOriginYWithValue:(homeScreenImageOrigin.y + kDefaultStepValue)];
            }
        } else {
            // start expend home screen image
            CGFloat newOriginX = self.contentView.frame.size.width / 2 - homeScreenImageSize.width / 2;
            CGFloat newOriginY = homeScreenImageOrigin.y - kDefaultStepValue;
            CGPoint newOrigin = CGPointMake(newOriginX, newOriginY);

            CGFloat newHeight = homeScreenImageSize.height + kDefaultStepValue * (homeScreenImageSizeProportion);
            CGFloat newWidth = homeScreenImageSize.width + kDefaultStepValue - 0.5f;
            CGSize newSize = CGSizeMake(newWidth, newHeight);
            [self.homeScreenImage updateFrameWithOrigin:newOrigin
                                                   size:newSize];

            // start hiding ipad image
            [self.reportScreenIpadImage updateOriginXWithValue:(self.reportScreenIpadImage.frame.origin.x - kDefaultStepValue)];
            // start hiding iphone image
            [self.reportScreenIphoneImage updateOriginXWithValue:(self.reportScreenIphoneImage.frame.origin.x + kDefaultStepValue)];

            if (homeScreenImageOrigin.y == homeScreenImageBeginUpdateOriginY) {
                // current page title
                JMIntroModel *model = [self.modelManager modelAtIndex:0];
                self.titlePageLabel.text = model.pageTitle;
                self.descriptionPageLabel.text = model.pageDescription;
            }
        }
    } else {
        // move up
        if (homeScreenImageOrigin.y == homeScreenImageStartOriginY) {
            self.isUnderRedLine = NO;
        }

        if (self.isUnderRedLine) {
            [self.homeScreenImage updateOriginYWithValue:(homeScreenImageOrigin.y - kDefaultStepValue)];
        } else {
            if (homeScreenImageOrigin.y < homeScreenImageBottomValueOriginY) {
                // start shrink home screen image
                CGFloat newOriginX = self.contentView.frame.size.width / 2 - homeScreenImageSize.width / 2;
                CGFloat newOriginY = homeScreenImageOrigin.y + kDefaultStepValue;
                CGPoint newOrigin = CGPointMake(newOriginX, newOriginY);

                CGFloat newHeight = homeScreenImageSize.height - kDefaultStepValue * (homeScreenImageSizeProportion) - 1;
                CGFloat newWidth = homeScreenImageSize.width - kDefaultStepValue - 0.5f;
                CGSize newSize = CGSizeMake(newWidth, newHeight);
                [self.homeScreenImage updateFrameWithOrigin:newOrigin
                                                       size:newSize];

                // start showing ipad image
                [self.reportScreenIpadImage updateOriginXWithValue:(self.reportScreenIpadImage.frame.origin.x + kDefaultStepValue)];
                // start showing iphone image
                [self.reportScreenIphoneImage updateOriginXWithValue:(self.reportScreenIphoneImage.frame.origin.x - kDefaultStepValue)];

                if (homeScreenImageOrigin.y == homeScreenImageBeginUpdateOriginY) {
                    // next page title
                    JMIntroModel *model = [self.modelManager modelAtIndex:1];
                    self.titlePageLabel.text = model.pageTitle;
                    self.descriptionPageLabel.text = model.pageDescription;
                }
            }
        }
    }
}

- (void)updateStayConnectedPageViewsWithVelocity:(CGPoint)velocity {
    CGFloat velocityY = fabsf(velocity.y);
    CGFloat homeScreenImageBeginUpdateOriginY = 70;

    if (velocity.y > 0) {
        // move down

        if (self.homeScreenImage.frame.origin.y > homeScreenImageBeginUpdateOriginY || velocityY > 500) {
            // move to previous page
            [UIView animateWithDuration:kDefaultAnimationDuration animations:^{
                [self setupTitleViewStartPosition];
                [self setupContentViewStartPosition];
                [self setupHomeScreenImageStartPosition];
            } completion:^(BOOL finished) {
                self.welcomeView.hidden = NO;
                self.messageView.hidden = YES;
                // now page is
                self.introPage = JMOnboardIntroPageWelcome;
            }];
        } else {
            // restore current state
            [UIView animateWithDuration:kDefaultAnimationDuration animations:^{
                [self setupReportScreenIpadImageStartPosition];
                [self setupReportScreenIphoneImageStartPosition];
                [self setupHomeScreenImageStartPosition];
            }];
        }
    } else {
        // move up

        if (self.homeScreenImage.frame.origin.y > homeScreenImageBeginUpdateOriginY || velocityY > 500) {
            // move to next page
            [UIView animateWithDuration:kDefaultAnimationDuration animations:^{
                [self setupHomeScreenImageSmallSizeOutScreen];
                [self setupReportScreenIpadImageEndPosition];
                [self setupReportScreenIphoneImageEndPosition];
            } completion:^(BOOL finished) {
                // titles
                JMIntroModel *model = [self.modelManager modelAtIndex:1];
                self.titlePageLabel.text = model.pageTitle;
                self.descriptionPageLabel.text = model.pageDescription;

                [self setButtonTitle:@"Skip Intro"];
                // now page is
                self.introPage = JMOnboardIntroPageInstanceAccess;
            }];
        } else {
            // restore current state
            [UIView animateWithDuration:kDefaultAnimationDuration animations:^{
                [self setupReportScreenIpadImageStartPosition];
                [self setupReportScreenIphoneImageStartPosition];
                [self setupHomeScreenImageStartPosition];
            }];
        }
    }
}

#pragma mark - Instance Access Page

- (void)changeInstanceAccessViewsWithVelocity:(CGPoint)velocity {
    CGPoint reportScreenIpadImageOrigin = self.reportScreenIpadImage.frame.origin;
    CGFloat reportScreenIpadImageFrameOriginX = self.contentView.frame.size.width/2 - self.reportScreenIpadImage.frame.size.width/2;
    CGFloat reportScreenIpadImageBeginUpdateOriginX = 20;
    CGFloat reportScreenIpadImageBottomValueOriginX = 0;

    if (velocity.y > 0) {
        // move down
        if (reportScreenIpadImageOrigin.x == reportScreenIpadImageFrameOriginX) {
            self.isUnderRedLine = YES;
        }

        if (self.isUnderRedLine) {
            if (reportScreenIpadImageOrigin.x > reportScreenIpadImageBottomValueOriginX) {
                [self.homeScreenImage updateOriginYWithValue:(self.homeScreenImage.frame.origin.y - kDefaultStepValue)];
                // start hiding ipad image
                [self.reportScreenIpadImage updateOriginXWithValue:(self.reportScreenIpadImage.frame.origin.x - kDefaultStepValue)];
                // start hiding iphone image
                [self.reportScreenIphoneImage updateOriginXWithValue:(self.reportScreenIphoneImage.frame.origin.x + kDefaultStepValue)];
            }
        } else {
            [self.serverScreenImage updateOriginYWithValue:(self.serverScreenImage.frame.origin.y + kDefaultStepValue)];
            // start hiding ipad image
            [self.reportScreenIpadImage updateOriginXWithValue:(self.reportScreenIpadImage.frame.origin.x + kDefaultStepValue)];
            // start hiding iphone image
            [self.reportScreenIphoneImage updateOriginXWithValue:(self.reportScreenIphoneImage.frame.origin.x - kDefaultStepValue)];

            if (reportScreenIpadImageOrigin.x == reportScreenIpadImageBeginUpdateOriginX) {
                // current page title
                JMIntroModel *model = [self.modelManager modelAtIndex:1];
                self.titlePageLabel.text = model.pageTitle;
                self.descriptionPageLabel.text = model.pageDescription;
            }
        }
    } else {
        // move up
        if (reportScreenIpadImageOrigin.x == reportScreenIpadImageFrameOriginX) {
            self.isUnderRedLine = NO;
        }

        if (self.isUnderRedLine) {
            [self.homeScreenImage updateOriginYWithValue:(self.homeScreenImage.frame.origin.y + kDefaultStepValue)];
            // start hiding ipad image
            [self.reportScreenIpadImage updateOriginXWithValue:(self.reportScreenIpadImage.frame.origin.x + kDefaultStepValue)];
            // start hiding iphone image
            [self.reportScreenIphoneImage updateOriginXWithValue:(self.reportScreenIphoneImage.frame.origin.x - kDefaultStepValue)];
        } else {
            if (reportScreenIpadImageOrigin.x > reportScreenIpadImageBottomValueOriginX) {
                [self.serverScreenImage updateOriginYWithValue:(self.serverScreenImage.frame.origin.y - kDefaultStepValue)];
                // start hiding ipad image
                [self.reportScreenIpadImage updateOriginXWithValue:(self.reportScreenIpadImage.frame.origin.x - kDefaultStepValue)];
                // start hiding iphone image
                [self.reportScreenIphoneImage updateOriginXWithValue:(self.reportScreenIphoneImage.frame.origin.x + kDefaultStepValue)];

                if (reportScreenIpadImageOrigin.x == reportScreenIpadImageBeginUpdateOriginX) {
                    // next page title
                    JMIntroModel *model = [self.modelManager modelAtIndex:2];
                    self.titlePageLabel.text = model.pageTitle;
                    self.descriptionPageLabel.text = model.pageDescription;
                }
            }
        }
    }
}

- (void)updateInstanceAccessPageViewsWithVelocity:(CGPoint)velocity {
    CGFloat velocityY = fabsf(velocity.y);
    CGPoint reportScreenIpadImageOrigin = self.reportScreenIpadImage.frame.origin;
    CGFloat reportScreenIpadImageBeginUpdateOriginX = 20;

    if (velocity.y > 0) {
        // move down

        if (reportScreenIpadImageOrigin.x < reportScreenIpadImageBeginUpdateOriginX || velocityY > 500) {
            // move to previous page
            [UIView animateWithDuration:kDefaultAnimationDuration animations:^{
                [self setupReportScreenIpadImageStartPosition];
                [self setupReportScreenIphoneImageStartPosition];
                [self setupHomeScreenImageStartPosition];
            } completion:^(BOOL finished) {
                // titles
                JMIntroModel *model = [self.modelManager modelAtIndex:0];
                self.titlePageLabel.text = model.pageTitle;
                self.descriptionPageLabel.text = model.pageDescription;

                [self setButtonTitle:@"Skip Intro"];

                self.introPage = JMOnboardIntroPageStayConnected;
            }];
        } else {
            // restore current page
            if (self.isUnderRedLine) {
                [UIView animateWithDuration:kDefaultAnimationDuration animations:^{
                    [self setupHomeScreenImageSmallSizeOutScreen];
                    [self setupReportScreenIpadImageEndPosition];
                    [self setupReportScreenIphoneImageEndPosition];
                }];
            } else {
                [UIView animateWithDuration:kDefaultAnimationDuration animations:^{
                    [self setupServerScreenImageStartPosition];
                    [self setupReportScreenIpadImageEndPosition];
                    [self setupReportScreenIphoneImageEndPosition];
                }];
            }
        }
    } else {
        // move up

        if (reportScreenIpadImageOrigin.x < reportScreenIpadImageBeginUpdateOriginX || velocityY > 500) {
            // move to next page
            [UIView animateWithDuration:kDefaultAnimationDuration animations:^{
                [self setupServerScreenImageFullSizePosition];
                [self setupReportScreenIphoneImageStartPosition];
                [self setupReportScreenIpadImageStartPosition];
            } completion:^(BOOL finished) {
                // titles
                JMIntroModel *model = [self.modelManager modelAtIndex:2];
                self.titlePageLabel.text = model.pageTitle;
                self.descriptionPageLabel.text = model.pageDescription;

                [self setButtonTitle:@"Start using JasperMobile"];
                // now page is
                self.introPage = JMOnboardIntroPageSeemlessIntegration;
            }];
        } else {
            // restore current page
            if (self.isUnderRedLine) {
                [UIView animateWithDuration:kDefaultAnimationDuration animations:^{
                    [self setupHomeScreenImageSmallSizeOutScreen];
                    [self setupReportScreenIpadImageEndPosition];
                    [self setupReportScreenIphoneImageEndPosition];
                }];
            } else {
                [UIView animateWithDuration:kDefaultAnimationDuration animations:^{
                    [self setupServerScreenImageStartPosition];
                    [self setupReportScreenIpadImageEndPosition];
                    [self setupReportScreenIphoneImageEndPosition];
                }];
            }
        }
    }
}

#pragma mark - Seemless Integration Page
- (void)changeSeemlessIntegrationPageViewsWithVelocity:(CGPoint)velocity {
    CGPoint serverScreenImageOrigin = self.serverScreenImage.frame.origin;
    CGSize serverScreenImageSize = self.serverScreenImage.frame.size;
    CGFloat serverScreenImageStartOriginY = 10;
    CGFloat serverScreenImageUpperValueOriginY = 5;
    CGFloat serverScreenImageBeginUpdateOriginY = 100;
    CGFloat serverScreenImageBottomValueOriginY = 120;

    if (velocity.y > 0) {
        // move down
        if (serverScreenImageOrigin.y == serverScreenImageStartOriginY ) {
            self.isUnderRedLine = YES;
        }

        if (self.isUnderRedLine) {
            if (serverScreenImageOrigin.y < serverScreenImageBottomValueOriginY) {
                CGFloat newOriginX = self.view.bounds.size.width / 2 - serverScreenImageSize.width / 2;
                CGFloat newOriginY = serverScreenImageOrigin.y + kDefaultStepValue;
                CGPoint newOrigin = CGPointMake(newOriginX, newOriginY);

                CGFloat newHeight = serverScreenImageSize.height - kDefaultStepValue * (serverScreenImageSize.height / serverScreenImageSize.width) - 1;
                CGFloat newWidth = serverScreenImageSize.width - kDefaultStepValue - 0.5f;
                CGSize newSize = CGSizeMake(newWidth, newHeight);
                [self.serverScreenImage updateFrameWithOrigin:newOrigin
                                                         size:newSize];

                // start showing ipad image
                [self.reportScreenIpadImage updateOriginXWithValue:(self.reportScreenIpadImage.frame.origin.x + kDefaultStepValue)];
                // start showing iphone image
                [self.reportScreenIphoneImage updateOriginXWithValue:(self.reportScreenIphoneImage.frame.origin.x - kDefaultStepValue)];

                if (serverScreenImageOrigin.y == serverScreenImageBeginUpdateOriginY) {
                    // previous page title
                    JMIntroModel *model = [self.modelManager modelAtIndex:1];
                    self.titlePageLabel.text = model.pageTitle;
                    self.descriptionPageLabel.text = model.pageDescription;
                }
            }
        } else {
            [self.serverScreenImage updateOriginYWithValue:(serverScreenImageOrigin.y + kDefaultStepValue)];
        }
    } else {
        // move up

        if (serverScreenImageOrigin.y == serverScreenImageStartOriginY ) {
            self.isUnderRedLine = NO;
        }

        if (self.isUnderRedLine) {
            CGFloat newOriginX = self.view.bounds.size.width / 2 - serverScreenImageSize.width / 2;
            CGFloat newOriginY = serverScreenImageOrigin.y - kDefaultStepValue;
            CGPoint newOrigin = CGPointMake(newOriginX, newOriginY);

            CGFloat newHeight = serverScreenImageSize.height + kDefaultStepValue * (serverScreenImageSize.height / serverScreenImageSize.width);
            CGFloat newWidth = serverScreenImageSize.width + kDefaultStepValue - 0.5f;
            CGSize newSize = CGSizeMake(newWidth, newHeight);
            [self.serverScreenImage updateFrameWithOrigin:newOrigin
                                                     size:newSize];

            // start hiding ipad image
            [self.reportScreenIpadImage updateOriginXWithValue:(self.reportScreenIpadImage.frame.origin.x - kDefaultStepValue)];
            // start hiding iphone image
            [self.reportScreenIphoneImage updateOriginXWithValue:(self.reportScreenIphoneImage.frame.origin.x + kDefaultStepValue)];

            if (serverScreenImageOrigin.y == serverScreenImageBeginUpdateOriginY) {
                // current page title
                JMIntroModel *model = [self.modelManager modelAtIndex:2];
                self.titlePageLabel.text = model.pageTitle;
                self.descriptionPageLabel.text = model.pageDescription;
            }
        } else {
            if (serverScreenImageOrigin.y > serverScreenImageUpperValueOriginY) {
                [self.serverScreenImage updateOriginYWithValue:(serverScreenImageOrigin.y - kDefaultStepValue)];
            }
        }

    }
}

- (void)updateSeemlessIntegrationViewsPageWithVelocity:(CGPoint)velocity {
    CGFloat velocityY = fabsf(velocity.y);
    CGFloat serverScreenImageBeginUpdateOriginY = 70;

    if (velocity.y > 0) {
        // move down

        if (self.serverScreenImage.frame.origin.y > serverScreenImageBeginUpdateOriginY || velocityY > 500) {
            [UIView animateWithDuration:kDefaultAnimationDuration animations:^{
                [self setupServerScreenImageStartPosition];
                [self setupReportScreenIpadImageEndPosition];
                [self setupReportScreenIphoneImageEndPosition];
            } completion:^(BOOL finished) {
                // titles
                JMIntroModel *model = [self.modelManager modelAtIndex:1];
                self.titlePageLabel.text = model.pageTitle;
                self.descriptionPageLabel.text = model.pageDescription;

                [self setButtonTitle:@"Skip Intro"];
                self.introPage = JMOnboardIntroPageInstanceAccess;
            }];
        } else {
            // restore current state
            [UIView animateWithDuration:kDefaultAnimationDuration animations:^{
                [self setupServerScreenImageFullSizePosition];
                [self setupReportScreenIphoneImageStartPosition];
                [self setupReportScreenIpadImageStartPosition];
            }];
        }

    } else {
        // move up

        [UIView animateWithDuration:kDefaultAnimationDuration animations:^{
            [self setupServerScreenImageFullSizePosition];
            [self setupReportScreenIphoneImageStartPosition];
            [self setupReportScreenIpadImageStartPosition];
        }];
    }
}


@end
