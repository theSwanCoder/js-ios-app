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
#import "JaspersoftSDK.h"


@interface JMReportViewerToolBar () <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *pageCountLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *pageCountActivityIndicator;
@property (weak, nonatomic) IBOutlet UITextField *currentPageField;

@property (weak, nonatomic) IBOutlet UIButton *firstButton;
@property (weak, nonatomic) IBOutlet UIButton *lastButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *previousButton;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@end

@implementation JMReportViewerToolBar

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.currentPageField.layer.cornerRadius = 4.f;
    self.currentPageField.layer.masksToBounds = YES;

    self.currentPageField.backgroundColor = [[JMThemesManager sharedManager] barsBackgroundColor];
    self.currentPageField.inputView = self.pickerView;
    self.currentPageField.inputAccessoryView = [self pickerToolbar];

    [self.firstButton setAccessibility:YES withTextKey:@"dialog_title_first" identifier:JMButtonFirstAccessibilityId];
    [self.previousButton setAccessibility:YES withTextKey:@"dialog_title_previous" identifier:JMButtonPreviousAccessibilityId];
    [self.nextButton setAccessibility:YES withTextKey:@"dialog_title_next" identifier:JMButtonNextAccessibilityId];
    [self.lastButton setAccessibility:YES withTextKey:@"dialog_title_last" identifier:JMButtonLastAccessibilityId];
    
    self.currentPageField.isAccessibilityElement = YES;
    self.currentPageField.accessibilityIdentifier = JMReportViewerPageCurrentPageAccessibilityId;

    self.pageCountLabel.isAccessibilityElement = YES;
    self.pageCountLabel.accessibilityIdentifier = JMReportViewerPageCountOfPagesLabelAccessibilityId;

    [self addObsevers];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.pickerView.delegate = nil;
    self.pickerView.dataSource = nil;
}

#pragma mark - Notifications
- (void)addObsevers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reportLoaderDidChangeCountOfPages:)
                                                 name:JSReportCountOfPagesDidChangeNotification
                                               object:nil]; // TODO: restrict object with an correct report object

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reportLoaderDidChangeCurrentPage:)
                                                 name:JSReportCurrentPageDidChangeNotification
                                               object:nil]; // TODO: restrict object with an correct report object
}

- (void)reportLoaderDidChangeCountOfPages:(NSNotification *)notification
{
    JSReport *report = notification.object;
    self.countOfPages = report.countOfPages;
}

- (void)reportLoaderDidChangeCurrentPage:(NSNotification *)notification
{
    JSReport *report = notification.object;
    self.currentPage = report.currentPage;
}

#pragma mark - Properties
- (BOOL)enable
{
    return self.userInteractionEnabled;
}

- (void)setEnable:(BOOL)enable
{
    self.userInteractionEnabled = enable;
}

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
    NSString *keyString = JMLocalizedString(@"report_viewer_pagecount");
    self.pageCountLabel.text = [NSString stringWithFormat:keyString, self.countOfPages];
    [JMLocalization localizeStringForKey:@"report_viewer_count_of_pages_is" completion:^(NSString *localizedString, NSString *languageString) {
        NSString *accessibilityLabel = [NSString stringWithFormat:localizedString, self.countOfPages];
        self.pageCountLabel.accessibilityLabel = accessibilityLabel;
        self.pageCountLabel.accessibilityLanguage = languageString;
    }];
    
    self.currentPageField.text = [NSString stringWithFormat:@"%ld", (long)self.currentPage];
    [JMLocalization localizeStringForKey:@"report_viewer_current_page_is" completion:^(NSString *localizedString, NSString *languageString) {
        NSString *accessibilityLabel = [NSString stringWithFormat:localizedString, self.currentPage];
        self.currentPageField.accessibilityLabel = accessibilityLabel;
        self.currentPageField.accessibilityLanguage = languageString;
    }];

    self.previousButton.enabled = self.currentPage > 1;
    self.firstButton.enabled = self.currentPage > 1;

    self.nextButton.enabled = self.currentPage < self.countOfPages;
    self.lastButton.enabled = self.currentPage < self.countOfPages && (_countOfPages != NSNotFound);
}

#pragma mark - Actions

- (IBAction)firstButtonTapped:(id)sender
{
    [self.toolbarDelegate toolbar:self changeFromPage:self.currentPage toPage:1];
}

- (IBAction)lastButtonTapped:(id)sender
{
    [self.toolbarDelegate toolbar:self changeFromPage:self.currentPage toPage:self.countOfPages];
}

- (IBAction)nextButtonTapped:(id)sender
{
    [self.toolbarDelegate toolbar:self changeFromPage:self.currentPage toPage:(self.currentPage + 1)];
}

- (IBAction)previousButtonTapped:(id)sender
{
    [self.toolbarDelegate toolbar:self changeFromPage:self.currentPage toPage:(self.currentPage - 1)];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    UIPickerView *pickerView = self.inputAccessoryView.subviews.firstObject;
    [pickerView sizeToFit];

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
    [cancel setAccessibility:YES withTextKey:@"dialog_button_cancel" identifier:JMButtonCancelAccessibilityId];
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    [done setAccessibility:YES withTextKey:@"dialog_button_done" identifier:JMButtonDoneAccessibilityId];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [pickerToolbar setItems:@[cancel, flexibleSpace, done]];

    return pickerToolbar;
}

#pragma mark - Actions

- (void)done:(id)sender
{
    NSInteger nextPage = [self.pickerView selectedRowInComponent:0] + 1;
    [self.toolbarDelegate toolbar:self changeFromPage:self.currentPage toPage:nextPage];

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
