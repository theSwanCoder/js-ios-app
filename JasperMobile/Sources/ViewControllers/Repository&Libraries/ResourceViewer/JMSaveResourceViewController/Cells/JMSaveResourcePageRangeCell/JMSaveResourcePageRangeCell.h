/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksii Gubariev ogubarie@tibco.com
 @author Oleksandr Dahno odahno@tibco.com
 @since 1.9.1
*/


@protocol JMSaveResourcePageRangeCellDelegate;

@interface JMSaveResourcePageRangeCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) BOOL editable;
@property (nonatomic, weak) id<JMSaveResourcePageRangeCellDelegate> cellDelegate;
@end

@protocol JMSaveResourcePageRangeCellDelegate <NSObject>
@required
- (NSRange)availableRangeForPageRangeCell:(JMSaveResourcePageRangeCell *)cell;

@optional
- (void)pageRangeCell:(JMSaveResourcePageRangeCell *)cell didSelectPage:(NSInteger)page;
@end
