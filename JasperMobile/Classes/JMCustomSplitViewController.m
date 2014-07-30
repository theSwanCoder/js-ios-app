//
//  JMCustomSplitViewController.m
//  JasperMobile
//
//  Created by Vlad Zavadskii on 6/18/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import "JMCustomSplitViewController.h"
#import "JMActionBarProvider.h"
#import "JMTitleProvider.h"
#import "JMHeaderBarAdditions.h"
#import <QuartzCore/QuartzCore.h>
#import "JMFullScreenButtonProvider.h"

#import "UIView+Additions.h"
#import "UIImage+Additions.h"

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
    
    
    [self showMasterView:NO];

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
        [self showMasterView:YES];
        container = self.masterView;
        [destinationViewController view].autoresizingMask = UIViewAutoresizingFlexibleHeight;
    } else if ([segue.identifier isEqualToString:kJMDetailViewControllerSegue]) {
        container = self.detailView;
        [destinationViewController view].autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    
    if ([destinationViewController isKindOfClass:[UINavigationController class]]) {
        [destinationViewController setDelegate:self];
        if ([segue.identifier isEqualToString:kJMDetailViewControllerSegue]) {
            self.detailNavigationController = destinationViewController;
        }
    } else if ([destinationViewController conformsToProtocol:@protocol(JMHeaderBarAdditions)] &&
               [destinationViewController respondsToSelector:@selector(searchWithQuery:)]) {
        [self searchHidden:NO];
    }
    
    [destinationViewController view].frame = CGRectMake(0, 0, container.frame.size.width,
                                                        container.frame.size.height);
    [container addSubview:[destinationViewController view]];
    [destinationViewController didMoveToParentViewController:self];
}

- (void)setMenuTitle:(NSString *)menuTitle
{
    _menuTitle = menuTitle;
    self.menuLabel.text = menuTitle;
}

#pragma mark - Actions

- (IBAction)back:(UITapGestureRecognizer *)recognizer
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)fullScreenButtonTapped:(id)sender
{
    self.fullScreenButton.selected = !self.fullScreenButton.selected;
    [UIView animateWithDuration:0.15 animations:^{
        if (self.fullScreenButton.selected) {
            CGRect viewRect = self.view.bounds;
            CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
            viewRect.origin.y += MIN(statusBarFrame.size.height, statusBarFrame.size.width);
            viewRect.size.height -= MIN(statusBarFrame.size.height, statusBarFrame.size.width);
            self.mainDetailsView.frame = viewRect;
        } else {
            CGRect viewRect = [self getFrameForDetailView];
            viewRect.size.height = self.view.bounds.size.height;
            viewRect.origin.y = self.logoView.frame.size.height;
            viewRect.size.height -= self.logoView.frame.size.height;
            self.mainDetailsView.frame = viewRect;
        }
        self.logoView.alpha = !self.fullScreenButton.selected;
    }];
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    if ([navigationController isEqual:self.detailNavigationController]) {
        [self showActionBarForViewController:viewController];
    }
    
    __block BOOL isSearchHidden = YES;
    __weak JMCustomSplitViewController *weakSelf = self;
    
    [self performActionOnVisibleViewControllers:^(id viewController) {
        if ([viewController respondsToSelector:@selector(searchWithQuery:)]) {
            isSearchHidden = NO;
        }
        if ([viewController respondsToSelector:@selector(setBarTitle:)]) {
            [viewController setBarTitle:weakSelf.headerBarLabel];
        }
    } conformsToProtocol:@protocol(JMHeaderBarAdditions)];
    [self searchHidden:isSearchHidden];
}

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    if ([navigationController isEqual:self.detailNavigationController]) {
        [self showFullScreenButtonForViewController:viewController];
        [self showMenuLabelTitleForViewController:viewController];
    }
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
        if ([viewController respondsToSelector:@selector(didClearSearch)]) {
            [viewController didClearSearch];
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

- (void)showMasterView:(BOOL)show
{
    CGRect masterViewFrame = self.masterView.frame;
    masterViewFrame.size.width = show * kJMMasterViewWidth;
    self.masterView.frame = masterViewFrame;
    
    self.mainDetailsView.frame = [self getFrameForDetailView];
    
    CGRect actionBarPlaceholderFrame = self.actionBarPlaceholderView.frame;
    if (!show) {
        actionBarPlaceholderFrame.origin.x += kJMMasterViewWidth;
        actionBarPlaceholderFrame.size.width -= kJMMasterViewWidth;
    } else {
        actionBarPlaceholderFrame.origin.x = 0;
        actionBarPlaceholderFrame.size.width = self.mainDetailsView.frame.size.width;
    }
    self.actionBarPlaceholderView.frame = actionBarPlaceholderFrame;
}

- (void) showFullScreenButtonForViewController:(id)viewController
{
    [UIView beginAnimations:nil context:nil];
    if ([viewController respondsToSelector:@selector(shouldDisplayFullScreenButton)]) {
        self.fullScreenButton.alpha = [viewController shouldDisplayFullScreenButton] ? 1 : 0;
        [self.mainDetailsView bringSubviewToFront:self.fullScreenButton];
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

- (void) showMenuLabelTitleForViewController:(id)viewController
{
    if (viewController && [viewController respondsToSelector:@selector(titleForMenuLabel)]) {
        self.menuLabel.text = [viewController titleForMenuLabel];
    } else {
        self.menuLabel.text = self.menuTitle;
    }
}

- (CGRect) getFrameForDetailView{
    CGRect masterViewFrame = self.masterView.frame;
    
    CGRect mainDetailsViewFrame = self.view.bounds;
    mainDetailsViewFrame.origin.x = masterViewFrame.size.width;
    mainDetailsViewFrame.origin.y = self.logoView.frame.size.height;
    mainDetailsViewFrame.size.width -= masterViewFrame.size.width;
    mainDetailsViewFrame.size.height -= self.logoView.frame.size.height;

    return mainDetailsViewFrame;
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
