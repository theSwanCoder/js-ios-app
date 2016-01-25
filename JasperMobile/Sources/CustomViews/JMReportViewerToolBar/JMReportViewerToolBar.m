/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2015 TIBCO Software, Inc. All rights reserved.
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

#import "JMReportViewerToolBar.h"

@interface JMReportViewerToolBar () <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *pageCountLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *pageCountActivityIndicator;
@property (weak, nonatomic) IBOutlet UITextField *currentPageField;

@property (weak, nonatomic) IBOutlet UIButton *firstButton;
@property (weak, nonatomic) IBOutlet UIButton *lastButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *previousButton;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (nonatomic, strong) UIView *inputAccessoryView;
@end

@implementation JMReportViewerToolBar

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.currentPageField.layer.cornerRadius = 4.f;
    self.currentPageField.layer.masksToBounds = YES;

    self.currentPageField.backgroundColor = [[JMThemesManager sharedManager] barsBackgroundColor];
    self.currentPageField.inputView = self.pickerView;
    self.currentPageField.inputAccessoryView = self.inputAccessoryView;
}

- (void)dealloc
{
    self.pickerView.delegate = nil;
    self.pickerView.dataSource = nil;
}

#pragma mark - Properties

- (void)setCountOfPages:(NSInteger)countOfPages
{
    _countOfPages = countOfPages;
    self.pageCountLabel.hidden = (_countOfPages == NSNotFound);
    self.pageCountActivityIndicator.hidden = (_countOfPages != NSNotFound);
    [self updatePages];
}

- (void)setCurrentPage:(NSInteger)currentPage
{
    _currentPage = currentPage;
    [self updatePages];
}

- (void) updatePages
{
    NSString *keyString = JMCustomLocalizedString(@"report.viewer.pagecount", nil);
    self.pageCountLabel.text = [NSString stringWithFormat:keyString, self.countOfPages];
    self.currentPageField.text = [NSString stringWithFormat:@"%ld", (long)self.currentPage];
    
    self.previousButton.enabled = self.currentPage > 1;
    self.firstButton.enabled = self.currentPage > 1;

    self.nextButton.enabled = self.currentPage < self.countOfPages;
    self.lastButton.enabled = self.currentPage < self.countOfPages && (_countOfPages != NSNotFound);
}

#pragma mark - Actions

- (IBAction)firstButtonTapped:(id)sender
{
    NSInteger currentPage = self.currentPage;
    NSInteger nextPage = 1;
    [self.toolbarDelegate toolbar:self changeFromPage:currentPage toPage:nextPage completion:^(BOOL success) {
        if (success) {
            self.currentPage = nextPage;
        }
    }];
}

- (IBAction)lastButtonTapped:(id)sender
{
    NSInteger currentPage = self.currentPage;
    NSInteger nextPage = self.countOfPages;
    [self.toolbarDelegate toolbar:self changeFromPage:currentPage toPage:nextPage completion:^(BOOL success) {
        if (success) {
            self.currentPage = nextPage;
        }
    }];
}

- (IBAction)nextButtonTapped:(id)sender
{
    NSInteger currentPage = self.currentPage;
    NSInteger nextPage = currentPage+1;
    [self.toolbarDelegate toolbar:self changeFromPage:currentPage toPage:nextPage completion:^(BOOL success) {
        if (success) {
            self.currentPage = nextPage;
        }
    }];
}

- (IBAction)previousButtonTapped:(id)sender
{
    NSInteger currentPage = self.currentPage;
    NSInteger nextPage = currentPage-1;
    [self.toolbarDelegate toolbar:self changeFromPage:currentPage toPage:nextPage completion:^(BOOL success) {
        if (success) {
            self.currentPage = nextPage;
        }
    }];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (self.countOfPages != NSNotFound) {
        [self.pickerView selectRow:self.currentPage - 1 inComponent:0 animated:NO];
        return YES;
    }
    return NO;
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.countOfPages;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [NSString stringWithFormat:@"%ld", (long)(row + 1)];
}

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

- (UIView *)inputAccessoryView
{
    if (!_inputAccessoryView) {
        CGRect viewFrame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 44);
        _inputAccessoryView = [[UIView alloc] initWithFrame:viewFrame];
        UIToolbar *toolbar = [self pickerToolbar];
        [_inputAccessoryView addSubview:toolbar];
    }
    return _inputAccessoryView;
}

#pragma mark - Actions

- (void)done:(id)sender
{
    NSInteger currentPage = self.currentPage;
    NSInteger nextPage = [self.pickerView selectedRowInComponent:0] + 1;
    self.previousButton.enabled = NO;
    self.firstButton.enabled = NO;
    self.nextButton.enabled = NO;
    self.lastButton.enabled = NO;
    [self.toolbarDelegate toolbar:self changeFromPage:currentPage toPage:nextPage completion:^(BOOL success) {
            self.previousButton.enabled = YES;
            self.firstButton.enabled = YES;
            self.nextButton.enabled = YES;
            self.lastButton.enabled = YES;
            if (success) {
                self.currentPage = nextPage;
            }
        }];

    [self hidePicker];
}

- (void)cancel:(id)sender
{
    [self hidePicker];
}

#pragma mark - Private

- (void)hidePicker
{
    [self.currentPageField resignFirstResponder];
}

@end
