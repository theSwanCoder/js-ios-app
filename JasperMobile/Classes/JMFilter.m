//
//  JMRESTFilter.m
//  JasperMobile
//
//  Created by Vlad Zavadskii on 5/30/13.
//  Copyright (c) 2013 com.jaspersoft. All rights reserved.
//

#import "JMFilter.h"
#import "JMCancelRequestPopup.h"
#import "UIAlertView+LocalizedAlert.h"

static JMFilter * delegate;

@interface JMFilter()
@property (nonatomic, weak) id <JSRequestDelegate> delegate;
@property (nonatomic, weak) UIViewController *viewControllerToDismiss;

- (id)initWithDelegate:(id <JSRequestDelegate>)delegate;
- (id)initWithDismissalViewController:(UIViewController *)viewController;
@end

@implementation JMFilter

#pragma mark - Class Methods

+ (void)checkNetworkReachabilityForBlock:(void (^)(void))block viewControllerToDismiss:(id)viewController
{
    if (![JSRESTBase isNetworkReachable]) {
        delegate = [[JMFilter alloc] initWithDismissalViewController:viewController];
        
        [JMCancelRequestPopup dismiss];
        [[UIAlertView localizedAlert:@"error.noconnection.dialog.title"
                             message:@"error.noconnection.dialog.msg"
                            delegate:delegate
                   cancelButtonTitle:@"dialog.button.ok"
                   otherButtonTitles:nil] show];
    } else {
        block();
	}
}

+ (JMFilter *)checkRequestResultForDelegate:(id <JSRequestDelegate>)delegate;
{
    return [[self alloc] initWithDelegate:delegate];
}

#pragma mark - JSRequestDelegate

- (void)requestFinished:(JSOperationResult *)result
{
    [JMCancelRequestPopup dismiss];
    
    if ([result isSuccessful]) {
        [self.delegate requestFinished:result];
    } else {
        [[UIAlertView localizedAlert:@"error.readingresponse.dialog.msg"
                             message:[NSString stringWithFormat:@"error.http.%i", result.statusCode]
                            delegate:nil
                   cancelButtonTitle:@"dialog.button.ok"
                   otherButtonTitles:nil] show];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    delegate = nil;
    
    if (self.viewControllerToDismiss.navigationController) {
        [self.viewControllerToDismiss.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Private

- (id)initWithDelegate:(id <JSRequestDelegate>)delegate
{
    if (self = [self init]) {
        self.delegate = delegate;
    }
    
    return self;
}

- (id)initWithDismissalViewController:(UIViewController *)viewController
{
    if (self = [self init]) {
        self.viewControllerToDismiss = viewController;
    }
    
    return self;
}

@end
