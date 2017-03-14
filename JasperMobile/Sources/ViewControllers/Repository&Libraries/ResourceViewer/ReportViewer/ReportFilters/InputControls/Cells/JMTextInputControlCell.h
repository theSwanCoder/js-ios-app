/*
 * Copyright ©  2013 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Vlad Zavadskii vzavadskii@jaspersoft.com
 @author Oleksii Gubariev ogubarie@tibco.com
 @since 1.6
 */


#import "JMInputControlCell.h"
#import "JMTextField.h"

@interface JMTextInputControlCell : JMInputControlCell <UITextFieldDelegate>
@property (nonatomic, weak) IBOutlet JMTextField *textField;

@end
