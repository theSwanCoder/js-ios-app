/*
 * Copyright ©  2013 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMNumberInputControlCell.h"

@implementation JMNumberInputControlCell

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([string isEqualToString:@"-"]) {
        if (range.location != 0 || [textField.text rangeOfString:@"-"].location != NSNotFound) {
            return NO;
        }
    }

    NSString *decimalSeparator = [[NSLocale currentLocale] objectForKey:NSLocaleDecimalSeparator];
    if ([string isEqualToString:decimalSeparator]) {
        NSInteger decimalSeparatorExpectedLocation = 0;
        if ([textField.text rangeOfString:@"-"].location != NSNotFound) {
            decimalSeparatorExpectedLocation = 1;
        }
        
        if (range.location == decimalSeparatorExpectedLocation || [textField.text rangeOfString:decimalSeparator].location != NSNotFound) {
            return NO;
        }
    }
    
    NSString *stringSet = [NSString stringWithFormat:@"-1234567890%@", decimalSeparator];
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:stringSet] invertedSet];
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    return [string isEqualToString:filtered];
}

@end
