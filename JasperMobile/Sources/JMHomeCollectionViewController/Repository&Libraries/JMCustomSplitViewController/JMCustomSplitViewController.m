//
//  JMCustomSplitViewController.m
//  JasperMobile
//
//  Created by Vlad Zavadskii on 6/18/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import "JMCustomSplitViewController.h"
#import "JMActionBarProvider.h"
#import "JMSearchBarAdditions.h"
#import <QuartzCore/QuartzCore.h>
#import "JMFullScreenButtonProvider.h"
#import "JMSearchBar.h"

#import "UIView+Additions.h"
#import "UIImage+Additions.h"

static NSString * const kJMMasterViewControllerSegue = @"MasterViewController";
static NSString * const kJMDetailViewControllerSegue = @"DetailViewController";

@interface JMCustomSplitViewController () <UINavigationControllerDelegate, JMSearchBarDelegate>
@property (nonatomic, weak) IBOutlet UIView *masterView;
@property (weak, nonatomic) IBOutlet UIView *masterContainerView;
@property (nonatomic, weak) UINavigationController *masterNavigationController;
@property (nonatomic, weak) IBOutlet UIView *detailView;
@property (weak, nonatomic) IBOutlet UIView *detailContainerView;
@property (nonatomic, weak) UINavigationController *detailNavigationController;

@property (nonatomic, weak) IBOutlet UILabel *menuLabel;
@property (weak, nonatomic) IBOutlet UIView *actionBarPlaceHolder;
@property (nonatomic, strong) NSString *menuTitle;


// Provided by child view controllers
@property (weak, nonatomic) IBOutlet UIButton *fullScreenButton;

@property (strong, nonatomic) JMSearchBar *searchBar;

@end


@implementation JMCustomSplitViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.menuLabel.text = JMCustomLocalizedString(@"master.base.resources.title", nil);

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
        container = self.masterContainerView;
        [destinationViewController view].autoresizingMask = UIViewAutoresizingFlexibleHeight;
    } else if ([segue.identifier isEqualToString:kJMDetailViewControllerSegue]) {
        container = self.detailContainerView;
        [destinationViewController view].autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    
    if ([destinationViewController isKindOfClass:[UINavigationController class]]) {
        [destinationViewController setDelegate:self];
        if ([segue.identifier isEqualToString:kJMDetailViewControllerSegue]) {
            self.detailNavigationController = destinationViewController;
        } else {
            self.masterNavigationController = destinationViewController;
        }
    }
    
    [destinationViewController view].frame = container.bounds;
    [container addSubview:[destinationViewController view]];
    [destinationViewController didMoveToParentViewController:self];
}

#pragma mark - Actions

- (IBAction)fullScreenButtonTapped:(id)sender
{
    self.fullScreenButton.selected = !self.fullScreenButton.selected;
    [UIView animateWithDuration:0.15 animations:^{
        if (self.fullScreenButton.selected) {
            self.detailView.frame = self.view.bounds;
        } else {
            CGRect viewRect = [self getDetailsViewFrame];
            viewRect.origin.x = self.masterView.frame.size.width;
            viewRect.size.width -= self.masterView.frame.size.width;
            self.detailView.frame = viewRect;
        }
    }];
}

- (void)searchButtonTapped:(id)sender
{
    [self setSearchBarHidden:NO];
}

#pragma mark - JMSearchBarDelegate

- (void)searchBarSearchButtonClicked:(JMSearchBar *)searchBar
{
    NSString *query = searchBar.text;
    id visibleViewController = self.masterNavigationController.visibleViewController;
    if ([visibleViewController conformsToProtocol:@protocol(JMSearchBarAdditions)]) {
        if (![[visibleViewController currentQuery] isEqualToString:query]) {
            [visibleViewController searchWithQuery:query];
        }
    }
}

- (void)searchBarClearButtonClicked:(JMSearchBar *)searchBar
{
    id visibleViewController = self.masterNavigationController.visibleViewController;
    if ([visibleViewController conformsToProtocol:@protocol(JMSearchBarAdditions)]) {
        [visibleViewController didClearSearch];
    }
    
    if ([searchBar.text length] == 0) {
        [self setSearchBarHidden:YES];
    }
}

- (void)searchBarCancelButtonClicked:(JMSearchBar *) searchBar
{
    if ([searchBar.text length] == 0) {
        [self setSearchBarHidden:YES];
    }
}

- (void) setSearchBarHidden:(BOOL)hidden
{
    UIBarButtonItem *searchItem = nil;
    if (hidden) {
        searchItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchButtonTapped:)];
        self.searchBar.text = nil;
    } else {
        if (!self.searchBar) {
            self.searchBar = [[JMSearchBar alloc] initWithFrame:CGRectMake(0, 0, 300, 34)];
            self.searchBar.delegate = self;
            self.searchBar.placeholder = JMCustomLocalizedString(@"search.resources.placeholder", nil);
        }
        searchItem = [[UIBarButtonItem alloc] initWithCustomView:self.searchBar];
    }
    [self.navigationItem setRightBarButtonItem:searchItem animated:YES];
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    if ([navigationController isEqual:self.detailNavigationController]) {
        [self showFullScreenButtonForViewController:viewController];
        [self showActionBarForViewController:viewController];
    }
    [self showNavigationItems];
}

#pragma mark - Private
- (void) showActionBarForViewController:(id)viewController
{
    [self.actionBarPlaceHolder.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if ([viewController conformsToProtocol:@protocol(JMActionBarProvider)]) {
        UIView *actionBar = [viewController actionBar];
        if (actionBar) {
            actionBar.frame = self.actionBarPlaceHolder.bounds;
            [self.actionBarPlaceHolder addSubview:actionBar];
        }
    }
    [UIView beginAnimations:nil context:nil];
    self.detailView.frame = [self getDetailsViewFrame];
    [UIView commitAnimations];
}

- (void) showFullScreenButtonForViewController:(id)viewController
{
    [UIView beginAnimations:nil context:nil];
    if ([viewController respondsToSelector:@selector(shouldDisplayFullScreenButton)]) {
        self.fullScreenButton.alpha = [viewController shouldDisplayFullScreenButton] ? 1 : 0;
        [self.detailView bringSubviewToFront:self.fullScreenButton];
    } else {
        self.fullScreenButton.alpha = 0;
    }
    if (self.fullScreenButton.alpha) {
        UIColor *fullScreenButtonImageColor = nil;
        if ([viewController respondsToSelector:@selector(fullScreenButtonImageColor)]) {
            fullScreenButtonImageColor = [viewController fullScreenButtonImageColor];
        } else {
            fullScreenButtonImageColor = [[viewController view] colorOfPoint:self.fullScreenButton.center];
            fullScreenButtonImageColor = [UIColor highlitedColorForColor:fullScreenButtonImageColor];
        }
        
        UIImage *normalImage = [[UIImage imageNamed:@"fullScreenMode.png"] colorizeImageWithColor:fullScreenButtonImageColor];
        UIImage *selectedImage = [[UIImage imageNamed:@"defaultScreenMode.png"] colorizeImageWithColor:fullScreenButtonImageColor];
        [self.fullScreenButton setImage:normalImage forState:UIControlStateNormal];
        [self.fullScreenButton setImage:selectedImage forState:UIControlStateSelected];
    }
    [UIView commitAnimations];
}

- (void) showNavigationItems
{
    [self.navigationItem setRightBarButtonItems:nil animated:YES];
    BOOL isSearchVisible = [self.masterNavigationController.visibleViewController conformsToProtocol:@protocol(JMSearchBarAdditions)];
    if (isSearchVisible) {
        [self setSearchBarHidden:YES];
    }
    

    UIViewController *visibleDetailsViewController = self.detailNavigationController.visibleViewController;
    NSMutableArray *itemsArray = [visibleDetailsViewController.navigationItem.rightBarButtonItems mutableCopy];
    if ([itemsArray count]) {
        [itemsArray addObjectsFromArray:self.navigationItem.rightBarButtonItems];
        self.navigationItem.rightBarButtonItems = itemsArray;
    }
    if (visibleDetailsViewController.title && [visibleDetailsViewController.title length]) {
        self.navigationItem.title = visibleDetailsViewController.navigationItem.title;
    }
}

- (CGRect) getDetailsViewFrame
{
    CGRect detailsViewFrame = self.detailView.frame;
    UIView *actionBar = [self.actionBarPlaceHolder.subviews firstObject];
    if (actionBar) {
        detailsViewFrame.origin.y = self.actionBarPlaceHolder.frame.size.height;
        detailsViewFrame.size.height = self.view.bounds.size.height - detailsViewFrame.origin.y;
    } else {
        detailsViewFrame.origin.y = 0;
        detailsViewFrame.size.height = self.view.bounds.size.height;
    }
    return detailsViewFrame;
}

@end
