/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksii Gubariev ogubarie@tibco.com
 @author Oleksandr Dahno odahno@tibco.com
 @since 1.9.1
*/

#import "JMTextField.h"

@protocol JMSaveResourceNameCellDelegate;

@interface JMSaveResourceNameCell : UITableViewCell <UITextFieldDelegate>
@property (nonatomic, weak) IBOutlet JMTextField *textField;
@property (nonatomic, weak) IBOutlet UILabel *errorLabel;
@property (nonatomic, weak) id<JMSaveResourceNameCellDelegate>cellDelegate;
@end

@protocol JMSaveResourceNameCellDelegate <NSObject>
@optional
- (void)nameCell:(JMSaveResourceNameCell *)cell didChangeResourceName:(NSString *)resourceName;
@end
