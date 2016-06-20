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


//
//  JMReportPartViewToolbar.m
//  TIBCO JasperMobile
//

#import "JMReportPartViewToolbar.h"
#import "JMReportPart.h"

@interface JMReportPartViewToolbar()
@property (weak, nonatomic) IBOutlet UIButton *previousButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@end

@implementation JMReportPartViewToolbar

#pragma mark - Life Cycle
- (void)awakeFromNib
{
    [super awakeFromNib];

    self.previousButton.enabled = NO;
    if (self.parts.count == 1) {
        self.nextButton.enabled = NO;
    }
}

#pragma mark - Custom Accessors
- (void)setCurrentPart:(JMReportPart *)currentPart
{
    _currentPart = currentPart;
    self.titleLabel.text = _currentPart.name;
}

- (void)setParts:(NSArray<JMReportPart *> *)parts
{
    _parts = parts;
    self.currentPart = _parts.firstObject;
}

#pragma mark - Actions
- (IBAction)previousButtonDidTap:(id)sender
{
    self.currentPart = [self previousPart];
    if ([self.delegate respondsToSelector:@selector(reportPartViewToolbarDidChangePart:)]) {
        [self.delegate reportPartViewToolbarDidChangePart:self];
    }
}

- (IBAction)nextButtonDidTap:(id)sender
{
    self.currentPart = [self nextPart];
    if ([self.delegate respondsToSelector:@selector(reportPartViewToolbarDidChangePart:)]) {
        [self.delegate reportPartViewToolbarDidChangePart:self];
    }
}

#pragma mark - Helpers
- (JMReportPart *)previousPart
{
    NSUInteger currentIndex = [self.parts indexOfObject:self.currentPart];
    NSUInteger previousIndex = currentIndex - 1;
    if (previousIndex == 0) {
        self.previousButton.enabled = NO;
    }
    self.nextButton.enabled = YES;
    JMReportPart *part = self.parts[previousIndex];
    return part;
}

- (JMReportPart *)nextPart
{
    NSUInteger currentIndex = [self.parts indexOfObject:self.currentPart];
    NSUInteger nextIndex = currentIndex + 1;
    if (nextIndex == self.parts.count - 1) {
        self.nextButton.enabled = NO;
    }
    self.previousButton.enabled = YES;
    JMReportPart *part = self.parts[nextIndex];
    return part;
}

@end