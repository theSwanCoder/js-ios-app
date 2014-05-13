//
//  JMMenuTableViewCell.m
//  JasperMobile
//
//  Created by Vlad Zavadskii on 5/8/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import "JMLibraryTableViewCell.h"
#import "UIColor+RGBComponent.h"

@implementation JMLibraryTableViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if (selected) {
        self.contentView.backgroundColor = [UIColor colorWithRed:[UIColor rgbComponent:72.0f]
                                                           green:[UIColor rgbComponent:79.0f]
                                                            blue:[UIColor rgbComponent:89.0f]
                                                           alpha:1.0f];
        [self.circleImageView setImage:[UIImage imageNamed:@"circle_selected.png"]];
    } else {
        self.contentView.backgroundColor = [UIColor colorWithRed:[UIColor rgbComponent:50.0f]
                                                           green:[UIColor rgbComponent:52.0f]
                                                            blue:[UIColor rgbComponent:59.0f]
                                                           alpha:1.0f];
        [self.circleImageView setImage:[UIImage imageNamed:@"circle.png"]];
    }
}

@end
