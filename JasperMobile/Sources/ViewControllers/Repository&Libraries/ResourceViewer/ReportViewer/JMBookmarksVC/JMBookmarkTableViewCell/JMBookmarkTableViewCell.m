/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMBookmarkTableViewCell.h"


@implementation JMBookmarkTableViewCell

- (IBAction)showBookmarksButtonDidTap:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(bookmarkCellDidTapShowBookmarksButton:)]) {
        [self.delegate bookmarkCellDidTapShowBookmarksButton:self];
    }
}

@end
