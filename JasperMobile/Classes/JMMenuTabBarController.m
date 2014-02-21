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
//  JMMenuTabBarController.m
//  Jaspersoft Corporation
//

#import "JMMenuTabBarController.h"
#import "JMConstants.h"
#import "JMRefreshable.h"
#import "JMRotationBase.h"
#import "JMServerProfile.h"
#import "JMUtils.h"

@interface JMMenuTabBarController()
@property (nonatomic, weak) id lastSelectedViewController;

- (void)enableTabBar;
- (void)disableTabBar;
@end

@implementation JMMenuTabBarController
inject_default_rotation()

#pragma mark - UIViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self disableTabBar];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeServerProfile:)
                                                 name:kJMChangeServerProfileNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(selectMenu:)
                                                 name:kJMSelectMenuNotification
                                               object:nil];
    [self disableTabBar];
    self.selectedIndex = kJMServersMenuTag;
    self.delegate = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    for (UITabBarItem *item in self.tabBar.items) {
        item.title = [JMUtils localizedTitleForMenuItemByTag:item.tag];
    }
}

#pragma mark - UITabBarController

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    UIViewController *selectedViewController = [viewController.childViewControllers objectAtIndex:0];

    if (self.lastSelectedViewController == selectedViewController &&
        [selectedViewController conformsToProtocol:@protocol(JMRefreshable)]) {
        [self.lastSelectedViewController refresh];
    }
    
    self.lastSelectedViewController = selectedViewController;
}

#pragma mark - Private

- (void)disableTabBar
{
    for (UITabBarItem *item in self.tabBar.items) {
        if (item.tag != kJMServersMenuTag &&
            item.tag != kJMSavedReportsMenuTag) {
            item.enabled = NO;
        }
    }
}

- (void)enableTabBar
{
    for (UITabBarItem *item in self.tabBar.items) {
        item.enabled = YES;
    }
}

- (void)changeServerProfile:(NSNotification *)notification
{
    NSUInteger index;
    NSDictionary *userInfo = notification.userInfo;
    
    if ([userInfo objectForKey:kJMNotUpdateMenuKey]) return;
    
    JMServerProfile *serverProfile = [userInfo objectForKey:kJMServerProfileKey];
    
    if (!serverProfile) {
        [self disableTabBar];
        index = kJMServersMenuTag;
    } else {
        [self enableTabBar];
        index = kJMRepositoryMenuTag;
    }
    
    self.selectedIndex = index;
}

- (void)selectMenu:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NSInteger menuTag = [[userInfo objectForKey:kJMMenuTag] integerValue];
    [self setSelectedIndex:menuTag];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    [super setSelectedIndex:selectedIndex];
    UIViewController *selectedViewController = [self.viewControllers objectAtIndex:selectedIndex];
    [self tabBarController:self didSelectViewController:selectedViewController];
}

@end
