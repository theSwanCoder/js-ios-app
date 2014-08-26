//
//  JMMainNavigationController.m
//  JasperMobile
//
//  Created by Oleksii Gubariev on 8/6/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "JMMainNavigationController.h"

@interface JMMainNavigationController ()

@end

@implementation JMMainNavigationController
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UINavigationBar appearance] setBarTintColor: kJMMainNavigationBarBackgroundColor];
    [[UIToolbar appearance] setBarTintColor: kJMMainNavigationBarBackgroundColor];

    [self.navigationBar setTintColor: [UIColor whiteColor]];
    [self.toolbar setTintColor: [UIColor whiteColor]];
    
    NSDictionary *textTitleOptions = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, [UIFont boldSystemFontOfSize:17], NSFontAttributeName, nil];
    [[UINavigationBar appearance] setTitleTextAttributes:textTitleOptions];

    NSDictionary *barButtonTitleOptions = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor lightGrayColor], NSForegroundColorAttributeName, [UIFont systemFontOfSize:17], NSFontAttributeName, nil];
    [[UIBarButtonItem appearance] setTitleTextAttributes:barButtonTitleOptions forState:UIControlStateDisabled];
    [[UIBarButtonItem appearance] setTitleTextAttributes:barButtonTitleOptions forState:UIControlStateNormal];
    
    UIImage *backButtonImage = [UIImage imageNamed:@"back_item.png"];
    UIImage *resizebleBackButtonImage = [backButtonImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, backButtonImage.size.width, 0, backButtonImage.size.width)];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:resizebleBackButtonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    [self.navigationBar setBarStyle:UIBarStyleDefault];
    
    self.navigationBar.opaque = YES;
    self.navigationBar.translucent = NO;
    self.toolbar.translucent = NO;
}

@end
