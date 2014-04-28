/*
 * JasperMobile for iOS
 * Copyright (C) 2011 - 2014 Jaspersoft Corporation. All rights reserved.
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
//  JMReportPagingViewController.m
//  Jaspersoft Corporation
//

#import "JMReportPagingViewController.h"
#import "JMCancelRequestPopup.h"
#import "JMReportViewerViewController.h"
#import "JMRequestDelegate.h"
#import "JMUtils.h"
#import "UIAlertView+LocalizedAlert.h"
#import <Objection-iOS/Objection.h>

static NSString * const kJMShowReportSaverSegue = @"ShowReportSaver";

@interface JMReportPagingViewController()
@property (nonatomic, assign) NSInteger totalPages;
@property (nonatomic, strong) NSString *requestId;
@property (nonatomic, strong) NSString *exportId;
@property (nonatomic, weak) JSConstants *constants;
@end

@implementation JMReportPagingViewController
objection_requires(@"resourceClient", @"reportClient", @"constants")
inject_default_rotation()

@synthesize resourceLookup = _resourceLookup;
@synthesize reportClient = _reportClient;
@synthesize resourceClient = _resourceClient;

#pragma mark - Initialization

- (void)awakeFromNib
{
    [super awakeFromNib];
    [[JSObjection defaultInjector] injectDependencies:self];
}

#pragma mark - UIViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id destinationViewController = segue.destinationViewController;
    [destinationViewController setResourceLookup:self.resourceLookup];
    [destinationViewController setParameters:self.parameters];
    [destinationViewController setDelegate:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSDictionary *options = @{UIPageViewControllerOptionInterPageSpacingKey : [NSNumber numberWithInt:20]};
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                              navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                            options:options];

    JMReportViewerViewController *defaultViewController = [self instantiateReportViewerViewControllerWithPageToDisplay:-1];
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

    if (self.resourceClient.serverProfile.serverInfo.versionAsInteger >= self.constants.VERSION_CODE_EMERALD_V2) {
        [self runReportExecution:defaultViewController];
    } else {
        [self runReport:defaultViewController];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (![JMRequestDelegate isRequestPoolEmpty]) {
        [self.reportClient cancelAllRequests];
    }
    [JMUtils hideNetworkActivityIndicator];
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSInteger currentPage = [(JMReportViewerViewController *)viewController currentPage];
    if (currentPage <= 1) return nil;
    return [self instantiateReportViewerViewControllerWithPageToDisplay:currentPage - 1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSInteger currentPage = [(JMReportViewerViewController *)viewController currentPage];
    if (currentPage >= self.totalPages) return nil;
    return [self instantiateReportViewerViewControllerWithPageToDisplay:currentPage + 1];
}

#pragma mark - Actions

- (IBAction)saveReport:(id)sender
{
    if (self.resourceClient.serverProfile.serverInfo.versionAsInteger >= self.constants.VERSION_CODE_EMERALD_V2) {
        [self performSegueWithIdentifier:kJMShowReportSaverSegue sender:self];
    } else {
        [[UIAlertView localizedAlertWithTitle:@"error.savereport.notavaialble.title"
                                      message:@"error.savereport.notavaialble.msg"
                                     delegate:nil
                            cancelButtonTitle:@"dialog.button.ok"
                            otherButtonTitles:nil] show];
    }
}

#pragma mark - Private

- (JMReportViewerViewController *)instantiateReportViewerViewControllerWithPageToDisplay:(NSInteger)page
{
    JMReportViewerViewController *viewController = (JMReportViewerViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"ReportViewerViewController"];
    viewController.currentPage = page;
    if (!viewController.request && self.requestId && self.exportId) {
        viewController.request = [self URLRequestForPage:page];
    }
    return viewController;
}

#pragma mark Uses for JRS versions 5.5 and higher

- (void)runReportExecution:(JMReportViewerViewController *)viewController
{
    [JMCancelRequestPopup dismiss];

    __weak JMReportPagingViewController *weakSelf = self;

    JMRequestDelegate *delegate = [JMRequestDelegate requestDelegateForFinishBlock:^(JSOperationResult *result) {
        JSReportExecutionResponse *response = [result.objects objectAtIndex:0];
        JSExportExecution *export = [response.exports objectAtIndex:0];

        weakSelf.totalPages = [response.totalPages integerValue];
        weakSelf.requestId = response.requestId;
        weakSelf.exportId = export.uuid;

        JMReportViewerViewController *viewController1 = [self instantiateReportViewerViewControllerWithPageToDisplay:1];
        [weakSelf.pageViewController setViewControllers:@[viewController1]
                                                                direction:UIPageViewControllerNavigationDirectionForward
                                                                 animated:NO
                                                               completion:nil];
    } errorBlock:^(JSOperationResult *result) {
        [viewController.activityIndicator stopAnimating];
    } viewControllerToDismiss:self];

    [self.reportClient runReportExecution:self.resourceLookup.uri async:NO outputFormat:self.constants.CONTENT_TYPE_HTML
                              interactive:YES freshData:YES saveDataSnapshot:NO ignorePagination:NO transformerKey:nil
                                    pages:nil attachmentsPrefix:nil parameters:self.parameters delegate:delegate];
}

- (NSURLRequest *)URLRequestForPage:(NSInteger)page
{
    NSString *fullExportId = [NSString stringWithFormat:@"%@;pages=%i", self.exportId, page];
    NSString *reportUrl = [self.reportClient generateReportOutputUrl:self.requestId exportOutput:fullExportId];
    return [NSURLRequest requestWithURL:[NSURL URLWithString:reportUrl]];
}


#pragma mark Uses for JRS versions 5.0 - 5.5

- (void)runReport:(JMReportViewerViewController *)viewController
{
    NSURL *reportURL = [NSURL URLWithString:[self.reportClient generateReportUrl:self.resourceLookup.uri
                                                                    reportParams:self.parameters
                                                                            page:0
                                                                          format:self.constants.CONTENT_TYPE_HTML]];
    NSURLRequest *request = [NSURLRequest requestWithURL:reportURL];
    [JMUtils showNetworkActivityIndicator];
    viewController.request = request;
}

@end
