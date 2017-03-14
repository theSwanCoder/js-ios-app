/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Olexandr Dakhno odahno@tibco.com
 @since 2.3
 */

@import UIKit;

@protocol JMExternalWindowDashboardControlsTableViewCellDelegate;

@interface JMExternalWindowDashboardControlsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *maximizeButton;
@property (weak, nonatomic) NSObject <JMExternalWindowDashboardControlsTableViewCellDelegate> *delegate;
@end

@protocol JMExternalWindowDashboardControlsTableViewCellDelegate
@optional
- (void)externalWindowDashboardControlsTableViewCellDidMaximize:(JMExternalWindowDashboardControlsTableViewCell *)cell;
- (void)externalWindowDashboardControlsTableViewCellDidMinimize:(JMExternalWindowDashboardControlsTableViewCell *)cell;
@end
