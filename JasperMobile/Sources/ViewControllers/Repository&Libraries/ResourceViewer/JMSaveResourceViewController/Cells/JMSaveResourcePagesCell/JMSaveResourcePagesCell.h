/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksii Gubariev ogubarie@tibco.com
 @since 2.1
 */

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, JMSaveResourcePagesType) {
    JMSaveResourcePagesType_All = 0,
    JMSaveResourcePagesType_Range
};

@class JMSaveResourcePagesCell;
@protocol JMSaveResourcePagesCellDelegate <NSObject>
@required
- (void)pagesCell:(JMSaveResourcePagesCell *)pagesCell didChangedPagesType:(JMSaveResourcePagesType)pagesType;

@end

@interface JMSaveResourcePagesCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, assign) JMSaveResourcePagesType pagesType;
@property (nonatomic, weak) id <JMSaveResourcePagesCellDelegate> cellDelegate;

@end
