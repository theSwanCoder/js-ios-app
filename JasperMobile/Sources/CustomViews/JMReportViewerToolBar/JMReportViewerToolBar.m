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
#import "JMThemesManager.h"
#import "JaspersoftSDK.h"
#import "JMLocalization.h"

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
    
    if ([JMUtils isSystemVersionEqualOrUp9]) {
        self.currentPageField.inputAssistantItem.leadingBarButtonGroups = @[];
        self.currentPageField.inputAssistantItem.trailingBarButtonGroups = @[];
    }
    
    self.countOfPages = NSNotFound;
    [self addObservers];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.pickerView.delegate = nil;
    self.pickerView.dataSource = nil;
}

#pragma mark - Notifications
- (void)addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reportLoaderDidSetReport:)
                                                 name:JSReportLoaderDidSetReportNotification
                                               object:nil];
}

- (void)reportLoaderDidSetReport:(NSNotification *)notification
{
    [self addObseversForReport:notification.object];
}

- (void)addObseversForReport:(JSReport *)report
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:JSReportCountOfPagesDidChangeNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reportLoaderDidChangeCountOfPages:)
                                                 name:JSReportCountOfPagesDidChangeNotification
                                               object:report];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:JSReportCurrentPageDidChangeNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reportLoaderDidChangeCurrentPage:)
                                                 name:JSReportCurrentPageDidChangeNotification
                                               object:report];
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
    self.currentPageField.text = [NSString stringWithFormat:@"%ld", (long)self.currentPage];
    
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
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
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
