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
//  JMDashboardParameter.m
//  TIBCO JasperMobile
//
#import "JMDashboardParameter.h"


@implementation JMDashboardParameter

#pragma mark - Life Cycle
- (instancetype)initWithData:(NSDictionary *)data
{
    self = [super init];
    if (self) {
        _identifier = data[@"id"];
        _values = data[@"value"];
    }
    return self;
}

+ (instancetype)parameterWithData:(NSDictionary *)data
{
    return [[self alloc] initWithData:data];
}

#pragma mark - Public API
- (void)updateValuesWithString:(NSString *)stringValues
{
    NSArray *values = [stringValues componentsSeparatedByString:@","];
    self.values = values;
}

- (NSString *)valuesAsString
{
    NSString *valuesAsString = self.values.firstObject;
    if (self.values.count > 1) {
        valuesAsString = [NSString stringWithFormat:@"%@, ", self.values.firstObject];
        for (int i = 1; i < self.values.count; i++) {
            if (i == self.values.count - 1) {
                valuesAsString = [valuesAsString stringByAppendingFormat:@"%@", self.values[i]];
            } else {
                valuesAsString = [valuesAsString stringByAppendingFormat:@"%@, ", self.values[i]];
            }
        }
    }
    return valuesAsString;
}

@end