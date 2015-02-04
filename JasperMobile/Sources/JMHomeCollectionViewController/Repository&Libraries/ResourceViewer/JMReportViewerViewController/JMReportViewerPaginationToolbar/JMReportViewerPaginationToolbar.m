//
//  JMReportViewerPaginationToolbar.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 1/25/15.
//  Copyright (c) 2015 TIBCO JasperMobile. All rights reserved.
//

#import "JMReportViewerPaginationToolbar.h"

@interface JMReportViewerPaginationToolbar() <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UILabel *countOfPageLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation JMReportViewerPaginationToolbar

const NSInteger inputAccessoryViewEditingTextLabelTag = 10;

#pragma mark - Lifecycle

-(void)dealloc
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    // init values
    _currentPage = 1;
    _countOfPages = 1;
    
    // setup textField
    self.textField.layer.cornerRadius = 4.f;
    self.textField.layer.masksToBounds = YES;
    self.textField.backgroundColor = kJMSearchBarBackgroundColor;
    self.textField.text = @(self.currentPage).stringValue;
    self.textField.keyboardType = UIKeyboardTypeNumberPad;
    self.textField.inputView = [self inputView];
    self.textField.inputAccessoryView = [self accessoryView];

    // setup slider
    self.slider.minimumValue = 1;
    self.slider.value = self.currentPage;
    self.slider.userInteractionEnabled = NO;
    
    // activityIndicator
    [self.activityIndicator startAnimating];
}

#pragma mark - Public API
- (void)updateCurrentPageWithPageNumber:(NSUInteger)pageNumber
{
    _currentPage = pageNumber;
    self.textField.text = @(pageNumber).stringValue;
    self.slider.value = pageNumber;
}

#pragma mark - Properties
- (void)setCountOfPages:(NSInteger)countOfPages
{
    if (countOfPages == NSNotFound || countOfPages == 0) {
        return;
    }
    
    [self.activityIndicator stopAnimating];
    self.slider.userInteractionEnabled = YES;
    _countOfPages = countOfPages;
    if (countOfPages) {
        self.countOfPageLabel.text = @(countOfPages).stringValue;
        self.slider.maximumValue = countOfPages;
    }
}

-(void)setCurrentPage:(NSInteger)currentPage
{
    if (_currentPage != currentPage) {
        _currentPage = currentPage;
        [self updateCurrentPageWithPageNumber:currentPage];
        
        if ([self.toolBarDelegate respondsToSelector:@selector(reportViewerPaginationToolbar:didChangePage:)]) {
            [self.toolBarDelegate reportViewerPaginationToolbar:self didChangePage:_currentPage];
        }
    }
}

#pragma mark - Actions
- (IBAction)sliderDidChangeValue:(UISlider *)sender
{
    self.currentPage = floorf(sender.value);
}

- (IBAction)sliderDidFinishChangeValue:(UISlider *)sender
{
    self.currentPage = floorf(sender.value);
}

- (void)cancel:(id)sender
{
    [self updateCurrentPageWithPageNumber:self.currentPage];
    [self hideKeyboard];
}

- (void)done:(id)sender
{
    UIPickerView *pickerView = (UIPickerView *)self.textField.inputView;
    self.currentPage = [pickerView selectedRowInComponent:0] + 1;
    [self hideKeyboard];
}

#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    UIPickerView *pickerView = (UIPickerView *)self.textField.inputView;
    [pickerView selectRow:self.currentPage - 1 inComponent:0 animated:NO];
    
    if ([self.toolBarDelegate respondsToSelector:@selector(reportViewerPaginationToolbarWillBeginChangePage:)]) {
        [self.toolBarDelegate reportViewerPaginationToolbarWillBeginChangePage:self];
    }
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
    return [NSString stringWithFormat:@"%zd", row + 1];
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

#pragma mark - Private methods
- (UIView *)inputView
{
    UIPickerView *inputView = [UIPickerView new];
    [inputView sizeToFit];
    inputView.delegate = self;
    inputView.dataSource = self;
    
    return inputView;
}

- (UIView *)accessoryView
{
    UIToolbar *accessoryView = [UIToolbar new];
    [accessoryView sizeToFit];
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [accessoryView setItems:@[flexibleSpace, cancel, done]];
    return accessoryView;
}

- (void)hideKeyboard
{
    [self.textField resignFirstResponder];
}

@end
