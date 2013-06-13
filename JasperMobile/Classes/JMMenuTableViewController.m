//
//  JMMenuTableViewController.m
//  JasperMobile
//
//  Created by Vlad Zavadskii on 6/3/13.
//  Copyright (c) 2013 com.jaspersoft. All rights reserved.
//

#import "JMMenuTableViewController.h"
#import "JMSplitViewBarButtonPresenterProtocol.h"
#import "JMRotationBase.h"
#import "JMLocalization.h"

@implementation JMMenuTableViewController
inject_default_rotation();

#pragma mark - Initialization

- (void)awakeFromNib {
    [super awakeFromNib];
    self.splitViewController.delegate = self;
}

#pragma mark - SplitViewBarButtonPresenterProtocol

- (id <JMSplitViewBarButtonPresenterProtocol>)splitViewBarButtonItemPresenter
{
    id detailsViewContoller = [self.splitViewController.viewControllers lastObject];
    if (![detailsViewContoller conformsToProtocol:@protocol(JMSplitViewBarButtonPresenterProtocol)]) {
        detailsViewContoller = nil;
    }
    
    return detailsViewContoller;
}

#pragma mark - SplitViewController delegate

- (BOOL)splitViewController:(UISplitViewController *)svc
   shouldHideViewController:(UIViewController *)vc
              inOrientation:(UIInterfaceOrientation)orientation
{
//    return [self splitViewBarButtonItemPresenter] ?  UIInterfaceOrientationIsPortrait(orientation) : NO;
    return NO;
}

- (void)splitViewController:(UISplitViewController *)svc
     willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)pc
{
//    barButtonItem.title = JMCustomLocalizedString(@"main.menu", nil);
//    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = barButtonItem;
}

- (void)splitViewController:(UISplitViewController *)svc
     willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
//    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = nil;
}


@end
