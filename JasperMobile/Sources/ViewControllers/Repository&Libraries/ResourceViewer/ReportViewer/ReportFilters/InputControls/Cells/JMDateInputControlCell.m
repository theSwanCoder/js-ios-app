/*
 * Copyright ©  2013 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMDateInputControlCell.h"
#import "UITableViewCell+Additions.h"
#import "JMUtils.h"
#import "JMLocalization.h"

@interface JMDateInputControlCell()

@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSDateFormatter *fieldDateFormatter;

@end

@implementation JMDateInputControlCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.textField.inputView = self.datePicker;
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.fieldDateFormatter = [[NSDateFormatter alloc] init];
}

- (void)setInputControlDescriptor:(JSInputControlDescriptor *)inputControlDescriptor
{
    [super setInputControlDescriptor:inputControlDescriptor];
    self.dateFormatter.dateFormat = inputControlDescriptor.dateTimeFormatValidationRule.format;

    if (inputControlDescriptor.type == kJS_ICD_TYPE_SINGLE_VALUE_DATE) {
        self.fieldDateFormatter = [JMUtils formatterForSimpleDate];
    } else if(inputControlDescriptor.type == kJS_ICD_TYPE_SINGLE_VALUE_TIME) {
        self.fieldDateFormatter = [JMUtils formatterForSimpleTime];
    } else if (inputControlDescriptor.type == kJS_ICD_TYPE_SINGLE_VALUE_DATETIME) {
        self.fieldDateFormatter = [JMUtils formatterForSimpleDateTime];
    }

    NSString *value = inputControlDescriptor.state.value;
    if (value.length) {
        NSDate *date = [self.dateFormatter dateFromString:value];
        if (!date) {
            date = [NSDate date];
        }
        self.datePicker.date = date;
        self.textField.text = [self.fieldDateFormatter stringFromDate:self.datePicker.date];
    }
}

- (UIDatePicker *)datePicker
{
    if (!_datePicker) {
        _datePicker = [[UIDatePicker alloc] init];
        _datePicker.datePickerMode = UIDatePickerModeDate;
        [_datePicker addTarget:self action:@selector(dateValueDidChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _datePicker;
}

- (NSArray *)leftInputAccessoryViewToolbarItems
{
    NSMutableArray *items = [NSMutableArray arrayWithArray:[super leftInputAccessoryViewToolbarItems]];
    UIBarButtonItem *unset = [[UIBarButtonItem alloc] initWithTitle:JMLocalizedString(@"report_viewer_options_ic_title_unset") style:UIBarButtonItemStylePlain target:self action:@selector(unset:)];
    [items addObject:unset];
    return items;
}

#pragma mark - UIDatePicker action
- (void) dateValueDidChanged:(id)sender
{
    self.textField.text = [self.fieldDateFormatter stringFromDate:self.datePicker.date];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // override a super realization with an empty realization
}

#pragma mark - Actions

- (void)doneButtonTapped:(id)sender
{
    [self updateValue:[self.dateFormatter stringFromDate:self.datePicker.date]];
    self.inputControlDescriptor.state.error = nil;
    [self updateDisplayingOfErrorMessage];

    [self.textField resignFirstResponder];
}

- (void)unset:(id)sender
{
    [self updateValue:nil];
    self.inputControlDescriptor.state.error = nil;
    [self updateDisplayingOfErrorMessage];

    self.textField.text = @"";

    [self.textField resignFirstResponder];
}

@end
