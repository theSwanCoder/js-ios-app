/*
 * JasperMobile for iOS
 * Copyright (C) 2011 - 2013 Jaspersoft Corporation. All rights reserved.
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
//  JMMenuTableViewController.m
//  Jaspersoft Corporation
//

#import "JMMenuTableViewController.h"
#import "JMRotationBase.h"
#import "JMSplitViewBarButtonPresenterProtocol.h"

@implementation JMMenuTableViewController
inject_default_rotation()

#pragma mark - Initialization

- (void)awakeFromNib {
    [super awakeFromNib];
    self.splitViewController.delegate = self;
}

#pragma mark - SplitViewBarButtonPresenterProtocol

- (id <JMSplitViewBarButtonPresenterProtocol>)splitViewBarButtonItemPresenter
{
    id detailsViewController = [self.splitViewController.viewControllers lastObject];
    if (![detailsViewController conformsToProtocol:@protocol(JMSplitViewBarButtonPresenterProtocol)]) {
        detailsViewController = nil;
    }
    
    return detailsViewController;
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
