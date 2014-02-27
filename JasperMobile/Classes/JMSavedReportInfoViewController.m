/*
 * JasperMobile for iOS
 * Copyright (C) 2011 - 2014 Jaspersoft Corporation. All rights reserved.
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
//  JMSavedReportInfoViewController.m
//  Jaspersoft Corporation
//

#import "JMSavedReportInfoViewController.h"
#import "JMLocalization.h"
#import "JMSavedReportModifyPopup.h"
#import "JMUtils.h"
#import <QuartzCore/QuartzCore.h>

@interface JMSavedReportInfoView : UIView
- (void)setText:(NSString *)text;
- (void)setDetailText:(NSString *)detailText;
@end

@implementation JMSavedReportInfoView

- (void)setText:(NSString *)text
{
    UILabel *textLabel = (UILabel *)[self viewWithTag:1];
    textLabel.text = text;
}

- (void)setDetailText:(NSString *)detailText
{
    UILabel *detailTextLabel = (UILabel *)[self viewWithTag:2];
    detailTextLabel.text = detailText;
}

@end

@interface JMSavedReportInfoViewController()
@property (nonatomic, weak) IBOutlet JMSavedReportInfoView *headerView;
@property (nonatomic, weak) IBOutlet JMSavedReportInfoView *reportNameView;
@property (nonatomic, weak) IBOutlet JMSavedReportInfoView *dateView;
@property (nonatomic, weak) IBOutlet JMSavedReportInfoView *sizeView;
@end

@implementation JMSavedReportInfoViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = JMCustomLocalizedString(@"savedreportinfo.title", nil);
    [self.headerView setText:JMCustomLocalizedString(@"savedreportinfo.sectionheader", nil)];
    [self.reportNameView setText:JMCustomLocalizedString(@"savedreportinfo.reportname", nil)];
    [self.reportNameView setDetailText:[self.fullReportName stringByDeletingPathExtension]];
    [self.dateView setText:JMCustomLocalizedString(@"savedreportinfo.date", nil)];
    [self.dateView setDetailText:self.date];
    [self.sizeView setText:JMCustomLocalizedString(@"savedreportinfo.size", nil)];
    [self.sizeView setDetailText:self.reportSize];

    CGFloat rgbComponent = 215.0f / 255.0f;
    CGColorRef borderColor = [[UIColor colorWithRed:rgbComponent green:rgbComponent blue:rgbComponent alpha:1.0f] CGColor];
    CGFloat borderWidth = 1.0f / [UIScreen mainScreen].scale;

    NSArray *views = @[self.headerView, self.reportNameView, self.dateView, self.sizeView];
    for (UIView *view in views) {
        view.layer.borderColor = borderColor;
        view.layer.borderWidth = borderWidth;
    }
}

#pragma mark - JMSavedReportModifyPopupDelegate

- (void)updateReportName:(NSString *)modifiedName
{
    NSString *extension = [self.fullReportName pathExtension];
    self.fullReportName = [modifiedName stringByAppendingPathExtension:extension];
    [self.reportNameView setDetailText:modifiedName];
}

#pragma mark - Actions

- (IBAction)modifyReportName:(id)sender
{
    [JMSavedReportModifyPopup presentInViewController:self fullReportName:self.fullReportName];
}

@end
