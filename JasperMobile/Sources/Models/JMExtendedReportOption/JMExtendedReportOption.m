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
//  JMExtendedReportOption.m
//  TIBCO JasperMobile
//

#import "JMExtendedReportOption.h"

@implementation JMExtendedReportOption
+ (JMExtendedReportOption *)defaultReportOption
{
    JSReportOption *reportOption = [JSReportOption new];
    reportOption.label = JMCustomLocalizedString(@"report.viewer.report.options.active.option.title", nil);
    
    JMExtendedReportOption *defaultReportOption = [JMExtendedReportOption new];
    defaultReportOption.reportOption = reportOption;
    
    return defaultReportOption;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    if ([self isMemberOfClass: [JMExtendedReportOption class]]) {
        JMExtendedReportOption *newExtendedReportOption = [[self class] allocWithZone:zone];
        newExtendedReportOption.reportOption            = [self.reportOption copyWithZone:zone];
        if (self.inputControls) {
            newExtendedReportOption.inputControls  = [[NSArray alloc] initWithArray:self.inputControls copyItems:YES];
        }
        return newExtendedReportOption;
    } else {
        NSString *messageString = [NSString stringWithFormat:@"You need to implement \"copyWithZone:\" method in %@",NSStringFromClass([self class])];
        @throw [NSException exceptionWithName:@"Method implementation is missing" reason:messageString userInfo:nil];
    }
}
@end
