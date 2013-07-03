//
//  JMTabBarController.m
//  JasperMobile
//
//  Created by Vlad Zavadskii on 5/30/13.
//  Copyright (c) 2013 com.jaspersoft. All rights reserved.
//

#import "JMMenuTabBarController.h"
#import "JMUtils.h"

@implementation JMMenuTabBarController
inject_default_rotation()

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // TODO: refactor without possilbe code duplication (as general solution for both devices)
    for (UITabBarItem *item in self.tabBar.items) {
        item.title = [JMUtils localizedTitleForMenuItemByTag:item.tag];
    }
}

@end
