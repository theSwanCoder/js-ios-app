/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.3
 */

@import UIKit;

@protocol JMScheduleCellDelegate;

@interface JMScheduleCell : UITableViewCell <UITextFieldDelegate>
@property(nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *valueTextField;
@property (nonatomic, weak) NSObject <JMScheduleCellDelegate> *delegate;
- (void)showErrorMessage:(NSString *)message;
@end

@protocol JMScheduleCellDelegate
@optional
- (void)scheduleCellDidStartChangeValue:(JMScheduleCell *)cell;
- (void)scheduleCell:(JMScheduleCell *)cell didChangeValue:(NSString *)newValue;
- (void)scheduleCellDidEndChangeValue:(JMScheduleCell *)cell;
@end
