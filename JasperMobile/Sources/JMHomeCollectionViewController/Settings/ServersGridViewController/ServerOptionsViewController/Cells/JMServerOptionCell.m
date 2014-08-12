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
}
@end
