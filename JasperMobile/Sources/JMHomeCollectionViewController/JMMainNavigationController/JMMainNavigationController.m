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
    
    NSDictionary *textTitleOptions = nil;
    NSDictionary *barButtonTitleOptions = nil;

    if ([self.navigationBar respondsToSelector:@selector(setBarTintColor:)]) {
        [[UINavigationBar appearance] setBarTintColor: kJMMainNavigationBarBackgroundColor];
        [self.navigationBar setTintColor: [UIColor whiteColor]];
        textTitleOptions = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, [UIFont boldSystemFontOfSize:17], NSFontAttributeName, nil];
        barButtonTitleOptions = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor lightGrayColor], NSForegroundColorAttributeName, [UIFont systemFontOfSize:17], NSFontAttributeName, nil];
    } else {
        [self.navigationBar setTintColor: kJMMainNavigationBarBackgroundColor];
        [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -3) forBarMetrics:UIBarMetricsDefault];
        textTitleOptions = [NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], UITextAttributeTextColor, [UIFont boldSystemFontOfSize:17], UITextAttributeFont, [UIColor clearColor], UITextAttributeTextShadowColor, nil];
        barButtonTitleOptions = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:17], UITextAttributeFont, nil];
    }
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]  setTitleTextAttributes:barButtonTitleOptions forState:UIControlStateDisabled];
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]  setTitleTextAttributes:barButtonTitleOptions forState:UIControlStateNormal];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setBackgroundImage:[UIImage new] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];

    if (![JMUtils isFoundationNumber7OrHigher]) {
        UIImage *backButtonImage = [UIImage imageNamed:@"back_item.png"];
        UIImage *resizebleBackButtonImage = [backButtonImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, backButtonImage.size.width / 2, 0, backButtonImage.size.width / 2)];
        [[UIBarButtonItem appearance] setBackButtonBackgroundImage:resizebleBackButtonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    }
    
    [[UINavigationBar appearance] setTitleTextAttributes:textTitleOptions];
    [self.navigationBar setBarStyle:UIBarStyleDefault];
    
    self.navigationBar.opaque = YES;
    self.navigationBar.translucent = NO;
}

@end
