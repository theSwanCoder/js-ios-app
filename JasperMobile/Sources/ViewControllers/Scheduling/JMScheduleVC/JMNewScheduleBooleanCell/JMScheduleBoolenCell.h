/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.3
 */

@import UIKit;

@protocol JMScheduleBoolenCellDelegate;

@interface JMScheduleBoolenCell : UITableViewCell
@property(nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UISwitch *uiSwitch;
@property (nonatomic, weak) NSObject <JMScheduleBoolenCellDelegate> *delegate;
@end

@protocol JMScheduleBoolenCellDelegate
@optional
- (void)scheduleBoolenCell:(JMScheduleBoolenCell *)cell didChangeValue:(BOOL)newValue;
@end
