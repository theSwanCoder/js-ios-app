//
//  JMServerOptionCell.h
//  JasperMobile
//
//  Created by Oleksii Gubariev on 7/24/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JMServerOption.h"

@class JMServerOptionCell;
@protocol JMServerOptionCellDelegate <NSObject>
@required
- (void) makeActiveButtonTappedOnTableViewCell:(JMServerOptionCell *)cell;

@end

@interface JMServerOptionCell : UITableViewCell
@property (nonatomic, strong) JMServerOption *serverOption;

@property (nonatomic, weak) IBOutlet id <JMServerOptionCellDelegate> delegate;


- (void) updateDisplayingOfErrorMessage;

@end
