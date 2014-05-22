//
//  JMResourceTableViewCell.h
//  JasperMobile
//
//  Created by Vlad Zavadsky on 5/21/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JMBaseResourceTableViewCell : UITableViewCell

+ (UIColor *)defaultColor;
+ (UIColor *)selectedColor;

@property (nonatomic, weak) IBOutlet UILabel *label;

@end
