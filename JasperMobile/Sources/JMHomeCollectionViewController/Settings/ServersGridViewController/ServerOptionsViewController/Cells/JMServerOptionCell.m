//
//  JMServerOptionCell.m
//  JasperMobile
//
//  Created by Oleksii Gubariev on 7/24/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "JMServerOptionCell.h"

@implementation JMServerOptionCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.textLabel.font = [JMFont tableViewCellTitleFont];
    self.textLabel.textColor = [UIColor darkGrayColor];
    
    self.detailTextLabel.font = [JMFont tableViewCellDetailErrorFont];
    self.detailTextLabel.textColor = [UIColor redColor];
    self.contentView.autoresizingMask |= UIViewAutoresizingFlexibleWidth;
}

- (void)setServerOption:(JMServerOption *)serverOption
{
    _serverOption = serverOption;
    
    self.textLabel.text = serverOption.titleString;
    [self updateDisplayingOfErrorMessage];
}

- (void) updateDisplayingOfErrorMessage
{
    self.detailTextLabel.text = self.serverOption.errorString;
    [UIView beginAnimations:nil context:nil];
    self.detailTextLabel.alpha = (self.serverOption.errorString.length == 0) ? 0 : 1;
    [UIView commitAnimations];
}


@end