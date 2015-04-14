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
//  JMOnboardIntroViewController.h
//  TIBCO JasperMobile
//


#import "JMOnboardIntroViewController.h"
#import "UIView+Additions.h"
#import "JMIntroModelManager.h"
#import "JMIntroModel.h"
#import "JMIntroImageView.h"

typedef NS_ENUM(NSInteger, JMOnboardIntroPage) {
    JMOnboardIntroPageWelcome,
    JMOnboardIntroPageStayConnected,
    JMOnboardIntroPageInstanceAccess,
    JMOnboardIntroPageSeemlessIntegration
};

static const CGFloat kDefaultAnimationDuration = 0.4f;
static const CGFloat kDefaultStepValue = 1.0f;
static const CGFloat kDefaultMinVelocity = 500.0f;
static const CGFloat kTopPadding = 10.0f;
static const CGFloat kImageScaleFactor = 5.0f;

static NSString * const kPageIdentifierStartPage = @"kPageIdentifierStartPage";
static NSString * const kPageIdentifierStayConnected = @"kPageIdentifierStayConnected";
static NSString * const kPageIdentifierInstanceAccess = @"kPageIdentifierInstanceAccess";
static NSString * const kPageIdentifierSeemlessIntegration = @"kPageIdentifierSeemlessIntegration";

@interface JMOnboardIntroViewController ()
@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *welcomeView;
@property (weak, nonatomic) IBOutlet UIView *messageView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet JMIntroImageView *homeScreenImage;
@property (weak, nonatomic) IBOutlet JMIntroImageView *reportScreenIphoneImage;
@property (weak, nonatomic) IBOutlet JMIntroImageView *reportScreenIpadImage;
@property (weak, nonatomic) IBOutlet JMIntroImageView *serverScreenImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
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

#pragma mark - UIViewController LifeCycle
- (void)awakeFromNib {
    [super awakeFromNib];

    self.introPage = JMOnboardIntroPageWelcome;
    self.modelManager = [JMIntroModelManager new];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self addGestureRecognizer];

    [self setButtonTitle:JMCustomLocalizedString(@"intro.button.skip.skip", nil)];
    self.titleLabel.text = JMCustomLocalizedString(@"intro.title", nil);
    self.descriptionLabel.text = JMCustomLocalizedString(@"intro.description", nil);

    [self setupImages];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}

#pragma mark - Rotation
- (BOOL)shouldAutorotate
{
    return ![JMUtils isIphone];
}

-(NSUInteger)supportedInterfaceOrientations
{
    return [JMUtils isIphone] ? UIInterfaceOrientationMaskPortrait : UIInterfaceOrientationMaskAll;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self setupImagesFrames];
    [self forwardToPage:self.introPage animation:YES];
}

#pragma mark - Setup
- (void)setupImages
{
    [self setupImagesFrames];

    [self setupTitleViewStartPosition];
    [self setupContentViewStartPosition];
    [self setupStartPositions];
}

- (void)setupImagesFrames
{
    [self setupHomeScreenImageFrames];
    [self setupServerScreenImageFrames];

    [self setupReportScreenIpadImageFrames];
    [self setupReportScreenIphoneImageFrames];
}

- (void)setupHomeScreenImageFrames
{
    CGFloat homeScreenImageWidth = self.homeScreenImage.image.size.width;
    CGFloat homeScreenImageHeight = self.homeScreenImage.image.size.height;

    CGRect imageFrame = CGRectZero;

    // origin image
    CGFloat contentViewWidth = CGRectGetWidth(self.contentView.frame);
    imageFrame.origin.x = contentViewWidth/2 - homeScreenImageWidth/2;
    imageFrame.origin.y = kTopPadding;
    imageFrame.size = self.homeScreenImage.image.size;
    imageFrame = CGRectIntegral(imageFrame);

    [self.homeScreenImage setImageFrame:imageFrame forPageIdentifier:kPageIdentifierStartPage];
    [self.homeScreenImage setImageFrame:imageFrame forPageIdentifier:kPageIdentifierStayConnected];

    // small image under bottom of screen
    imageFrame.origin.x = contentViewWidth/2 - homeScreenImageWidth/(2*kImageScaleFactor);
    imageFrame.origin.y = CGRectGetMinY(self.bottomView.frame);
    imageFrame.size = CGSizeMake(homeScreenImageWidth/kImageScaleFactor, homeScreenImageHeight/kImageScaleFactor);
    imageFrame = CGRectIntegral(imageFrame);

    [self.homeScreenImage setImageFrame:imageFrame forPageIdentifier:kPageIdentifierInstanceAccess];
    [self.homeScreenImage setImageFrame:imageFrame forPageIdentifier:kPageIdentifierSeemlessIntegration];
}

- (void)setupServerScreenImageFrames
{
    CGFloat serverScreenImageWidth = self.serverScreenImage.image.size.width;
    CGFloat serverScreenImageHeight = self.serverScreenImage.image.size.height;

    CGRect imageFrame = CGRectZero;

    // small image under bottom of screen
    CGFloat mainViewWidth = CGRectGetWidth(self.contentView.frame);
    CGFloat newOriginX = mainViewWidth/2 - serverScreenImageWidth/(2*kImageScaleFactor);
    CGFloat newOriginY = CGRectGetMinY(self.bottomView.frame);

    imageFrame.origin = CGPointMake(newOriginX, newOriginY);
    imageFrame.size = CGSizeMake(serverScreenImageWidth/kImageScaleFactor, serverScreenImageHeight/kImageScaleFactor);
    imageFrame = CGRectIntegral(imageFrame);

    [self.serverScreenImage setImageFrame:imageFrame forPageIdentifier:kPageIdentifierStartPage];
    [self.serverScreenImage setImageFrame:imageFrame forPageIdentifier:kPageIdentifierStayConnected];
    [self.serverScreenImage setImageFrame:imageFrame forPageIdentifier:kPageIdentifierInstanceAccess];

    // origin image
    newOriginX = mainViewWidth/2 - serverScreenImageWidth/2;
    newOriginY = kTopPadding;

    imageFrame.origin = CGPointMake(newOriginX, newOriginY);
    imageFrame.size = self.serverScreenImage.image.size;
    imageFrame = CGRectIntegral(imageFrame);

    [self.serverScreenImage setImageFrame:imageFrame forPageIdentifier:kPageIdentifierSeemlessIntegration];
}

- (void)setupReportScreenIpadImageFrames
{
    CGFloat reportScreenIpadImageWidth = self.reportScreenIpadImage.image.size.width;

    CGRect imageFrame = CGRectZero;
    imageFrame.size = self.reportScreenIpadImage.image.size;

    // start position - behind left side of content view
    imageFrame.origin.x = -reportScreenIpadImageWidth;
    imageFrame.origin.y = 0;
    imageFrame = CGRectIntegral(imageFrame);

    [self.reportScreenIpadImage setImageFrame:imageFrame forPageIdentifier:kPageIdentifierStartPage];
    [self.reportScreenIpadImage setImageFrame:imageFrame forPageIdentifier:kPageIdentifierStayConnected];
    [self.reportScreenIpadImage setImageFrame:imageFrame forPageIdentifier:kPageIdentifierSeemlessIntegration];

    // visible position
    imageFrame.origin.x = CGRectGetWidth(self.contentView.frame)/2 - reportScreenIpadImageWidth/2;
    imageFrame.origin.y = 0;
    imageFrame = CGRectIntegral(imageFrame);

    [self.reportScreenIpadImage setImageFrame:imageFrame forPageIdentifier:kPageIdentifierInstanceAccess];
}

- (void)setupReportScreenIphoneImageFrames
{
    CGFloat reportScreenIphoneImageWidth = self.reportScreenIphoneImage.image.size.width;
    CGFloat reportScreenIphoneImageHeight = self.reportScreenIphoneImage.image.size.height;

    CGFloat ipadImageHeigth = self.reportScreenIpadImage.image.size.height;
    CGFloat ipadImageWidth = self.reportScreenIpadImage.image.size.width;

    CGRect imageFrame = CGRectZero;
    imageFrame.size = self.reportScreenIphoneImage.image.size;

    // start position - behind right side of content view
    CGFloat newOriginY = ipadImageHeigth - reportScreenIphoneImageHeight * 3/4;
    CGFloat contentViewWidth = CGRectGetWidth(self.contentView.frame);
    CGFloat newOriginX = contentViewWidth;
    imageFrame.origin = CGPointMake(newOriginX, newOriginY);
    imageFrame = CGRectIntegral(imageFrame);

    [self.reportScreenIphoneImage setImageFrame:imageFrame forPageIdentifier:kPageIdentifierStartPage];
    [self.reportScreenIphoneImage setImageFrame:imageFrame forPageIdentifier:kPageIdentifierStayConnected];
    [self.reportScreenIphoneImage setImageFrame:imageFrame forPageIdentifier:kPageIdentifierSeemlessIntegration];

    // visible position
    newOriginX = contentViewWidth/2 + ipadImageWidth/2 - reportScreenIphoneImageWidth * 3/4;
    imageFrame.origin = CGPointMake(newOriginX, newOriginY);
    imageFrame = CGRectIntegral(imageFrame);

    [self.reportScreenIphoneImage setImageFrame:imageFrame forPageIdentifier:kPageIdentifierInstanceAccess];
}

- (void)setupStartPositions
{
    [self.homeScreenImage updateFrameForPageWithIdentifier:kPageIdentifierStartPage];

    [self.reportScreenIphoneImage updateFrameForPageWithIdentifier:kPageIdentifierStartPage];
    self.reportScreenIphoneImage.hidden = YES;

    [self.reportScreenIpadImage updateFrameForPageWithIdentifier:kPageIdentifierStartPage];
    self.reportScreenIpadImage.hidden = YES;

    [self.serverScreenImage updateFrameForPageWithIdentifier:kPageIdentifierStartPage];
    self.serverScreenImage.hidden = YES;
}


#pragma mark - Actions
- (IBAction)skipAction:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Setup
- (void)setupTitleViewStartPosition
{
    CGFloat newHeight = CGRectGetHeight(self.welcomeView.frame);
    [self.titleView updateHeightWithValue:newHeight];
}

- (void)setupTitleViewEndPosition
{
    CGFloat newHeight = CGRectGetHeight(self.messageView.frame);
    [self.titleView updateHeightWithValue:newHeight];
}

- (void)setupContentViewStartPosition
{
    CGFloat contentViewStartHeight;
    if ([JMUtils isIphone]) {
        contentViewStartHeight = 290;
    } else {
        contentViewStartHeight = 610;
    }
    [self.contentView updateOriginYWithValue:contentViewStartHeight];
}

- (void)setupContentViewEndPosition
{
    CGFloat titleViewHeight = CGRectGetHeight(self.titleView.frame);
    [self.contentView updateOriginWithOrigin:CGPointMake(0, titleViewHeight)];
}

#pragma mark - Animations
- (void)forwardToPage:(JMOnboardIntroPage)introPage animation:(BOOL)shouldAnimate
{
    CGFloat animationDuration = shouldAnimate ? kDefaultAnimationDuration : 0;

    switch (introPage) {
        case JMOnboardIntroPageWelcome: {
            // make visible images
            self.homeScreenImage.hidden = NO;

            [UIView animateWithDuration:animationDuration animations:^{
                [self setupTitleViewStartPosition];
                [self setupContentViewStartPosition];
                [self.homeScreenImage updateFrameForPageWithIdentifier:kPageIdentifierStayConnected];
            } completion:^(BOOL finished) {
                self.welcomeView.hidden = NO;
                self.messageView.hidden = YES;
                // now page is
                self.introPage = JMOnboardIntroPageWelcome;

                // make hidden images
                [self hideImagesForIntroPage:introPage];
            }];
            break;
        }
        case JMOnboardIntroPageStayConnected: {
            // make visible images
            self.homeScreenImage.hidden = NO;

            [UIView animateWithDuration:animationDuration animations:^{
                [self setupTitleViewEndPosition];
                [self setupContentViewEndPosition];
                [self.homeScreenImage updateFrameForPageWithIdentifier:kPageIdentifierStayConnected];
                [self.reportScreenIphoneImage updateFrameForPageWithIdentifier:kPageIdentifierStayConnected];
                [self.reportScreenIpadImage updateFrameForPageWithIdentifier:kPageIdentifierStayConnected];
            } completion:^(BOOL finished) {
                self.welcomeView.hidden = YES;
                self.messageView.hidden = NO;
                // now page is
                self.introPage = JMOnboardIntroPageStayConnected;
                [self setButtonTitle:JMCustomLocalizedString(@"intro.button.skip.skip", nil)];

                JMIntroModel *model = [self.modelManager modelAtIndex:0];
                self.titlePageLabel.text = model.pageTitle;
                self.descriptionPageLabel.text = model.pageDescription;

                // make hidden images
                [self hideImagesForIntroPage:introPage];
            }];
            break;
        }
        case JMOnboardIntroPageInstanceAccess: {
            // make visible images
            self.reportScreenIpadImage.hidden = NO;
            self.reportScreenIphoneImage.hidden = NO;

            [UIView animateWithDuration:animationDuration animations:^{
                [self.homeScreenImage updateFrameForPageWithIdentifier:kPageIdentifierInstanceAccess];
                [self.reportScreenIphoneImage updateFrameForPageWithIdentifier:kPageIdentifierInstanceAccess];
                [self.reportScreenIpadImage updateFrameForPageWithIdentifier:kPageIdentifierInstanceAccess];
                [self.serverScreenImage updateFrameForPageWithIdentifier:kPageIdentifierInstanceAccess];
            } completion:^(BOOL finished) {
                // now page is
                self.introPage = JMOnboardIntroPageInstanceAccess;
                [self setButtonTitle:JMCustomLocalizedString(@"intro.button.skip.skip", nil)];

                JMIntroModel *model = [self.modelManager modelAtIndex:1];
                self.titlePageLabel.text = model.pageTitle;
                self.descriptionPageLabel.text = model.pageDescription;

                // make hidden images
                [self hideImagesForIntroPage:introPage];
            }];

            break;
        }
        case JMOnboardIntroPageSeemlessIntegration: {
            // make visible images
            self.serverScreenImage.hidden = NO;

            [UIView animateWithDuration:animationDuration animations:^{
                [self.serverScreenImage updateFrameForPageWithIdentifier:kPageIdentifierSeemlessIntegration];
                [self.reportScreenIphoneImage updateFrameForPageWithIdentifier:kPageIdentifierSeemlessIntegration];
                [self.reportScreenIpadImage updateFrameForPageWithIdentifier:kPageIdentifierSeemlessIntegration];
            } completion:^(BOOL finished) {
                // now page is
                self.introPage = JMOnboardIntroPageSeemlessIntegration;
                [self setButtonTitle:JMCustomLocalizedString(@"intro.button.skip.startUsing", nil)];

                JMIntroModel *model = [self.modelManager modelAtIndex:2];
                self.titlePageLabel.text = model.pageTitle;
                self.descriptionPageLabel.text = model.pageDescription;

                // make hidden images
                [self hideImagesForIntroPage:introPage];
            }];
            break;
        }
    }
}

- (void)backToPage:(JMOnboardIntroPage)introPage animation:(BOOL)shouldAnimate {
    CGFloat animationDuration = shouldAnimate ? kDefaultAnimationDuration : 0;

    switch (introPage) {
        case JMOnboardIntroPageWelcome : {
            // make visible images
            self.homeScreenImage.hidden = NO;
            self.serverScreenImage.hidden = YES;
            self.reportScreenIpadImage.hidden = YES;
            self.reportScreenIphoneImage.hidden = YES;

            [UIView animateWithDuration:animationDuration animations:^{
                [self setupContentViewStartPosition];
            } completion:^(BOOL finished) {
                [self hideImagesForIntroPage:introPage];
            }];
            break;
        }
        case JMOnboardIntroPageStayConnected : {
            // make visible images
            self.homeScreenImage.hidden = NO;
            self.serverScreenImage.hidden = YES;
            self.reportScreenIpadImage.hidden = NO;
            self.reportScreenIphoneImage.hidden = NO;

            [UIView animateWithDuration:animationDuration animations:^{
                [self.homeScreenImage updateFrameForPageWithIdentifier:kPageIdentifierStayConnected];
                [self.reportScreenIphoneImage updateFrameForPageWithIdentifier:kPageIdentifierStayConnected];
                [self.reportScreenIpadImage updateFrameForPageWithIdentifier:kPageIdentifierStayConnected];
            } completion:^(BOOL finished) {
                [self hideImagesForIntroPage:introPage];
            }];
            break;
        }
        case JMOnboardIntroPageInstanceAccess : {
            // make visible images
            self.homeScreenImage.hidden = NO;
            self.serverScreenImage.hidden = NO;
            self.reportScreenIpadImage.hidden = NO;
            self.reportScreenIphoneImage.hidden = NO;

            [UIView animateWithDuration:animationDuration animations:^{
                [self.homeScreenImage updateFrameForPageWithIdentifier:kPageIdentifierInstanceAccess];
                [self.reportScreenIpadImage updateFrameForPageWithIdentifier:kPageIdentifierInstanceAccess];
                [self.reportScreenIphoneImage updateFrameForPageWithIdentifier:kPageIdentifierInstanceAccess];
                [self.serverScreenImage updateFrameForPageWithIdentifier:kPageIdentifierInstanceAccess];
            } completion:^(BOOL finished) {
                [self hideImagesForIntroPage:introPage];
            }];
            break;
        }
        case JMOnboardIntroPageSeemlessIntegration : {
            // make visible images
            self.homeScreenImage.hidden = YES;
            self.serverScreenImage.hidden = NO;
            self.reportScreenIpadImage.hidden = NO;
            self.reportScreenIphoneImage.hidden = NO;

            [UIView animateWithDuration:animationDuration animations:^{
                [self.reportScreenIpadImage updateFrameForPageWithIdentifier:kPageIdentifierSeemlessIntegration];
                [self.reportScreenIphoneImage updateFrameForPageWithIdentifier:kPageIdentifierSeemlessIntegration];
                [self.serverScreenImage updateFrameForPageWithIdentifier:kPageIdentifierSeemlessIntegration];
            } completion:^(BOOL finished) {
                [self hideImagesForIntroPage:introPage];
            }];
            break;
        }
    }
}

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
        [self forwardToPage:JMOnboardIntroPageStayConnected animation:YES];
    } else if (self.introPage == JMOnboardIntroPageStayConnected) {
        [self forwardToPage:JMOnboardIntroPageInstanceAccess animation:YES];
    } else if (self.introPage == JMOnboardIntroPageInstanceAccess) {
        [self forwardToPage:JMOnboardIntroPageSeemlessIntegration animation:YES];
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer {

    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        // start point
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint velocity = [gestureRecognizer velocityInView:self.view];
        switch (self.introPage) {
            case JMOnboardIntroPageWelcome : {
                // make visible images
                self.homeScreenImage.hidden = NO;
                self.serverScreenImage.hidden = YES;
                self.reportScreenIpadImage.hidden = YES;
                self.reportScreenIphoneImage.hidden = YES;

                [self changeWelcomePageViewsWithVelocity:velocity];
                break;
            }
            case JMOnboardIntroPageStayConnected : {
                // make visible images
                self.homeScreenImage.hidden = NO;
                self.serverScreenImage.hidden = YES;
                self.reportScreenIpadImage.hidden = NO;
                self.reportScreenIphoneImage.hidden = NO;

                [self changeStayConnectedViewsWithVelocity:velocity];
                break;
            }
            case JMOnboardIntroPageInstanceAccess : {
                // make visible images
                self.homeScreenImage.hidden = YES;
                self.serverScreenImage.hidden = NO;
                self.reportScreenIpadImage.hidden = NO;
                self.reportScreenIphoneImage.hidden = NO;

                [self changeInstanceAccessViewsWithVelocity:velocity];
                break;
            }
            case JMOnboardIntroPageSeemlessIntegration : {
                // make visible images
                self.homeScreenImage.hidden = YES;
                self.serverScreenImage.hidden = NO;
                self.reportScreenIpadImage.hidden = NO;
                self.reportScreenIphoneImage.hidden = NO;

                [self changeSeemlessIntegrationPageViewsWithVelocity:velocity];
                break;
            }
        }
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint velocity = [gestureRecognizer velocityInView:self.view];

        [self hideImagesForIntroPage:self.introPage];

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
- (void)hideImagesForIntroPage:(JMOnboardIntroPage)introPage
{
    switch (introPage) {
        case JMOnboardIntroPageWelcome: {
            self.homeScreenImage.hidden = NO;
            self.reportScreenIpadImage.hidden = YES;
            self.reportScreenIphoneImage.hidden = YES;
            self.serverScreenImage.hidden = YES;
            break;
        };
        case JMOnboardIntroPageStayConnected: {
            self.homeScreenImage.hidden = NO;
            self.reportScreenIpadImage.hidden = YES;
            self.reportScreenIphoneImage.hidden = YES;
            self.serverScreenImage.hidden = YES;
            break;
        };
        case JMOnboardIntroPageInstanceAccess: {
            self.homeScreenImage.hidden = YES;
            self.reportScreenIpadImage.hidden = NO;
            self.reportScreenIphoneImage.hidden = NO;
            self.serverScreenImage.hidden = YES;
            break;
        };
        case JMOnboardIntroPageSeemlessIntegration: {
            self.homeScreenImage.hidden = YES;
            self.reportScreenIpadImage.hidden = YES;
            self.reportScreenIphoneImage.hidden = YES;
            self.serverScreenImage.hidden = NO;
            break;
        };
    }
}

- (void)setButtonTitle:(NSString *)buttonTitle {
    [self.skipButton setTitle:buttonTitle forState:UIControlStateNormal];
}


#pragma mark - Welcome Page
- (void)changeWelcomePageViewsWithVelocity:(CGPoint)velocity {
    CGPoint contentViewOrigin = self.contentView.frame.origin;

    CGFloat contentViewStartHeight;
    if ([JMUtils isIphone]) {
        contentViewStartHeight = 290;
    } else {
        contentViewStartHeight = 610;
    }

    CGFloat contentViewStartOriginY = contentViewStartHeight;
    CGFloat contentViewBeginUpdateOriginY = contentViewStartOriginY * 0.8f;
    CGFloat contentViewUpperValueOriginY = contentViewStartOriginY * 0.7f;
    CGFloat contentViewBottomValueOriginY = contentViewStartOriginY * 1.2f;

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
            if (contentViewOrigin.y <= contentViewBeginUpdateOriginY) {
                // update title view
                self.welcomeView.hidden = NO;
                self.messageView.hidden = YES;
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
                if (contentViewOrigin.y <= contentViewBeginUpdateOriginY) {
                    // update title view
                    self.welcomeView.hidden = YES;
                    self.messageView.hidden = NO;

                    JMIntroModel *model = [self.modelManager modelAtIndex:0];
                    self.titlePageLabel.text = model.pageTitle;
                    self.descriptionPageLabel.text = model.pageDescription;
                }
            }
        }
    }
}

- (void)updateWelcomePageViewsWithVelocity:(CGPoint)velocity {
    CGFloat velocityY = fabs(velocity.y);
    CGPoint contentViewOrigin = self.contentView.frame.origin;

    CGFloat contentViewStartHeight;
    if ([JMUtils isIphone]) {
        contentViewStartHeight = 290;
    } else {
        contentViewStartHeight = 610;
    }

    CGFloat contentViewStartOriginY = contentViewStartHeight;
    CGFloat contentViewBeginUpdateOriginY = contentViewStartOriginY * 0.8f;

    if (velocity.y > 0) {
        // move down
        if (contentViewOrigin.y == contentViewStartOriginY) {
            self.isUnderRedLine = YES;
        }

        // restore previous state
        [self backToPage:JMOnboardIntroPageWelcome animation:YES];
    } else {
        // move up
        if (contentViewOrigin.y == contentViewStartOriginY) {
            self.isUnderRedLine = NO;
        }

        if (self.contentView.frame.origin.y < contentViewBeginUpdateOriginY || (!self.isUnderRedLine && velocityY > kDefaultMinVelocity) ) {
            // move to next page
            [self forwardToPage:JMOnboardIntroPageStayConnected animation:YES];
        } else {
            // restore previous state
            [self backToPage:JMOnboardIntroPageWelcome animation:YES];
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

    if (velocity.y > 0) { // move down

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
    } else { // move up

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
    CGFloat velocityY = fabs(velocity.y);

    CGPoint homeScreenImageOrigin = self.homeScreenImage.frame.origin;
    CGFloat homeScreenImageStartOriginY = 10;
    CGFloat homeScreenImageBeginUpdateOriginY = 70;

    if (velocity.y > 0) {
        // move down
        if (homeScreenImageOrigin.y == homeScreenImageStartOriginY ) {
            self.isUnderRedLine = YES;
        }

        if (self.homeScreenImage.frame.origin.y > homeScreenImageBeginUpdateOriginY || (self.isUnderRedLine && velocityY > kDefaultMinVelocity) ) {
            // move to previous page
            [self forwardToPage:JMOnboardIntroPageWelcome animation:YES];
        } else {
            // restore current state
            [self backToPage:JMOnboardIntroPageStayConnected animation:YES];
        }
    } else {
        // move up
        if (homeScreenImageOrigin.y == homeScreenImageStartOriginY) {
            self.isUnderRedLine = NO;
        }

        if (self.homeScreenImage.frame.origin.y > homeScreenImageBeginUpdateOriginY || (!self.isUnderRedLine && velocityY > kDefaultMinVelocity) ) {
            // move to next page
            [self forwardToPage:JMOnboardIntroPageInstanceAccess animation:YES];
        } else {
            // restore current state
            [self backToPage:JMOnboardIntroPageStayConnected animation:YES];
        }
    }
}

#pragma mark - Instance Access Page

- (void)changeInstanceAccessViewsWithVelocity:(CGPoint)velocity {
    CGPoint reportScreenIpadImageOrigin = self.reportScreenIpadImage.frame.origin;
    CGFloat reportScreenIpadImageFrameOriginX = self.contentView.frame.size.width/2 - self.reportScreenIpadImage.frame.size.width/2;
    CGFloat reportScreenIpadImageBeginUpdateOriginX = 20;
    CGFloat reportScreenIpadImageBottomValueOriginX = 0;

    if (velocity.y > 0) { // move down

        if (reportScreenIpadImageOrigin.x == reportScreenIpadImageFrameOriginX) {
            self.isUnderRedLine = YES;
        }

        if (self.isUnderRedLine) {
            if (reportScreenIpadImageOrigin.x > reportScreenIpadImageBottomValueOriginX) {
                [self.homeScreenImage updateOriginYWithValue:(self.homeScreenImage.frame.origin.y - kDefaultStepValue)];
                // start hiding ipad image
                [self.reportScreenIpadImage updateOriginXWithValue:(self.reportScreenIpadImage.frame.origin.x + kDefaultStepValue)];
                // start hiding iphone image
                [self.reportScreenIphoneImage updateOriginXWithValue:(self.reportScreenIphoneImage.frame.origin.x - kDefaultStepValue)];
            }
        } else {
            [self.serverScreenImage updateOriginYWithValue:(self.serverScreenImage.frame.origin.y + kDefaultStepValue)];
            // start hiding ipad image
            [self.reportScreenIpadImage updateOriginXWithValue:(self.reportScreenIpadImage.frame.origin.x - kDefaultStepValue)];
            // start hiding iphone image
            [self.reportScreenIphoneImage updateOriginXWithValue:(self.reportScreenIphoneImage.frame.origin.x + kDefaultStepValue)];

            if (reportScreenIpadImageOrigin.x == reportScreenIpadImageBeginUpdateOriginX) {
                // current page title
                JMIntroModel *model = [self.modelManager modelAtIndex:1];
                self.titlePageLabel.text = model.pageTitle;
                self.descriptionPageLabel.text = model.pageDescription;
            }
        }
    } else { // move up

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
    CGFloat velocityY = fabs(velocity.y);

    CGPoint reportScreenIpadImageOrigin = self.reportScreenIpadImage.frame.origin;
    CGFloat reportScreenIpadImageBeginUpdateOriginX = 20;

    if (velocity.y > 0) { // move down

        if ( (velocityY > kDefaultMinVelocity) || reportScreenIpadImageOrigin.x < reportScreenIpadImageBeginUpdateOriginX ) {
            // move to previous page
            [self forwardToPage:JMOnboardIntroPageStayConnected animation:YES];
        } else {
            // restore current page
            [self backToPage:JMOnboardIntroPageInstanceAccess animation:YES];
        }
    } else { // move up

        if ( (velocityY > kDefaultMinVelocity) || reportScreenIpadImageOrigin.x < reportScreenIpadImageBeginUpdateOriginX ) {
            // move to next page
            [self forwardToPage:JMOnboardIntroPageSeemlessIntegration animation:YES];
        } else {
            // restore current page
            [self backToPage:JMOnboardIntroPageInstanceAccess animation:YES];
        }
    }
}

#pragma mark - Seemless Integration Page
- (void)changeSeemlessIntegrationPageViewsWithVelocity:(CGPoint)velocity {
    CGPoint serverScreenImageOrigin = self.serverScreenImage.frame.origin;
    CGSize serverScreenImageSize = self.serverScreenImage.frame.size;
    CGFloat mainViewWidth = CGRectGetWidth([UIApplication sharedApplication].keyWindow.bounds);
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
                CGFloat newOriginX = mainViewWidth / 2 - serverScreenImageSize.width / 2;
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
            CGFloat newOriginX = mainViewWidth / 2 - serverScreenImageSize.width / 2;
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
    CGFloat velocityY = fabs(velocity.y);

    CGPoint serverScreenImageOrigin = self.serverScreenImage.frame.origin;
    CGFloat serverScreenImageStartOriginY = 10;
    CGFloat serverScreenImageBeginUpdateOriginY = 100;

    if (velocity.y > 0) {
        // move down
        if (serverScreenImageOrigin.y == serverScreenImageStartOriginY ) {
            self.isUnderRedLine = YES;
        }

        if (self.serverScreenImage.frame.origin.y > serverScreenImageBeginUpdateOriginY || (self.isUnderRedLine && velocityY > kDefaultMinVelocity) ) {
            [self forwardToPage:JMOnboardIntroPageInstanceAccess animation:YES];
        } else {
            // restore current state
            [self backToPage:JMOnboardIntroPageSeemlessIntegration animation:YES];
        }
    } else {
        // move up
        if (serverScreenImageOrigin.y == serverScreenImageStartOriginY ) {
            self.isUnderRedLine = NO;
        }

        [self backToPage:JMOnboardIntroPageSeemlessIntegration animation:YES];
    }
}


@end
