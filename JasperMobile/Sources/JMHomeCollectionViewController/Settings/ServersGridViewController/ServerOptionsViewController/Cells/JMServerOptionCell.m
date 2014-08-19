//
//  JMServerOptionCell.m
//  JasperMobile
//
//  Created by Oleksii Gubariev on 7/24/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "JMServerOptionCell.h"

@implementation JMServerOptionCell

- (void)setServerOption:(JMServerOption *)serverOption
{
    _serverOption = serverOption;
    self.titleLabel.text = serverOption.titleString;
    [self updateDisplayingOfErrorMessage];
}

- (void) updateDisplayingOfErrorMessage
{
    self.errorLabel.text = self.serverOption.errorString;
    [UIView beginAnimations:nil context:nil];
    self.errorLabel.alpha = (self.serverOption.errorString.length == 0) ? 0 : 1;
    CGRect titleLabelFrame = self.titleLabel.frame;
    titleLabelFrame.origin.y = (self.serverOption.errorString.length == 0) ? 14 :6;
    self.titleLabel.frame = titleLabelFrame;
    [UIView commitAnimations];
}


@end
