/*
 * Copyright ©  2014 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMTimeInputControlCell.h"

@implementation JMTimeInputControlCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.datePicker.datePickerMode = UIDatePickerModeTime;
}
@end
