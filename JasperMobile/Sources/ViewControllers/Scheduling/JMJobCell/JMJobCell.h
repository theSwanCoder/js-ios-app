//
// Created by Aleksandr Dakhno on 11/30/15.
// Copyright (c) 2015 TIBCO JasperMobile. All rights reserved.
//

@protocol JMJobCellDelegate;

@interface JMJobCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) NSObject <JMJobCellDelegate> *delegate;
@end

@protocol JMJobCellDelegate
@optional
- (void)jobCellDidReceiveDeleteJobAction:(JMJobCell *)cell;
@end