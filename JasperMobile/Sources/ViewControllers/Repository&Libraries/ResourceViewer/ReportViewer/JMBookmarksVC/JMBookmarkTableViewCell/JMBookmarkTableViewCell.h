/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.6
 */

@import UIKit;
@protocol JMBookmarkTableViewCellDelegate;

@interface JMBookmarkTableViewCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *anchorLabel;
@property (nonatomic, weak) IBOutlet UILabel *pageLabel;
@property (nonatomic, weak) IBOutlet UIButton *showBookmarksButton;
@property (nonatomic, weak) NSObject <JMBookmarkTableViewCellDelegate> *delegate;
@end

@protocol JMBookmarkTableViewCellDelegate
@optional
- (void)bookmarkCellDidTapShowBookmarksButton:(JMBookmarkTableViewCell *)cell;
@end
