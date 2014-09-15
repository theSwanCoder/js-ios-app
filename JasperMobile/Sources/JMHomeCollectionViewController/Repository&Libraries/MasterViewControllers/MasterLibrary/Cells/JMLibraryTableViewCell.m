//
//  JMMenuTableViewCell.m
//  JasperMobile
//
//  Created by Vlad Zavadskii on 5/8/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import "JMLibraryTableViewCell.h"

@implementation JMLibraryTableViewCell
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    self.contentView.backgroundColor = selected ? kJMMasterResourceCellSelectedBackgroundColor : kJMMasterResourceCellDefaultBackgroundColor;
    self.leftSideView.hidden = !selected;
}

@end
