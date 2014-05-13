//
//  JMResourceCell.m
//  JasperMobile
//
//  Created by Vlad Zavadsky on 3/28/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import "JMResourceTableViewCell.h"

@implementation JMResourceTableViewCell

- (void)layoutSubviews
{
    [super layoutSubviews];    
    CGSize size = self.imageView.frame.size;
    self.imageView.frame = CGRectMake(0, 0, size.width, size.height);
}

@end
