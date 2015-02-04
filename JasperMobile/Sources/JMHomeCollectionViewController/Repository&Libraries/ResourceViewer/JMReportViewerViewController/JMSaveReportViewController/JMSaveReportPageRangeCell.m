/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2014 TIBCO Software, Inc. All rights reserved.
 * http://community.jaspersoft.com/project/jaspermobile-ios
 *
 * Unless you have purchased a commercial license agreement from Jaspersoft,
 * the following license terms apply:
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/lgpl>.
 */


//
//  JMSaveReportPageRangeCell.h
//  TIBCO JasperMobile
//

/**
@since 1.9.1
*/

#import "JMSaveReportPageRangeCell.h"

@interface JMSaveReportPageRangeCell() <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
@property (weak, nonatomic) UIPickerView *pickerView;
@property (nonatomic, weak) IBOutlet UITextField *textField;
@end

@implementation JMSaveReportPageRangeCell

#pragma mark - Lifecycle

- (void)awakeFromNib
{
    UIPickerView *pickerView = [UIPickerView new];

    self.textField.inputView = pickerView;
    self.textField.inputAccessoryView = [self pickerToolbar];

    self.pickerView = pickerView;
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

#pragma mark - Public API
- (void)updateCurrentPagePosition
{
    [self.pickerView selectRow:(self.currentPage - 1)
                   inComponent:0
                      animated:YES];
}

#pragma mark - Custom Setters
- (void)setCurrentPage:(NSInteger)currentPage
{
    _currentPage = currentPage;
    self.textField.text = @(currentPage).stringValue;
}


#pragma mark - Picker
- (UIToolbar *)pickerToolbar
{
    UIToolbar *pickerToolbar = [[UIToolbar alloc] init];
    [pickerToolbar sizeToFit];

    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [pickerToolbar setItems:@[flexibleSpace, cancel, done]];

    return pickerToolbar;
}

- (void)done:(id)sender
{
    if ([self.cellDelegate respondsToSelector:@selector(pageRangeCell:didSelectPage:)]) {
        [self.cellDelegate pageRangeCell:self didSelectPage:@([self.pickerView selectedRowInComponent:0] + 1)];
    }
    [self hidePicker];
}

- (void)cancel:(id)sender
{
    [self hidePicker];
}

- (void)hidePicker
{
    [self.textField resignFirstResponder];
}

#pragma mark - UIPickeViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.pageCount;
}

#pragma mark - UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [NSString stringWithFormat:@"%@", @(row + 1)];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self updateCurrentPagePosition];
    return YES;
}

@end
