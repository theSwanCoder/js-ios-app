//
//  JMSwitchMenu.m
//  JasperMobile
//
//  Created by Vlad Zavadsky on 3/27/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import "JMSwitchMenu.h"

@implementation JMSwitchMenu

- (void)numberOfResources:(NSInteger)count
{
    UILabel *label = (UILabel *) [self viewWithTag:1];
    label.text = [NSString stringWithFormat:@"%i Results", count];
    label.hidden = NO;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self configure];
    }
    
    return self;
}

#pragma mark - Private

- (void)configure
{
    UIView *resources = [self viewWithTag:1];
    resources.hidden = YES;
    
    UISegmentedControl *control = (UISegmentedControl *) [self viewWithTag:2];
    control.tintColor = [UIColor clearColor];
    UIImage *horizontalList = [UIImage imageNamed:@"horizontal_list.png"];
    UIImage *verticalList = [UIImage imageNamed:@"vertical_list.png"];
    control.frame = CGRectMake(self.frame.size.width - horizontalList.size.width, 0, horizontalList.size.width, horizontalList.size.height);
    [control setDividerImage:horizontalList forLeftSegmentState:UIControlStateSelected rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [control setDividerImage:verticalList forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
}

@end
