/*
 * Copyright ©  2014 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksii Gubariev ogubarie@tibco.com
 @since 1.9
 */

#import <UIKit/UIKit.h>
#import "JMServerOption.h"

@class JMServerOptionCell;
@protocol JMServerOptionCellDelegate <NSObject>
@required
- (void) reloadTableViewCell:(JMServerOptionCell *)cell;

@end

@interface JMServerOptionCell : UITableViewCell
@property (nonatomic, strong) JMServerOption *serverOption;

@property (nonatomic, weak) IBOutlet id <JMServerOptionCellDelegate> delegate;


- (void) updateDisplayingOfErrorMessage;

@end
