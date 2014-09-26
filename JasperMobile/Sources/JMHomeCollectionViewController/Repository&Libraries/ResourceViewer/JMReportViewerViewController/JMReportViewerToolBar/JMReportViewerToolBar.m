//
//  JMReportViewerToolBar.m
//  JasperMobile
//
//  Created by Oleksii Gubariev on 7/17/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "JMReportViewerToolBar.h"

@interface JMReportViewerToolBar () <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *pageTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *pageCountLabel;
@property (weak, nonatomic) IBOutlet UITextField *currentPageField;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *firstButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *lastButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *previousButton;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;


@end

@implementation JMReportViewerToolBar

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.pageTitleLabel.text = JMCustomLocalizedString(@"action.report.viewer.page", nil);
    self.currentPageField.backgroundColor = kJMMainNavigationBarBackgroundColor;
    self.countOfPages = 1;
    self.currentPage = 1;
    self.currentPageField.inputView = self.pickerView;
    self.currentPageField.inputAccessoryView = [self pickerToolbar];
}

#pragma mark - Properties
- (NSRange)availableRange
{
    return NSMakeRange(0, self.countOfPages);
}

- (void)setCountOfPages:(NSInteger)countOfPages
{
    _countOfPages = countOfPages;
    [self updatePages];
}

- (void)setCurrentPage:(NSInteger)currentPage
{
    _currentPage = currentPage;
    [self updatePages];
}

- (void) updatePages
{
    NSString *keyString = JMCustomLocalizedString(@"action.report.viewer.pagecount", nil);
    self.pageCountLabel.text = [NSString stringWithFormat:keyString, self.countOfPages];
    self.currentPageField.text = [NSString stringWithFormat:@"%ld", (long)self.currentPage];
    
    self.previousButton.enabled = !(self.currentPage <= 1);
    self.firstButton.enabled = !(self.currentPage <= 1);

    self.nextButton.enabled = !(self.currentPage >= self.countOfPages);
    self.lastButton.enabled = !(self.currentPage >= self.countOfPages);
}

#pragma mark - Actions

- (IBAction)firstButtonTapped:(id)sender
{
    self.currentPage = 1;
    [self.toolbarDelegate pageDidChangedOnToolbar];
}

- (IBAction)lastButtonTapped:(id)sender
{
    self.currentPage = self.countOfPages;
    [self.toolbarDelegate pageDidChangedOnToolbar];
}

- (IBAction)nextButtonTapped:(id)sender
{
    self.currentPage ++;
    [self.toolbarDelegate pageDidChangedOnToolbar];
}

- (IBAction)previousButtonTapped:(id)sender
{
    self.currentPage --;
    [self.toolbarDelegate pageDidChangedOnToolbar];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self.pickerView selectRow:self.currentPage - 1 inComponent:0 animated:NO];
    return YES;
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
    return [NSString stringWithFormat:@"%ld", row + 1];
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

#pragma mark - Actions

- (void)done:(id)sender
{
    self.currentPage = [self.pickerView selectedRowInComponent:0] + 1;
    [self.toolbarDelegate pageDidChangedOnToolbar];

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
