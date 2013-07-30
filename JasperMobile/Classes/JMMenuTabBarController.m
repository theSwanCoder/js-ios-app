//
//  JMTabBarController.m
//  JasperMobile
//
//  Created by Vlad Zavadskii on 5/30/13.
//  Copyright (c) 2013 com.jaspersoft. All rights reserved.
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
