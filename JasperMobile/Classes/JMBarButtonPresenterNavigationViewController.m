//
//  JMBarButtonPresenterNavigationViewController.m
//  JasperMobile
//
//  Created by Vlad Zavadskii on 6/3/13.
//  Copyright (c) 2013 com.jaspersoft. All rights reserved.
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
