//
//  JMResourceCell.h
//  JasperMobile
//
//  Created by Vlad Zavadsky on 3/28/14.
//  Copyright (c) 2014 com.jaspersoft. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kJMResourceCellIdentifier @"ResourceCell"

@interface JMResourceCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *label;
@property (nonatomic, weak) IBOutlet UILabel *desc;
@property (nonatomic, weak) IBOutlet UILabel *creationDate;
@property (nonatomic, readonly, weak) IBOutlet UIImageView *imageView;

@end
