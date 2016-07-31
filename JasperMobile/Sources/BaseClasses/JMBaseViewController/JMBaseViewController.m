/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2015 TIBCO Software, Inc. All rights reserved.
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
//  JMBaseViewController.m
//  TIBCO JasperMobile
//

#import "JMBaseViewController.h"
#import "JMAnalyticsManager.h"
#import "JMUtils.h"
#import "JMLocalization.h"
#import "JMThemesManager.h"

@interface JMBaseViewController()

@end

@implementation JMBaseViewController

- (void)dealloc
{
    JMLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
}

#pragma mark - UIViewController LifeCycle
- (void)viewDidAppear:(BOOL)animated
{
    self.screenName = [self screenNameForAnalytics];

    [super viewDidAppear:animated];
}

#pragma mark - Work with navigation items
- (UIBarButtonItem *)backButtonWithTitle:(NSString *)title
                                  target:(id)target
                                  action:(SEL)action
{
    NSString *backItemTitle = title;
    if (!backItemTitle) {
        NSArray *viewControllers = self.navigationController.viewControllers;
        NSUInteger index = [viewControllers indexOfObject:self];
        if ((index != NSNotFound) && (viewControllers.count - 1) >= index) {
            UIViewController *previousViewController = viewControllers[index - 1];
            backItemTitle = previousViewController.title;
        } else {
            backItemTitle = JMCustomLocalizedString(@"back_button_title", nil);
        }
    }

    UIImage *backButtonImage = [UIImage imageNamed:@"back_item"];
    UIImage *resizebleBackButtonImage = [backButtonImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, backButtonImage.size.width, 0, backButtonImage.size.width) resizingMode:UIImageResizingModeStretch];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:[self croppedBackButtonTitle:backItemTitle]
                                                                 style:UIBarButtonItemStylePlain
                                                                target:target
                                                                action:action];
    [backItem setBackgroundImage:resizebleBackButtonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    return backItem;
}

- (NSString *)croppedBackButtonTitle:(NSString *)backButtonTitle
{
    // detect backButton text width to truncate with '...'
    NSDictionary *textAttributes = @{NSFontAttributeName : [[JMThemesManager sharedManager] navigationBarTitleFont]};
    CGSize titleTextSize = [self.title sizeWithAttributes:textAttributes];
    CGFloat titleTextWidth = ceilf(titleTextSize.width);
    CGSize backItemTextSize = [backButtonTitle sizeWithAttributes:textAttributes];
    CGFloat backItemTextWidth = ceilf(backItemTextSize.width);
    CGFloat backItemOffset = 12;

    CGFloat viewWidth = CGRectGetWidth(self.navigationController.navigationBar.frame);

    if (( (backItemOffset + backItemTextWidth) > (viewWidth - titleTextWidth) / 2 ) && ![backButtonTitle isEqualToString:JMCustomLocalizedString(@"back_button_title", nil)]) {
        return [self croppedBackButtonTitle:JMCustomLocalizedString(@"back_button_title", nil)];
    }
    return backButtonTitle;
}

#pragma mark - Analytics
- (NSString *)screenNameForAnalytics
{
    NSString *screenName = [[JMAnalyticsManager sharedManager] mapClassNameToReadableName:NSStringFromClass(self.class)];
    return [screenName stringByAppendingString:[self additionalsToScreenName]];
}

- (NSString *)additionalsToScreenName
{
    return @"";
}

@end