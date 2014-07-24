//
//  JMServerOptionCell.h
//  JasperMobile
//
//  Created by Oleksii Gubariev on 7/24/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JMServerOption.h"


@interface JMServerOptionCell : UITableViewCell
@property (nonatomic, strong) JMServerOption *serverOption;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

@end
