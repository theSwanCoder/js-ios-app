//
//  UIViewController+JMMainNavigationItem.m
//  JasperMobile
//
//  Created by Oleksii Gubariev on 8/6/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "UIViewController+JMMainNavigationItem.h"
#import "JMMainNavigationController.h"
#import "JMMainNavigationItemProvider.h"

@implementation UIViewController (JMMainNavigationItem)

- (void)viewController:(id)viewController setNeedsUpdateMainNavigationItem:(JMMainNavigationItem)item
{
    if ([viewController conformsToProtocol:@protocol(JMMainNavigationItemProvider)]) {
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        JMMainNavigationController *initialViewController = (JMMainNavigationController *)[window rootViewController];
        NSLog(@"%@", initialViewController.topViewController);
        if (item & JMMainNavigationItem_Title && [viewController respondsToSelector:@selector(titleForMainNavigationItem)]) {
            initialViewController.topViewController.title =[viewController titleForMainNavigationItem];
        }
        if (item & JMMainNavigationItem_Left && [viewController respondsToSelector:@selector(leftItemsForMainNavigationItem)]) {
            initialViewController.topViewController.navigationItem.leftBarButtonItems =[viewController leftItemsForMainNavigationItem];
        }
        if (item & JMMainNavigationItem_Right && [viewController respondsToSelector:@selector(rightItemsForMainNavigationItem)]) {
            initialViewController.topViewController.navigationItem.rightBarButtonItems =[viewController rightItemsForMainNavigationItem];
        }
    }
}

@end
