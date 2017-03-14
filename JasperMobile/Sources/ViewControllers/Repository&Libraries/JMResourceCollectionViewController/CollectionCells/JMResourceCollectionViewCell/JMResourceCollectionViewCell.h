/*
 * Copyright ©  2014 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksii Gubariev ogubarie@tibco.com
 @since 1.9
 */

extern NSString * kJMHorizontalResourceCell;
extern NSString * kJMGridResourceCell;

@class JMResourceCollectionViewCell;
@class JMResource;

@protocol JMResourceCollectionViewCellDelegate <NSObject>
@required
- (void) infoButtonDidTappedOnCell:(JMResourceCollectionViewCell *)cell;
@end


@interface JMResourceCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) JMResource *resource;
@property (nonatomic, weak) id <JMResourceCollectionViewCellDelegate> delegate;
@property (nonatomic, readonly) UIImage *thumbnailImage;
@end
