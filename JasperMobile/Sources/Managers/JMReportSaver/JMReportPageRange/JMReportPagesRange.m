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
//  JMReport.h
//  TIBCO JasperMobile
//

#import "JMReportPagesRange.h"

@implementation JMReportPagesRange

#pragma mark - Initializers
- (instancetype)initWithStartPage:(NSUInteger)startPage endPage:(NSUInteger)endPage
{
    self = [super init];
    if (self) {
        _startPage = startPage;
        _endPage = endPage;
    }
    return self;
}

+ (instancetype)rangeWithStartPage:(NSUInteger)startPage endPage:(NSUInteger)endPage
{
    return [[self alloc] initWithStartPage:startPage endPage:endPage];
}

#pragma mark - Custom Getters
- (NSString *)pagesFormat
{
    NSString *pagesFormat;
    if(self.startPage == 0) {
        pagesFormat = @"";
    } else if (self.startPage == self.endPage) {
        pagesFormat = [NSString stringWithFormat:@"%@", @(self.startPage)];
    } else {
        pagesFormat = [NSString stringWithFormat:@"%@-%@", @(self.startPage), @(self.endPage)];
    }
    return pagesFormat;
}

#pragma mark - Description
- (NSString *)description
{
    return [NSString stringWithFormat:@"PagesRange from: %@, to: %@", @(self.startPage), @(self.endPage)];
}

@end