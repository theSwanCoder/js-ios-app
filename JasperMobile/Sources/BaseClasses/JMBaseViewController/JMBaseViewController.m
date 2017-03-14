/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


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
            backItemTitle = JMLocalizedString(@"back_button_title");
        }
    }

    UIImage *backButtonImage = [UIImage imageNamed:@"back_item"];
    UIImage *resizebleBackButtonImage = [backButtonImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, backButtonImage.size.width, 0, backButtonImage.size.width) resizingMode:UIImageResizingModeStretch];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:[self croppedBackButtonTitle:backItemTitle]
                                                                 style:UIBarButtonItemStylePlain
                                                                target:target
                                                                action:action];
    [backItem setBackgroundImage:resizebleBackButtonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    backItem.accessibilityIdentifier = @"JMBackButtonAccessibilityId";
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

    if (( (backItemOffset + backItemTextWidth) > (viewWidth - titleTextWidth) / 2 ) && ![backButtonTitle isEqualToString:JMLocalizedString(@"back_button_title")]) {
        return [self croppedBackButtonTitle:JMLocalizedString(@"back_button_title")];
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
