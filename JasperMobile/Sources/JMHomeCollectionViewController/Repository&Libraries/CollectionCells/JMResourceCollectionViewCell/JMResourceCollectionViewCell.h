//
//  JMResourceCollectionViewCell.h
//  JasperMobile
//
//  Created by Oleksii Gubariev on 8/20/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import <UIKit/UIKit.h>
extern NSString * kJMHorizontalResourceCell;
extern NSString * kJMGridResourceCell;

@class JMResourceCollectionViewCell;
@protocol JMResourceCollectionViewCellDelegate <NSObject>
@required
- (void) infoButtonDidTappedOnCell:(JMResourceCollectionViewCell *)cell;

@end


@interface JMResourceCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) JSResourceLookup *resourceLookup;
@property (nonatomic, weak) id <JMResourceCollectionViewCellDelegate> delegate;

@end
