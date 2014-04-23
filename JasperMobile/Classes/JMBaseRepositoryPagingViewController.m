//
//  JMBaseRepositoryPagingViewController.m
//  JasperMobile
//
//  Created by Vlad Zavadsky on 3/17/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import "JMBaseRepositoryPagingViewController.h"
#import "JMResourcePageContentViewController.h"

@interface JMBaseRepositoryPagingViewController ()
@property (nonatomic, assign) NSInteger totalPages;
@end

@implementation JMBaseRepositoryPagingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.totalPages = 15;
    
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                              navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                            options:nil];
	// Do any additional setup after loading the view.
    JMResourcePageContentViewController *defaultViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ResourcePageContentViewController"];
    defaultViewController.index = 0;
    
//    JMReportViewerViewController *defaultViewController = [self instantiateReportViewerViewControllerWithPageToDisplay:-1];
    [self.pageViewController setViewControllers:@[defaultViewController]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:NO
                                     completion:nil];
    
    self.pageViewController.dataSource = self;
    
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.view sendSubviewToBack:self.pageViewController.view];
    
    // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
    CGRect pageViewRect = self.view.bounds;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        pageViewRect = CGRectInset(pageViewRect, 40.0, 40.0);
    }
    self.pageViewController.view.frame = pageViewRect;
    
    [self.pageViewController didMoveToParentViewController:self];
    
    // Add the page view controller's gesture recognizers to the book view controller's view so that the gestures are started more easily.
    self.view.gestureRecognizers = self.pageViewController.gestureRecognizers;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    JMResourcePageContentViewController *pVC = (JMResourcePageContentViewController *) viewController;
    if (pVC.index <= 0) return nil;
    
    JMResourcePageContentViewController *newPVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ResourcePageContentViewController"];
    newPVC.index = pVC.index--;
    
    return newPVC;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    JMResourcePageContentViewController *pVC = (JMResourcePageContentViewController *) viewController;
    if (pVC.index >= self.totalPages) return nil;
    
    JMResourcePageContentViewController *newPVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ResourcePageContentViewController"];
    newPVC.index = pVC.index++;
    
    return newPVC;
}

@end
