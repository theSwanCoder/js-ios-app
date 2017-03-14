/*
 * Copyright ©  2014 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksii Gubariev ogubarie@tibco.com
 @since 1.9
 */

#import <UIKit/UIKit.h>
#import "JMServerOptionCell.h"

@interface JMBooleanServerOptionCell : JMServerOptionCell
@property (weak, nonatomic) IBOutlet UIButton *checkBoxButton;

- (IBAction)checkButtonTapped:(id)sender;

@end
