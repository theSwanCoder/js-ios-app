/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMMenuItemTableViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+RGBComponent.h"
#import "JMThemesManager.h"

@implementation JMMenuItemTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.textLabel.font = [[JMThemesManager sharedManager] menuItemTitleFont];
}

#pragma mark - LifeCycle
-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    // selected color
    UIView *selectedBackgroundView = [UIView new];
    selectedBackgroundView.frame = self.bounds;
    UIColor *selectedMenuColor = [UIColor сolorFromColor:[[JMThemesManager sharedManager] menuViewBackgroundColor] differents:0.25 increase:YES];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.colors = @[(id)[selectedMenuColor colorWithAlphaComponent:1.0f].CGColor, (id)[selectedMenuColor colorWithAlphaComponent:0.0f].CGColor];
    gradient.frame = selectedBackgroundView.frame;
    [gradient setStartPoint:CGPointMake(0.0, 0.5)];
    [gradient setEndPoint:CGPointMake(1.0, 0.5)];
    [selectedBackgroundView.layer insertSublayer:gradient atIndex:0];
    
    self.selectedBackgroundView = selectedBackgroundView;
}

-(void)setSelected:(BOOL)selected
{
    super.selected = selected;
    if (selected) {
        self.textLabel.textColor = [[JMThemesManager sharedManager] menuViewSelectedTextColor];
        self.imageView.image = self.menuItem.selectedItemIcon;
    } else {
        self.textLabel.textColor = [[JMThemesManager sharedManager] menuViewTextColor];
        self.imageView.image = self.menuItem.itemIcon;
    }
}

#pragma mark - Setters
- (void)setMenuItem:(JMMenuItem *)menuItem
{
    _menuItem = menuItem;
    self.textLabel.text = menuItem.itemTitle;
    self.imageView.image = menuItem.itemIcon;
}

@end
