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
//  JMTabBarController.m
//  Jaspersoft Corporation
//

#import "JMMenuTabBarController.h"
#import "JMConstants.h"
#import "JMRotationBase.h"
#import "JMServerProfile.h"
#import "JMUtils.h"

@implementation JMMenuTabBarController
inject_default_rotation()

#pragma mark - UIViewController

- (void)awakeFromNib
{
    [self disableTabBar];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeServerProfile:)
                                                 name:kJMChangeServerProfileNotification
                                               object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // TODO: refactor without possilbe code duplication (as general solution for both devices)
    for (UITabBarItem *item in self.tabBar.items) {
        item.title = [JMUtils localizedTitleForMenuItemByTag:item.tag];
    }
}

#pragma mark - Private

// TODO: move to @protocol if there will be more than 1 implementation
- (void)disableTabBar
{
    for (UITabBarItem *item in self.tabBar.items) {
        if (item.tag != kJMServersMenuTag) {
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
    JMServerProfile *serverProfile = [[notification userInfo] objectForKey:kJMServerProfileKey];
    if (!serverProfile) {
        [self disableTabBar];
        [self setSelectedIndex:kJMServersMenuTag];
    } else {
        [self enableTabBar];
        [self setSelectedIndex:kJMLibraryMenuTag];
    }
}

@end
