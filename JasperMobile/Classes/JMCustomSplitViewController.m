//
//  JMCustomSplitViewController.m
//  JasperMobile
//
//  Created by Vlad Zavadskii on 6/18/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import "JMCustomSplitViewController.h"
#import "JMActionBarProvider.h"
#import "JMHeaderBarAdditions.h"
#import <QuartzCore/QuartzCore.h>

static NSString * const kJMMasterViewControllerSegue = @"MasterViewController";
static NSString * const kJMDetailViewControllerSegue = @"DetailViewController";

@implementation JMCustomSplitViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(back:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    tapGestureRecognizer.numberOfTouchesRequired = 1;
    [self.logoView addGestureRecognizer:tapGestureRecognizer];
    
    self.searchTextField.delegate = self;
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 7.0f, 0)];
    self.searchTextField.leftView = paddingView;
    self.searchTextField.leftViewMode = UITextFieldViewModeAlways;
    [self searchHidden:YES];
    
    self.headerBarLabel.text = @"";
    
    @try {
        [self performSegueWithIdentifier:kJMMasterViewControllerSegue sender:self];
    } @catch (NSException *exception) {
        NSLog(@"No segue to master view controller");
    }
    
    @try {
        [self performSegueWithIdentifier:kJMDetailViewControllerSegue sender:self];
    } @catch (NSException *exception) {
        NSLog(@"No segue to detail view controller");
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id destinationViewController = segue.destinationViewController;
    
    // TODO: investigate if manually removing child view controllers is needed
    [self addChildViewController:destinationViewController];
    
    UIView *container;
    
    if ([segue.identifier isEqualToString:kJMMasterViewControllerSegue]) {
        container = self.masterView;
        [destinationViewController view].autoresizingMask = UIViewAutoresizingFlexibleHeight;
    } else if ([segue.identifier isEqualToString:kJMDetailViewControllerSegue]) {
        container = self.detailView;
        [destinationViewController view].autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    
    if ([destinationViewController isKindOfClass:[UINavigationController class]]) {
        [destinationViewController setDelegate:self];
    } else if ([destinationViewController conformsToProtocol:@protocol(JMHeaderBarAdditions)] &&
               [destinationViewController respondsToSelector:@selector(searchWithQuery:)]) {
        [self searchHidden:NO];
    }
    
    [destinationViewController view].frame = CGRectMake(0, 0, container.frame.size.width,
                                                        container.frame.size.height);
    [container addSubview:[destinationViewController view]];
    [destinationViewController didMoveToParentViewController:self];
}

#pragma mark - Actions

- (IBAction)back:(UITapGestureRecognizer *)recognizer
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    [self showActionBarForViewController:viewController];
    
    __block BOOL isSearchHidden = YES;
    __weak JMCustomSplitViewController *weakSelf = self;
    
    [self performActionOnVisibleViewControllers:^(id viewController) {
        if ([viewController respondsToSelector:@selector(searchWithQuery:)]) {
            isSearchHidden = NO;
        }
        if ([viewController respondsToSelector:@selector(barTitle)]) {
            weakSelf.headerBarLabel.text = [viewController barTitle];
        }
    } conformsToProtocol:@protocol(JMHeaderBarAdditions)];
    [self searchHidden:isSearchHidden];
}

- (IBAction)search:(id)sender
{
    NSString *query = self.searchTextField.text;
    [self.searchTextField resignFirstResponder];
    [self performActionOnVisibleViewControllers:^(id viewController) {
        if ([viewController respondsToSelector:@selector(searchWithQuery:)]) {
            [viewController searchWithQuery:query];
        }
    } conformsToProtocol:@protocol(JMHeaderBarAdditions)];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    [self performActionOnVisibleViewControllers:^(id viewController) {
        if ([viewController respondsToSelector:@selector(clearSearch)]) {
            [viewController clearSearch];
        }
    } conformsToProtocol:@protocol(JMHeaderBarAdditions)];
    
    textField.text = @"";
    [textField resignFirstResponder];
    
    return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self search:nil];
    return YES;
}

#pragma mark - Private

- (void)showActionBarForViewController:(id)viewController
{
    if ([viewController conformsToProtocol:@protocol(JMActionBarProvider)]) {
        // TODO: optimize - reuse old instance of action bar (by setting new delegate) if it remains the same
        UIView *actionBar = [viewController actionBar];
        UIView *currentActionBar = self.actionBarPlaceholderView.subviews.firstObject;
        
        if (currentActionBar == actionBar) {
            return;
        } else if (currentActionBar) {
            [currentActionBar removeFromSuperview];
        }
        
        if (actionBar) {
            actionBar.frame = CGRectMake(0, 0, self.actionBarPlaceholderView.frame.size.width, self.actionBarPlaceholderView.frame.size.height);
            actionBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [self.actionBarPlaceholderView addSubview:actionBar];
        }
    }
}

- (void)performActionOnVisibleViewControllers:(void (^)(id viewController))action conformsToProtocol:(Protocol *)protocol
{
    for (id viewController in self.childViewControllers) {
        id visibleViewController;
        
        if ([viewController isKindOfClass:[UINavigationController class]]) {
            visibleViewController = [viewController visibleViewController];
        } else {
            visibleViewController = viewController;
        }
        
        if (!protocol || [visibleViewController conformsToProtocol:protocol]) {
            action(visibleViewController);
        }
    }
}

- (void)searchHidden:(BOOL)hidden
{
    self.searchTextField.hidden = hidden;
    self.searchButton.hidden = hidden;
}

@end
