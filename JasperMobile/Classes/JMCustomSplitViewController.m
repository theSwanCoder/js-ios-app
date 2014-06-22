//
//  JMCustomSplitViewController.m
//  JasperMobile
//
//  Created by Vlad Zavadskii on 6/18/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import "JMCustomSplitViewController.h"
#import "JMActionBarProvider.h"
#import "JMSearchable.h"
#import <QuartzCore/QuartzCore.h>

static NSString * const kJMMasterViewControllerSegue = @"MasterViewController";
static NSString * const kJMDetailViewControllerSegue = @"DetailViewController";

@interface JMCustomSplitViewController()
// Returns visible master view controller from stack of UINavigationViewController or
// returns first child view controller (if exists)
- (id)visibleMasterViewController;
// Returns visible detail view controller from stack of UINavigationViewController or
// returns first detail view controller (if exists)
- (id)visibleDetailViewController;
@end

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
}

//- (IBAction)search:(id)sender
//{
//    NSString *query = [sender textLabel].text;
//    for (id viewController in self.prese) {
//        
//    }
//}

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

- (id)visibleMasterViewController
{
    id masterViewController = [self.childViewControllers firstObject];
    if ([masterViewController isKindOfClass:[UINavigationController class]]) masterViewController = [masterViewController visibleViewController];
    return masterViewController;
}

@end
