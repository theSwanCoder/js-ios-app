//
//  JMListValueTableViewCell.h
//  JasperMobile
//
//  Created by Vlad Zavadskii on 7/16/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const kJMListValueTableViewCellIdentifier;

@interface JMListValueTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *valueLabel;

@end
