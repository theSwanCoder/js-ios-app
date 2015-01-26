//
//  JMReportViewerPaginationToolbar.m
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 1/25/15.
//  Copyright (c) 2015 TIBCO JasperMobile. All rights reserved.
//

#import "JMReportViewerPaginationToolbar.h"

@interface JMReportViewerPaginationToolbar() <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UILabel *countOfPageLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@end

@implementation JMReportViewerPaginationToolbar

const NSInteger inputAccessoryViewEditingTextLabelTag = 10;

#pragma mark - Lifecycle

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
    self.textField.inputAccessoryView = [self accessoryView];
    
    // setup slider
    self.slider.minimumValue = 1;
    self.slider.value = self.currentPage;
    self.slider.userInteractionEnabled = NO;
    
    // activityIndicator
    [self.activityIndicator startAnimating];
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
    _currentPage = currentPage;
    
    if ([self.toolBarDelegate respondsToSelector:@selector(reportViewerPaginationToolbar:didChangePage:)]) {
        [self.toolBarDelegate reportViewerPaginationToolbar:self didChangePage:_currentPage];
    }
}

#pragma mark - Actions
- (IBAction)sliderDidChangeValue:(UISlider *)sender
{
    self.textField.text = @(floorf(sender.value)).stringValue;
}

- (IBAction)sliderDidFinishChangeValue:(UISlider *)sender
{
    self.currentPage = floorf(sender.value);
}

- (void)cancel:(id)sender
{
    self.textField.text = @(self.currentPage).stringValue;
    [self hideKeyboard];
}

- (void)done:(id)sender
{
    NSInteger newCurrentPage = self.textField.text.integerValue;
    if (newCurrentPage > self.countOfPages) {
        NSString *title = [NSString stringWithFormat:JMCustomLocalizedString(@"detail.report.viewer.wrongNumberOfCurrentPage", nil), @(self.countOfPages).stringValue];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:nil delegate:nil cancelButtonTitle:JMCustomLocalizedString(@"dialog.button.ok", nil) otherButtonTitles: nil];
        [alert show];
    } else {
        self.currentPage = newCurrentPage;
        self.slider.value = newCurrentPage;
        [self hideKeyboard];
    }
}

#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    UILabel *label = (UILabel *)[textField.inputAccessoryView viewWithTag:inputAccessoryViewEditingTextLabelTag];
    label.text = textField.text;
    
    if ([self.toolBarDelegate respondsToSelector:@selector(reportViewerPaginationToolbarWillBeginChangePage:)]) {
        [self.toolBarDelegate reportViewerPaginationToolbarWillBeginChangePage:self];
    }
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *newNumber = [formatter numberFromString:string];
    if (!newNumber && string.length) {
        return NO;
    }
    
    UILabel *label = (UILabel *)[textField.inputAccessoryView viewWithTag:inputAccessoryViewEditingTextLabelTag];
    NSMutableString *currentText = [textField.text mutableCopy];
    if (range.length) {
        // remove symbol
        [currentText replaceCharactersInRange:range withString:@""];
    } else {
        // add symbol
        [currentText appendString:string];
    }
    label.text = currentText;
    
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Private methods
- (UIView *)accessoryView
{
    UIToolbar *accessoryView = [UIToolbar new];
    [accessoryView sizeToFit];
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [accessoryView setItems:@[flexibleSpace, cancel, done]];
    
    // setup label that show current page
    CGRect accessoryViewBounds = accessoryView.bounds;
    CGFloat textFieldWidth = CGRectGetWidth(self.textField.frame);
    CGFloat textFieldHeight = CGRectGetHeight(self.textField.frame);
    CGFloat labelOriginX = 8;
    CGFloat labelOriginY = accessoryViewBounds.size.height/2 - textFieldHeight/2;
    CGRect labelFrame = CGRectMake(labelOriginX, labelOriginY, textFieldWidth, textFieldHeight);
    UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
    label.layer.cornerRadius = 4.f;
    label.layer.masksToBounds = YES;
    label.tag = inputAccessoryViewEditingTextLabelTag;
    label.backgroundColor = self.textField.backgroundColor;
    label.text = self.textField.text;
    label.textColor = self.textField.textColor;
    label.textAlignment = self.textField.textAlignment;
    [accessoryView addSubview:label];
    
    return accessoryView;
}

- (void)hideKeyboard
{
    [self.textField resignFirstResponder];
}

@end
