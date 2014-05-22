//
//  JMResourceTableViewCell.m
//  JasperMobile
//
//  Created by Vlad Zavadsky on 5/21/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import "JMResourceTableViewCell.h"
#import "UIColor+RGBComponent.h"

@implementation JMResourceTableViewCell

+ (UIColor *)defaultColor
{
    static UIColor *defaultColor;
    if (!defaultColor) {
        defaultColor = [UIColor colorWithRed:[UIColor rgbComponent:46.0f]
                                       green:[UIColor rgbComponent:49.0f]
                                        blue:[UIColor rgbComponent:56.0f]
                                       alpha:1.0f];
    }
    return defaultColor;
}

+ (UIColor *)selectedColor
{
    static UIColor *selectedColor;
    if (!selectedColor) {
        selectedColor = [UIColor colorWithRed:[UIColor rgbComponent:72.0f]
                                        green:[UIColor rgbComponent:79.0f]
                                         blue:[UIColor rgbComponent:89.0f]
                                        alpha:1.0f];
    }
    return selectedColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if (!selected) {
        self.contentView.backgroundColor = [self.class defaultColor];
    } else {
        self.contentView.backgroundColor = [self.class selectedColor];
    }
}

@end
