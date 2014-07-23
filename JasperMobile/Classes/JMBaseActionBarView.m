//
//  JMBaseActionBarView.m
//  JasperMobile
//
//  Created by Oleksii Gubariev on 7/17/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "JMBaseActionBarView.h"
@implementation JMBaseActionBarView
- (void)awakeFromNib
{
    [super awakeFromNib];
    for (UIButton *actionButton in _actionBarButtons) {
        [actionButton setBackgroundColor:kJMDetailActionBarItemsBackgroundColor];
        [actionButton setTitleColor:kJMDetailActionBarItemsTextColor forState:UIControlStateNormal];
        [actionButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [actionButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];

        actionButton.titleLabel.font = [UIFont systemFontOfSize:17];
    }
}

@end
