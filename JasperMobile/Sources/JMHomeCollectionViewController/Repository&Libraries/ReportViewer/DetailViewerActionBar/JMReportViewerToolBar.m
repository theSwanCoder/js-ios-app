//
//  JMReportViewerToolBar.m
//  JasperMobile
//
//  Created by Oleksii Gubariev on 7/17/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "JMReportViewerToolBar.h"

@interface JMReportViewerToolBar () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *pageTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *pageCountLabel;
@property (weak, nonatomic) IBOutlet UITextField *currentPageField;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *firstButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *lastButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *previousButton;

@end

@implementation JMReportViewerToolBar

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.pageTitleLabel.text = JMCustomLocalizedString(@"action.report.viewer.page", nil);
    self.currentPageField.backgroundColor = kJMMainNavigationBarBackgroundColor;
    self.countOfPages = 1;
    self.currentPage = 1;
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
    self.currentPageField.text = [NSString stringWithFormat:@"%d", self.currentPage];
    
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
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:@"1234567890"] invertedSet];
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    
    NSMutableString *newString = [NSMutableString stringWithString:textField.text];
    [newString replaceCharactersInRange:range withString:string];
    NSInteger currentValue = [newString integerValue];

    return (([string isEqualToString:filtered]) && (NSLocationInRange(currentValue, self.availableRange)));
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if ([textField.text integerValue]) {
        self.currentPage = [textField.text integerValue];
        [self.toolbarDelegate pageDidChangedOnToolbar];
    } else {
        self.currentPageField.text = [NSString stringWithFormat:@"%d", self.currentPage];
    }
}

@end
