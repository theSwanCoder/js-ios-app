/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2016 TIBCO Software, Inc. All rights reserved.
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
//  JMReportChartType.m
//  TIBCO JasperMobile
//

#import "JMReportChartType.h"

@interface JMReportChartType()
@property (nonatomic, strong, readwrite) NSString *imageName;
@end

@implementation JMReportChartType

- (NSString *)imageName
{
    if (!_imageName) {
        _imageName = [self convertName:self.name];
    }
    return _imageName;
}

- (NSString *)convertName:(NSString *)name
{
    // Commented those image names without images.
    NSString *convertedName;
    if ([name isEqualToString:@"Bar"]) {
        convertedName = @"bar";
    } else if ([name isEqualToString:@"Area"]) {
        convertedName = @"area";
    } else if ([name isEqualToString:@"Column"]) {
        convertedName = @"column";
    } else if ([name isEqualToString:@"Line"]) {
        convertedName = @"line";
    } else if ([name isEqualToString:@"Spline"]) {
        convertedName = @"spline";
    } else if ([name isEqualToString:@"AreaSpline"]) {
        convertedName = @"area_spline";
    } else if ([name isEqualToString:@"StackedBar"]) {
        convertedName = @"stacked_bar";
    } else if ([name isEqualToString:@"StackedColumn"]) {
        convertedName = @"stacked_column";
    } else if ([name isEqualToString:@"StackedLine"]) {
        convertedName = @"unknown_chart";
//        convertedName = @"stacked_line";
    } else if ([name isEqualToString:@"StackedArea"]) {
        convertedName = @"stacked_area";
    } else if ([name isEqualToString:@"StackedSpline"]) {
        convertedName = @"unknown_chart";
//        convertedName = @"stacked_spline";
    } else if ([name isEqualToString:@"StackedAreaSpline"]) {
        convertedName = @"unknown_chart";
//        convertedName = @"stacked_area_spline";
    } else if ([name isEqualToString:@"StackedPercentBar"]) {
        convertedName = @"unknown_chart";
//        convertedName = @"stacked_percent_bar";
    } else if ([name isEqualToString:@"StackedPercentColumn"]) {
        convertedName = @"unknown_chart";
//        convertedName = @"stacked_percent_column";
    } else if ([name isEqualToString:@"StackedPercentLine"]) {
        convertedName = @"unknown_chart";
//        convertedName = @"stacked_percent_line";
    } else if ([name isEqualToString:@"StackedPercentArea"]) {
        convertedName = @"unknown_chart";
//        convertedName = @"stacked_percent_area";
    } else if ([name isEqualToString:@"StackedPercentSpline"]) {
        convertedName = @"unknown_chart";
//        convertedName = @"stacked_percent_spline";
    } else if ([name isEqualToString:@"StackedPercentAreaSpline"]) {
        convertedName = @"unknown_chart";
//        convertedName = @"stacked_percent_area_spline";
    } else if ([name isEqualToString:@"Pie"]) {
        convertedName = @"pie";
    } else if ([name isEqualToString:@"DualLevelPie"]) {
        convertedName = @"dual_level_pie";
    } else if ([name isEqualToString:@"TimeSeriesLine"]) {
        convertedName = @"unknown_chart";
//        convertedName = @"time_series_line";
    } else if ([name isEqualToString:@"TimeSeriesArea"]) {
        convertedName = @"unknown_chart";
//        convertedName = @"time_series_area";
    } else if ([name isEqualToString:@"TimeSeriesSpline"]) {
        convertedName = @"unknown_chart";
//        convertedName = @"time_series_spline";
    } else if ([name isEqualToString:@"TimeSeriesAreaSpline"]) {
        convertedName = @"unknown_chart";
//        convertedName = @"time_series_area_spline";
    } else if ([name isEqualToString:@"ColumnLine"]) {
        convertedName = @"column_line";
    } else if ([name isEqualToString:@"ColumnSpline"]) {
        convertedName = @"column_spline";
    } else if ([name isEqualToString:@"StackedColumnLine"]) {
        convertedName = @"stacked_column_line";
    } else if ([name isEqualToString:@"StackedColumnSpline"]) {
        convertedName = @"stacked_column_spline";
    } else if ([name isEqualToString:@"MultiAxisLine"]) {
        convertedName = @"multi_axis_line";
    } else if ([name isEqualToString:@"MultiAxisSpline"]) {
        convertedName = @"multi_axis_spline";
    } else if ([name isEqualToString:@"MultiAxisColumn"]) {
        convertedName = @"multi_axis_column";
    } else if ([name isEqualToString:@"Scatter"]) {
        convertedName = @"scatter";
    } else if ([name isEqualToString:@"Bubble"]) {
        convertedName = @"bubble";
    } else if ([name isEqualToString:@"SpiderColumn"]) {
        convertedName = @"spider_column";
    } else if ([name isEqualToString:@"SpiderLine"]) {
        convertedName = @"spider_line";
    } else if ([name isEqualToString:@"SpiderArea"]) {
        convertedName = @"spider_area";
    } else if ([name isEqualToString:@"HeatMap"]) {
        convertedName = @"heat_map";
    } else if ([name isEqualToString:@"TimeSeriesHeatMap"]) {
        convertedName = @"time_series_heat_map";
    } else if ([name isEqualToString:@"SemiPie"]) {
        convertedName = @"semi_pie";
    } else if ([name isEqualToString:@"DualMeasureTreeMap"]) {
        convertedName = @"dual_measure_tree_map";
    } else if ([name isEqualToString:@"TreeMap"]) {
        convertedName = @"tree_map";
    } else if ([name isEqualToString:@"OneParentTreeMap"]) {
        convertedName = @"unknown_chart";
//        convertedName = @"one_parent_tree_map";
    } else {
        convertedName = @"unknown_chart";
    }
    return convertedName;
}

@end