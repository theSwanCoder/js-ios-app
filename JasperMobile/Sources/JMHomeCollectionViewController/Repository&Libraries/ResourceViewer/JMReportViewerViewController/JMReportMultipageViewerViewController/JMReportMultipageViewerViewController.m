//
//  JMReportMultipageViewerViewController.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 1/25/15.
//  Copyright (c) 2015 TIBCO JasperMobile. All rights reserved.
//

#import "JMReportMultipageViewerViewController.h"
#import "JMReportPageViewerViewController.h"
#import "JMReportViewer.h"
#import "JMReportViewerPaginationToolbar.h"
#import "JMResourcesCollectionViewController.h"
#import "JMReportLoader.h"

@interface JMReportMultipageViewerViewController() <JMReportViewerPaginationToolbarDelegate, JMReportLoaderDelegate>
@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (nonatomic, assign) NSInteger countOfPages;
@property (nonatomic, strong) JMReportLoader *reportLoader;
@property (nonatomic, weak) JMReportViewerPaginationToolbar *toolbar;
@end

@implementation JMReportMultipageViewerViewController

#pragma mark - Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.countOfPages = 1;
    
    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
    
    JMReportPageViewerViewController *startingViewController = (JMReportPageViewerViewController *)[self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
}

#pragma mark - Actions
- (void) backButtonTapped:(id) sender
{
    [self.view endEditing:YES];
    NSInteger currentIndex = [self.navigationController.viewControllers indexOfObject:self];
    for (NSInteger i = currentIndex; i > 0; --i) {
        UIViewController *controller = [self.navigationController.viewControllers objectAtIndex:i];
        if ([controller isKindOfClass:[JMResourcesCollectionViewController class]]) {
            [self.toolbar removeFromSuperview];
            [self.navigationController popToViewController:controller animated:YES];
            break;
        }
    }
}

#pragma mark - Public API
- (void)setInputControls:(NSMutableArray *)inputControls
{
    self.reportLoader.inputControls = inputControls;
}

#pragma mark - Properties
- (JMReportLoader *)reportLoader
{
    if (!_reportLoader) {
        _reportLoader = [[JMReportLoader alloc] initWithResourceLookup:self.resourceLookup];
        _reportLoader.delegate = self;
    }
    return _reportLoader;
}

- (JMReportViewerPaginationToolbar *)toolbar
{
    if (!_toolbar) {
        _toolbar = [[[NSBundle mainBundle] loadNibNamed:@"JMReportViewerPaginationToolbar" owner:self options:nil] firstObject];
        _toolbar.toolBarDelegate = self;
        _toolbar.currentPage = self.reportLoader.currentPage;
        _toolbar.countOfPages = self.reportLoader.countOfPages;
        [self.navigationController.toolbar addSubview:_toolbar];
        _toolbar.frame = self.navigationController.toolbar.bounds;
    }
    return _toolbar;
}


#pragma mark - Run Report
- (void) runReportExecution
{
    [self.reportLoader runReportExecution];
}

#pragma mark - Private Methods
- (JMReportPageViewerViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if ( index >= self.countOfPages ) {
        return nil;
    }
    
    JMReportPageViewerViewController *reportPageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"JMReportPageViewerViewController"];
    reportPageViewController.pageIndex = index;
    
    [self.reportLoader startLoadPage:index+1 withCompletion:@weakself(^(NSString *HTMLString, NSString *baseURL)) {
        
        [reportPageViewController.webView loadHTMLString:HTMLString
                                                 baseURL:[NSURL URLWithString:baseURL]];
        //self.toolbar.currentPage = reportPageViewController.pageIndex;
    }@weakselfend];
    
    return reportPageViewController;
}

- (void) updateToolbarAppearence
{
    BOOL isToolbarHidden = YES;
    if (self.reportLoader.isMultiPageReport && self.toolbar) {
        isToolbarHidden = NO;
    }
    
    if (self.navigationController.toolbarHidden != isToolbarHidden) {
        [self.navigationController setToolbarHidden:isToolbarHidden
                                           animated:YES];
    }
}

#pragma mark - UIPageViewControllerDataSource
-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((JMReportPageViewerViewController *)viewController).pageIndex;
    if (index == 0 || index == NSNotFound) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((JMReportPageViewerViewController *) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == self.countOfPages) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

#pragma mark - JMRefreshable
- (void)refresh
{
    [self.navigationController popToViewController:self animated:YES];
    [self runReportExecution];
}

#pragma mark - JMReportLoaderDelegate
- (void)reportLoaderDidRunReportExecution:(JMReportLoader *)reportLoader
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
}

- (void)reportLoaderDidEndReportExecution:(JMReportLoader *)reportLoader
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
}

// start export execution
- (void)reportLoaderDidBeginExportExecution:(JMReportLoader *)reportLoader forPageNumber:(NSInteger)pageNumber
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
}

- (void)reportLoaderDidEndExportExecution:(JMReportLoader *)loader forPageNumber:(NSInteger)pageNumber
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
}

// start load output resources
- (void)reportLoaderDidBeginLoadOutputResources:(JMReportLoader *)reportLoader forPageNumber:(NSInteger)pageNumber
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
}

- (void)reportLoaderDidEndLoadOutputResources:(JMReportLoader *)reportLoader forPageNumber:(NSInteger)pageNumber
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
}

// cancel
- (void)reportLoaderDidCancel:(JMReportLoader *)reportLoader
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    [self backButtonTapped:nil];
}

// show report's page
- (void)reportLoader:(JMReportLoader *)reportLoader
   didLoadHTMLString:(NSString *)HTMLString
         withBaseURL:(NSString *)baseURL
       forPageNumber:(NSUInteger)pageNumber
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    
//    if (pageNumber > self.pageViewController.viewControllers.count) {
//        return;
//    }
//    
//    JMReportPageViewerViewController *reportPageViewController = [self.pageViewController viewControllers][pageNumber - 1];
//    if (reportPageViewController.webView.isLoading) {
//        [reportPageViewController.webView stopLoading];
//    }
//    [reportPageViewController.webView loadHTMLString:HTMLString
//                                             baseURL:[NSURL URLWithString:baseURL]];
}

- (void)reportLoader:(JMReportLoader *)reportLoader
didFailedLoadHTMLStringWithError:(JSErrorDescriptor *)error
       forPageNumber:(NSInteger)pageNumber
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
}

-(void)reportLoaderDidUpdateState:(JMReportLoader *)reportLoader
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    self.toolbar.currentPage = reportLoader.currentPage;
    self.toolbar.countOfPages = reportLoader.countOfPages;
    self.countOfPages = reportLoader.countOfPages;
    [self updateToolbarAppearence];
}

#pragma mark - JMReportViewerPaginationToolbarDelegate
- (void)reportViewerPaginationToolbar:(JMReportViewerPaginationToolbar *)toolbar didChangePage:(NSUInteger)page
{
    self.reportLoader.currentPage = page;
}

@end
