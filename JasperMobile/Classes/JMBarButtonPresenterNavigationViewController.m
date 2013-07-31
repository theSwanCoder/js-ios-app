/*
 * JasperMobile for iOS
 * Copyright (C) 2005 - 2013 Jaspersoft Corporation. All rights reserved.
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
//  JMBarButtonPresenterNavigationViewController.m
//  Jaspersoft Corporation
//

#import "JMBarButtonPresenterNavigationViewController.h"

@implementation JMBarButtonPresenterNavigationViewController

@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setSplitViewBarButtonItem:self.splitViewBarButtonItem];
}

#pragma mark - SplitViewBarButtonPresenterProtocol

- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    NSMutableArray *toolbarItems = [self.navigationBar.items mutableCopy] ?: [NSMutableArray array];
    if (_splitViewBarButtonItem) [toolbarItems removeObject:_splitViewBarButtonItem];
    if (splitViewBarButtonItem) [toolbarItems insertObject:splitViewBarButtonItem atIndex:0];
    self.navigationBar.items = toolbarItems;
    _splitViewBarButtonItem = splitViewBarButtonItem;
}

@end
