/*
 * Copyright ©  2013 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMDateTimeInputControlCell.h"
#import "UITableViewCell+Additions.h"
#import "JMLocalization.h"

@implementation JMDateTimeInputControlCell
- (NSArray *)rightInputAccessoryViewToolbarItems
{
    NSMutableArray *items = [NSMutableArray arrayWithArray:[super rightInputAccessoryViewToolbarItems]];
    UIBarButtonItem *datePickerSwitcher = [[UIBarButtonItem alloc] initWithTitle:JMLocalizedString(@"report_viewer_options_ic_title_time") style:UIBarButtonItemStylePlain target:self action:@selector(datePickerSwitched:)];
    [items insertObject:datePickerSwitcher atIndex:items.count - 1];
    return items;
}

#pragma mark - Actions

- (void)datePickerSwitched:(UIBarButtonItem *)sender
{
    if (self.datePicker.datePickerMode == UIDatePickerModeDate) {
        self.datePicker.datePickerMode = UIDatePickerModeTime;
        sender.title = JMLocalizedString(@"report_viewer_options_ic_title_date");
    } else {
        self.datePicker.datePickerMode = UIDatePickerModeDate;
        sender.title = JMLocalizedString(@"report_viewer_options_ic_title_time");
    }
}

@end
