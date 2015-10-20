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
//  JMOnboardIntroViewController.h
//  TIBCO JasperMobile
//


#import "JMOnboardIntroViewController.h"
#import "UIView+Additions.h"
#import "JMIntroModelManager.h"
#import "JMIntroModel.h"
#import "JMIntroImageView.h"

static const CGFloat kDefaultAnimationDuration = 0.4f;
static const CGFloat kDefaultStepValue = 1.0f;
static const CGFloat kDefaultMinVelocity = 500.0f;

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
// constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *homeScreenImageTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *reportScreenIpadCenterXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *reportScreenIphoneCenterXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *reportScreenIphoneTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *reportScreenIpadTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *serverScreenImageTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleViewTopConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *homeScreenImageHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *homeScreenImageWidthConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *serverScreenImageHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *serverScreenImageWidthConstraint;

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
    
    [self setButtonTitleForPage:self.introPage];
    self.titleLabel.text = JMCustomLocalizedString(@"intro.title", nil);
    self.descriptionLabel.text = JMCustomLocalizedString(@"intro.description", nil);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self setupImages];
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

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return [JMUtils isIphone] ? UIInterfaceOrientationMaskPortrait : UIInterfaceOrientationMaskAll;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self forwardToPage:self.introPage animation:YES];
}

#pragma mark - Setup
- (void)setupImages
{
    self.serverScreenImage.hidden = YES;
    self.reportScreenIpadImage.hidden = YES;
    self.reportScreenIphoneImage.hidden = YES;

    [self setupStartPositions];
}

- (void)setupStartPositions
{
    // home screen
    self.homeScreenImageHeightConstraint.constant = self.homeScreenImage.image.size.height;
    self.homeScreenImageWidthConstraint.constant = self.homeScreenImage.image.size.width;

    // server screen
    self.serverScreenImageHeightConstraint.constant = (CGFloat) (self.serverScreenImage.image.size.height * 0.2);
    self.serverScreenImageWidthConstraint.constant = (CGFloat) (self.serverScreenImage.image.size.width * 0.2);
}


#pragma mark - Actions
- (IBAction)skipAction:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:kJMDefaultsIntroDidApear];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
}

#pragma mark - Setup

#pragma mark - Animations
- (void)forwardToPage:(JMOnboardIntroPage)introPage animation:(BOOL)shouldAnimate
{
    CGFloat animationDuration = shouldAnimate ? kDefaultAnimationDuration : 0;

    void(^animationCompletion)(BOOL) = ^(BOOL finished) {
        // now page is
        self.introPage = introPage;
        [self setButtonTitleForPage:introPage];
        [self updateVisibilityOfImagesForIntroPage:introPage];

        JMIntroModel *model = [self.modelManager modelForIntroPage:introPage];
        self.titlePageLabel.text = model.pageTitle;
        self.descriptionPageLabel.text = model.pageDescription;
    };

    [self updateConstraintsForPage:introPage];

    [UIView animateWithDuration:animationDuration
                     animations:^{
                        [self.view layoutIfNeeded];
                     }
                     completion:animationCompletion];
}

- (void)backToPage:(JMOnboardIntroPage)introPage animation:(BOOL)shouldAnimate
{
    CGFloat animationDuration = shouldAnimate ? kDefaultAnimationDuration : 0;

    void(^animationCompletion)(BOOL) = ^(BOOL finished) {
        [self updateVisibilityOfImagesForIntroPage:introPage];
    };

    [self updateConstraintsForPage:introPage];

    [UIView animateWithDuration:animationDuration
                     animations:^{
                         [self.view layoutIfNeeded];
                     }
                     completion:animationCompletion];
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
        JMLog(@"cancelled state");
    } else if (gestureRecognizer.state == UIGestureRecognizerStateFailed) {
        JMLog(@"failed state");
    }
}

#pragma mark - Private methods
- (void)updateConstraintsForPage:(JMOnboardIntroPage)introPage
{
    CGFloat homeScreenImageTopConstantStartValue = 15;
    CGFloat serverScreenImageTopConstantStartValue = 15;
    CGFloat titleViewTopConstant = -215;

    switch (introPage) {
        case JMOnboardIntroPageWelcome: {
            self.titleViewTopConstraint.constant = 0;
            break;
        }
        case JMOnboardIntroPageStayConnected: {
            self.titleViewTopConstraint.constant = titleViewTopConstant;

            // reports screens
            CGFloat contentViewWidth = CGRectGetWidth(self.contentView.frame);
            CGFloat reportScreenIpadWidth = CGRectGetWidth(self.reportScreenIpadImage.frame);
            CGFloat reportScreenIphoneWidth = CGRectGetWidth(self.reportScreenIphoneImage.frame);

            self.reportScreenIpadCenterXConstraint.constant = (CGFloat) (contentViewWidth/2.0 + reportScreenIpadWidth/2.0);
            self.reportScreenIphoneCenterXConstraint.constant = (CGFloat) -(contentViewWidth/2.0 + reportScreenIphoneWidth/2.0);

            // home screen
            self.homeScreenImageTopConstraint.constant = homeScreenImageTopConstantStartValue;
            self.homeScreenImageHeightConstraint.constant = self.homeScreenImage.image.size.height;
            self.homeScreenImageWidthConstraint.constant = self.homeScreenImage.image.size.width;

            break;
        }
        case JMOnboardIntroPageInstanceAccess: {
            // home screen
            self.homeScreenImageTopConstraint.constant = CGRectGetHeight(self.contentView.frame);
            self.homeScreenImageHeightConstraint.constant = (CGFloat) (self.homeScreenImage.image.size.height * 0.2);
            self.homeScreenImageWidthConstraint.constant = (CGFloat) (self.homeScreenImage.image.size.width * 0.2);

            // server screen
            self.serverScreenImageTopConstraint.constant = CGRectGetHeight(self.contentView.frame);
            self.serverScreenImageHeightConstraint.constant = (CGFloat) (self.serverScreenImage.image.size.height * 0.2);
            self.serverScreenImageWidthConstraint.constant = (CGFloat) (self.serverScreenImage.image.size.width * 0.2);

            // reports screens
            self.reportScreenIpadCenterXConstraint.constant = (CGFloat) (self.reportScreenIpadImage.image.size.width / 6.0);
            self.reportScreenIphoneCenterXConstraint.constant = -self.reportScreenIphoneImage.image.size.width;

            break;
        }
        case JMOnboardIntroPageSeemlessIntegration: {

            // reports screens
            CGFloat contentViewWidth = CGRectGetWidth(self.contentView.frame);
            CGFloat reportScreenIpadWidth = CGRectGetWidth(self.reportScreenIpadImage.frame);
            CGFloat reportScreenIphoneWidth = CGRectGetWidth(self.reportScreenIphoneImage.frame);

            self.reportScreenIpadCenterXConstraint.constant = (CGFloat) (contentViewWidth/2.0 + reportScreenIpadWidth/2.0);
            self.reportScreenIphoneCenterXConstraint.constant = (CGFloat) -(contentViewWidth/2.0 + reportScreenIphoneWidth/2.0);

            // server screen
            self.serverScreenImageTopConstraint.constant = serverScreenImageTopConstantStartValue;
            self.serverScreenImageHeightConstraint.constant = self.serverScreenImage.image.size.height;
            self.serverScreenImageWidthConstraint.constant = self.serverScreenImage.image.size.width;

            break;
        }
    };
}

- (void)updateVisibilityOfImagesForIntroPage:(JMOnboardIntroPage)introPage
{
    switch (introPage) {
        case JMOnboardIntroPageWelcome: {
            self.welcomeView.hidden = NO;
            self.messageView.hidden = YES;

            self.homeScreenImage.hidden = NO;

            self.reportScreenIpadImage.hidden = YES;
            self.reportScreenIphoneImage.hidden = YES;

            self.serverScreenImage.hidden = YES;
            break;
        };
        case JMOnboardIntroPageStayConnected: {
            self.welcomeView.hidden = YES;
            self.messageView.hidden = NO;

            self.homeScreenImage.hidden = NO;

            self.reportScreenIpadImage.hidden = NO;
            self.reportScreenIphoneImage.hidden = NO;

            self.serverScreenImage.hidden = YES;
            break;
        };
        case JMOnboardIntroPageInstanceAccess: {
            self.welcomeView.hidden = YES;
            self.messageView.hidden = NO;

            self.homeScreenImage.hidden = NO;

            self.reportScreenIpadImage.hidden = NO;
            self.reportScreenIphoneImage.hidden = NO;

            self.serverScreenImage.hidden = NO;
            break;
        };
        case JMOnboardIntroPageSeemlessIntegration: {
            self.welcomeView.hidden = YES;
            self.messageView.hidden = NO;

            self.homeScreenImage.hidden = YES;

            self.reportScreenIpadImage.hidden = NO;
            self.reportScreenIphoneImage.hidden = NO;

            self.serverScreenImage.hidden = NO;
            break;
        };
    }
}

- (void)setButtonTitleForPage:(JMOnboardIntroPage)introPage
{
    NSString *buttonTitle = JMCustomLocalizedString(@"intro.button.skip.skip", nil);
    switch (introPage) {
        case JMOnboardIntroPageWelcome:
        case JMOnboardIntroPageStayConnected:
        case JMOnboardIntroPageInstanceAccess: break;
        case JMOnboardIntroPageSeemlessIntegration: {
            buttonTitle = JMCustomLocalizedString(@"intro.button.skip.startUsing", nil);
            break;
        }
    };
    [self.skipButton setTitle:buttonTitle forState:UIControlStateNormal];
}


#pragma mark - Welcome Page
- (void)changeWelcomePageViewsWithVelocity:(CGPoint)velocity
{
    if (velocity.y < 0) { // move up
        self.titleViewTopConstraint.constant -= kDefaultStepValue;
    } else { // move down
        self.titleViewTopConstraint.constant += kDefaultStepValue;
    }

    [self.view layoutIfNeeded];
}

- (void)updateWelcomePageViewsWithVelocity:(CGPoint)velocity
{
    CGFloat titleViewTopConstantMinValue = -70;
    if (velocity.y < 0) { // move up

        if (self.titleViewTopConstraint.constant < titleViewTopConstantMinValue || fabs(velocity.y) > kDefaultMinVelocity ) {
            // move to next page
            [self forwardToPage:JMOnboardIntroPageStayConnected animation:YES];
        } else {
            // restore previous state
            [self backToPage:JMOnboardIntroPageWelcome animation:YES];
        }
    } else { // move down

        // restore previous state
        [self backToPage:JMOnboardIntroPageWelcome animation:YES];
    }
}

#pragma mark - Stay Connected Page
- (void)changeStayConnectedViewsWithVelocity:(CGPoint)velocity
{
    CGFloat homeScreenImageTopConstantStartValue = 15;
    CGFloat homeScreenImageTopConstantMaxValue = 100;
    CGFloat k = self.homeScreenImageHeightConstraint.constant/self.homeScreenImageWidthConstraint.constant;

    if (velocity.y < 0) { // move up
        if (self.homeScreenImageTopConstraint.constant < homeScreenImageTopConstantMaxValue) {
            self.homeScreenImageTopConstraint.constant += kDefaultStepValue;

            self.homeScreenImageWidthConstraint.constant -= kDefaultStepValue;
            self.homeScreenImageHeightConstraint.constant = self.homeScreenImageWidthConstraint.constant * k;

            self.reportScreenIpadCenterXConstraint.constant -= kDefaultStepValue;
            self.reportScreenIphoneCenterXConstraint.constant += kDefaultStepValue;
        }
    } else { // move down
        if (self.homeScreenImageTopConstraint.constant > 0) {
            if (self.homeScreenImageTopConstraint.constant > homeScreenImageTopConstantStartValue - 1 && self.homeScreenImageTopConstraint.constant < homeScreenImageTopConstantStartValue + 1) {
                self.titleViewTopConstraint.constant += kDefaultStepValue;
            } else {
                self.homeScreenImageTopConstraint.constant -= kDefaultStepValue;

                CGFloat homeScreenWidth = self.homeScreenImage.image.size.width;
                if (self.homeScreenImageTopConstraint.constant > homeScreenImageTopConstantStartValue || self.homeScreenImageWidthConstraint.constant < homeScreenWidth ) {
                    self.homeScreenImageWidthConstraint.constant += kDefaultStepValue;
                    self.homeScreenImageHeightConstraint.constant = self.homeScreenImageWidthConstraint.constant * k;
                }

                self.reportScreenIpadCenterXConstraint.constant += kDefaultStepValue;
                self.reportScreenIphoneCenterXConstraint.constant -= kDefaultStepValue;
            }
        }
    }
}

- (void)updateStayConnectedPageViewsWithVelocity:(CGPoint)velocity
{
    CGFloat homeScreenImageTopConstantMaxValue = 100;
    CGFloat titleViewTopConstantMaxValue = -150;

    if (velocity.y < 0) { // move up

        if ( self.homeScreenImageTopConstraint.constant > homeScreenImageTopConstantMaxValue - 1 || (fabs(velocity.y) > kDefaultMinVelocity) ) {
            [self forwardToPage:JMOnboardIntroPageInstanceAccess animation:YES];
        } else {
            [self backToPage:JMOnboardIntroPageStayConnected animation:YES];
        }
    } else { // move down

        if ( self.titleViewTopConstraint.constant > titleViewTopConstantMaxValue || fabs(velocity.y) > kDefaultMinVelocity ) {
            [self forwardToPage:JMOnboardIntroPageWelcome animation:YES];
        } else {
            [self backToPage:JMOnboardIntroPageStayConnected animation:YES];
        }
    }
}

#pragma mark - Instance Access Page

- (void)changeInstanceAccessViewsWithVelocity:(CGPoint)velocity
{
    CGFloat k = self.serverScreenImageHeightConstraint.constant/self.serverScreenImageWidthConstraint.constant;

    if (velocity.y < 0) { // move up

        self.serverScreenImageTopConstraint.constant -= kDefaultStepValue;
        self.serverScreenImageWidthConstraint.constant += kDefaultStepValue;
        self.serverScreenImageHeightConstraint.constant = self.serverScreenImageWidthConstraint.constant * k;

        self.reportScreenIpadCenterXConstraint.constant += kDefaultStepValue;
        self.reportScreenIphoneCenterXConstraint.constant -= kDefaultStepValue;

    } else { // move down
        CGFloat contentViewHeight = CGRectGetHeight(self.contentView.frame);

        if (self.serverScreenImageTopConstraint.constant > contentViewHeight - 1 && self.serverScreenImageTopConstraint.constant < contentViewHeight + 1) {
            self.homeScreenImageTopConstraint.constant -= kDefaultStepValue;
            CGFloat homeScreenAspectRatio = self.homeScreenImageHeightConstraint.constant/self.homeScreenImageWidthConstraint.constant;
            self.homeScreenImageWidthConstraint.constant += kDefaultStepValue;
            self.homeScreenImageHeightConstraint.constant = self.homeScreenImageWidthConstraint.constant * homeScreenAspectRatio;

            self.reportScreenIpadCenterXConstraint.constant += kDefaultStepValue;
            self.reportScreenIphoneCenterXConstraint.constant -= kDefaultStepValue;
        } else if (self.serverScreenImageTopConstraint.constant < contentViewHeight) {
            self.serverScreenImageTopConstraint.constant += kDefaultStepValue;
            self.serverScreenImageWidthConstraint.constant -= kDefaultStepValue;
            self.serverScreenImageHeightConstraint.constant = self.serverScreenImageWidthConstraint.constant * k;

            self.reportScreenIpadCenterXConstraint.constant -= kDefaultStepValue;
            self.reportScreenIphoneCenterXConstraint.constant += kDefaultStepValue;
        }
    }
}

- (void)updateInstanceAccessPageViewsWithVelocity:(CGPoint)velocity
{
    CGFloat maxYValue = 330;
    if (velocity.y < 0) { // move up
        if ( self.serverScreenImageTopConstraint.constant > maxYValue || fabs(velocity.y) > kDefaultMinVelocity ) {
            [self forwardToPage:JMOnboardIntroPageSeemlessIntegration animation:YES];
        } else {
            [self backToPage:JMOnboardIntroPageInstanceAccess animation:YES];
        }
    } else { // move down
        if ( self.homeScreenImageTopConstraint.constant > maxYValue ||  fabs(velocity.y) > kDefaultMinVelocity ) {
            [self forwardToPage:JMOnboardIntroPageStayConnected animation:YES];
        } else {
            [self backToPage:JMOnboardIntroPageInstanceAccess animation:YES];
        }
    }
}

#pragma mark - Seemless Integration Page
- (void)changeSeemlessIntegrationPageViewsWithVelocity:(CGPoint)velocity
{
    CGFloat serverScreenImageTopConstantStartValue = 15;
    CGFloat serverScreenImageTopConstantMaxValue = 100;
    CGFloat k = self.serverScreenImageHeightConstraint.constant/self.serverScreenImageWidthConstraint.constant;

    if (velocity.y < 0) { // move up
        if (self.serverScreenImageTopConstraint.constant > 0) {
            self.serverScreenImageTopConstraint.constant -= kDefaultStepValue;

            CGFloat serverScreenImageWidth = self.serverScreenImage.image.size.width;
            if (self.serverScreenImageTopConstraint.constant > serverScreenImageTopConstantStartValue || self.serverScreenImageWidthConstraint.constant < serverScreenImageWidth) {
                self.serverScreenImageWidthConstraint.constant += kDefaultStepValue;
                self.serverScreenImageHeightConstraint.constant = self.serverScreenImageWidthConstraint.constant * k;
            }

            self.reportScreenIpadCenterXConstraint.constant += kDefaultStepValue;
            self.reportScreenIphoneCenterXConstraint.constant -= kDefaultStepValue;
        }
    } else { // move down
        if (self.serverScreenImageTopConstraint.constant < serverScreenImageTopConstantMaxValue) {
            self.serverScreenImageTopConstraint.constant += kDefaultStepValue;

            self.serverScreenImageWidthConstraint.constant -= kDefaultStepValue;
            self.serverScreenImageHeightConstraint.constant = self.serverScreenImageWidthConstraint.constant * k;

            self.reportScreenIpadCenterXConstraint.constant -= kDefaultStepValue;
            self.reportScreenIphoneCenterXConstraint.constant += kDefaultStepValue;
        }
    }
}

- (void)updateSeemlessIntegrationViewsPageWithVelocity:(CGPoint)velocity
{
    CGFloat serverScreenImageTopConstantMaxValue = 100;
    if (velocity.y < 0) { // move up
        [self backToPage:JMOnboardIntroPageSeemlessIntegration animation:YES];
    } else { // move down
        if (self.serverScreenImageTopConstraint.constant > serverScreenImageTopConstantMaxValue - 1 || fabs(velocity.y) > kDefaultMinVelocity ) {
            [self forwardToPage:JMOnboardIntroPageInstanceAccess animation:YES];
        } else {
            // restore current state
            [self backToPage:JMOnboardIntroPageSeemlessIntegration animation:YES];
        }
    }
}


@end
