//
//  JMResourceTableViewCell.h
//  JasperMobile
//
//  Created by Vlad Zavadsky on 5/21/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JMResourceTableViewCell : UITableViewCell

+ (UIColor *)defaultColor;
+ (UIColor *)selectedColor;

@property (nonatomic, weak) IBOutlet UILabel *title;

@end
