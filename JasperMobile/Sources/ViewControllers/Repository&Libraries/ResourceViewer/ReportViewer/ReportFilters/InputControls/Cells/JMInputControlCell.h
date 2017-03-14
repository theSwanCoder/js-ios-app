/*
 * Copyright ©  2013 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Vlad Zavadskii vzavadskii@jaspersoft.com
 @author Oleksii Gubariev ogubarie@tibco.com
 @since 1.6
 */

@import UIKit;
#import "JaspersoftSDK.h"

@class JMInputControlCell;
@protocol JMInputControlCellDelegate <NSObject>
@required
- (void) reloadTableViewCell:(JMInputControlCell *)cell;

- (void) inputControlCellDidChangedValue:(JMInputControlCell *)cell;

- (void) updatedInputControlsValuesWithDescriptor:(JSInputControlDescriptor *)descriptor;
@end

@interface JMInputControlCell : UITableViewCell 

@property (nonatomic, strong) JSInputControlDescriptor *inputControlDescriptor;
@property (nonatomic, weak) id <JMInputControlCellDelegate> delegate;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *errorLabel;

- (void) updateDisplayingOfErrorMessage;
- (void) updateValue:(NSString *)newValue;
- (void) setEnabledCell:(BOOL) enabled;

@end
