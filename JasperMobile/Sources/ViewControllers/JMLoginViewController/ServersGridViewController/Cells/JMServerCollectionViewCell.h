/*
 * Copyright ©  2014 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksii Gubariev ogubarie@tibco.com
 @since 1.9
 */

#import <UIKit/UIKit.h>
#import "JMServerProfile.h"

@class JMServerCollectionViewCell;

@protocol JMServerCollectionViewCellDelegate <NSObject>
@required
- (void)deleteServerProfileForCell:(JMServerCollectionViewCell *)cell;
- (void)cloneServerProfileForCell:(JMServerCollectionViewCell *)cell;
- (void)editServerProfileForCell:(JMServerCollectionViewCell *)cell;
@end

@interface JMServerCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) JMServerProfile *serverProfile;
@property (nonatomic, weak) id <JMServerCollectionViewCellDelegate> delegate;
- (void) editServerProfile:(id)sender;
- (void) deleteServerProfile:(id)sender;
@end
