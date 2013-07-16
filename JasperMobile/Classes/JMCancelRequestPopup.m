//
//  JMLoadingViewController.m
//  JasperMobile
//
//  Created by Vlad Zavadskii on 6/6/13.
//  Copyright (c) 2013 com.jaspersoft. All rights reserved.
//

#import "JMCancelRequestPopup.h"
#import "JMLocalization.h"
#import "UIViewController+MJPopupViewController.h"
#import <QuartzCore/QuartzCore.h>

static NSString * const kJMCancelRequestPopupNib = @"JMCancelRequestPopup";

static JMCancelRequestPopup *instance;

@interface JMCancelRequestPopup ()
@property (nonatomic, strong) JSRESTBase *restClient;
@property (nonatomic, strong) UIViewController *viewController;
@property (nonatomic, copy) JMCancelRequestBlock cancelBlock;
@property (nonatomic, weak) IBOutlet UIButton *cancelButton;
@property (nonatomic, weak) IBOutlet UILabel *progressLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil viewController:(UIViewController *)viewController restClient:(JSRESTBase *)restClient cancelBlock:(JMCancelRequestBlock)cancelBlock;
@end

@implementation JMCancelRequestPopup

#pragma mark - Class Methods

+ (void)presentInViewController:(UIViewController *)viewController progressMessage:(NSString *)progressMessage restClient:(JSRESTBase *)client cancelBlock:(JMCancelRequestBlock)cancelBlock
{
    // Before presenting new cancel request popup we should dismiss previous one
    [[self class] dismiss];
    
    instance = [[JMCancelRequestPopup alloc] initWithNibName:kJMCancelRequestPopupNib
                                                      bundle:nil
                                              viewController:viewController
                                                  restClient:client
                                                 cancelBlock:cancelBlock];
    
    [instance.cancelButton setTitle:JMCustomLocalizedString(@"dialog.button.cancel", nil) forState:UIControlStateNormal];
    instance.progressLabel.text = JMCustomLocalizedString(progressMessage, nil);
    
    [viewController presentPopupViewController:instance animationType:MJPopupViewAnimationFade];
}

+ (void)dismiss
{
    if (instance) {
        [instance.viewController dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
        instance = nil;
    }
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.layer.cornerRadius = 5.0f;
}

- (void)viewDidUnload
{
    [self setCancelButton:nil];
    [self setProgressLabel:nil];
    [super viewDidUnload];
}

#pragma mark - Actions

- (IBAction)cancelRequests:(id)sender
{
    [self.restClient cancelAllRequests];
    [self.viewController dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    
    if (self.cancelBlock) {
        self.cancelBlock();
    }
}

#pragma mark - Private

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil viewController:(UIViewController *)viewController restClient:(JSRESTBase *)restClient cancelBlock:(JMCancelRequestBlock)cancelBlock
{
    self = [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.restClient = restClient;
        self.viewController = viewController;
        self.cancelBlock = cancelBlock;
    }
    
    return self;
}

@end
