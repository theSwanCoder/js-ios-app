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
//  JMAdhocViewerVC.h
//  TIBCO JasperMobile
//

#import "JMResource.h"
#import "JMAdhocViewerVC.h"
#import "JMWebViewManager.h"
#import "JMVIZWebEnvironment.h"
#import "JMJavascriptRequest.h"
#import "Charts-Swift.h"

NSString *const kJMAdhocViewWebEnvironemntId = @"kJMAdhocViewWebEnvironemntId";

@interface JMAdhocViewerVC()
//@property (nonatomic, strong) JMResource *resource;
@property (weak, nonatomic) IBOutlet BarChartView *barChartView;
@end

@implementation JMAdhocViewerVC

#pragma mark - Lifecycle
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UIViewController Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self startResourceViewing];
}

- (void)startResourceViewing
{
//    __weak __typeof(self) weakSelf = self;
//    [((JMVIZWebEnvironment *)self.webEnvironment) prepareWithCompletion:^(BOOL isReady, NSError *error) {
//        __typeof(self) strongSelf = weakSelf;
//        if (isReady) {
//            JMLog(@"ready");
//            JMLog(@"resource uri: %@", strongSelf.resource.resourceLookup.uri);
//            [strongSelf loadAdhocViewWithCompletion:^(BOOL success, NSError *error) {
//                if (error) {
//                    JMLog(@"error of loading adhoc view");
//                } else {
//                    JMLog(@"success of loading adhoc view");
//                }
//            }];
//        } else {
//            JMLog(@"not ready");
//        }
//    }];
    [self showChart];
}

- (void)showChart
{
    JMLog(@"%@ - %@", self, NSStringFromSelector(_cmd));
//    NSArray <NSString *>*months = @[@"Jan", @"Feb", @"Mar", @"Apr", @"May", @"Jun", @"Jul", @"Aug", @"Sep", @"Oct", @"Nov", @"Dec"];
//    NSArray <NSNumber *>*values = @[@20.0, @4.0, @6.0, @3.0, @12.0, @16.0, @4.0, @18.0, @2.0, @4.0, @5.0, @4.0];
    
//    NSArray <NSString *>*xAxisValues = @[
//                                         @"Deluxe Supermarket",
//                                         @"Gourmet Supermarket",
//                                         @"Mid-Size Grocery",
//                                         @"Supermarket"
//                                         ];
    NSArray <NSString *>*xAxisValues = @[
                                         @"Deluxe Supermarket (Canada)",
                                         @"Deluxe Supermarket (Mexico)",
                                         @"Deluxe Supermarket (USA)",
                                         @"Gourmet Supermarket (Canada)",
                                         @"Gourmet Supermarket (Mexico)",
                                         @"Gourmet Supermarket (USA)",
                                         @"Mid-Size Grocery (Canada)",
                                         @"Mid-Size Grocery (Mexico)",
                                         @"Mid-Size Grocery (USA)",
                                         @"Supermarket (Canada)",
                                         @"Supermarket (Mexico)",
                                         @"Supermarket (USA)"
                                         ];
    
    BarChartData *chartData = [[BarChartData alloc] initWithXVals:xAxisValues
                                                         dataSets:@[
                                                                    [self firstDataSetWithXAxisValues:xAxisValues],
                                                                    [self secondDataSetWithXAxisValues:xAxisValues],
                                                                    [self thirdDataSetWithXAxisValues:xAxisValues]
                                                                    ]];
    self.barChartView.data = chartData;
    self.barChartView.xAxis.enabled = NO;
//    self.barChartView.xAxis.labelPosition = XAxisLabelPositionBottom;
//    self.barChartView.xAxis.labelRotationAngle = -45;
    self.barChartView.legend.position = ChartLegendPositionBelowChartCenter;
    self.barChartView.legend.form = ChartLegendFormSquare;
    self.barChartView.descriptionText = @"";
    JMLog(@"isGrouped: %@", chartData.isGrouped ? @"YES" : @"NO");
    self.barChartView.rightAxis.enabled = NO;
//    ChartYAxis *leftAxis = self.barChartView.leftAxis;
//    leftAxis.axisMaxValue = 2000;
//    leftAxis.axisMinValue = 0.0;
    
    
//    ChartYAxis *rightAxis = self.barChartView.rightAxis;
//    rightAxis.axisMaxValue = 1.0;
//    rightAxis.axisMinValue = 0.0;
}

- (BarChartDataSet *)firstDataSetWithXAxisValues:(NSArray *)xAxisValues
{
    NSArray <NSNumber *>*values = @[
                                    @316.67, 
                                    @958.0, 
                                    @553.36, 
                                    @1828.03, 
                                    @159.05, 
                                    @255.5,
                                    @414.55,
                                    @97.35,
                                    @271.95,
                                    @38.8,
                                    @408.1,
                                    @388.7,
                                    @1227.1,
                                    @1615.8,
                                    // @4266.48 - // TOTAL
                                    ];
    NSArray <NSNumber *>*normalizedValues = [self normalizeValues:values];
    NSMutableArray <BarChartDataEntry *>*dataEntries = [NSMutableArray array];
    for (NSNumber *value in normalizedValues) {
        NSInteger index = [normalizedValues indexOfObject:value];
        BarChartDataEntry *dataEntry = [[BarChartDataEntry alloc] initWithValue:normalizedValues[index].doubleValue 
                                                                         xIndex:index];
        [dataEntries addObject:dataEntry];
    }
    BarChartDataSet *chartDataSet = [[BarChartDataSet alloc] initWithYVals:dataEntries 
                                                                     label:@"Store Sales 2013"];
    chartDataSet.colors = @[[UIColor blackColor]];
    return chartDataSet;
}

- (BarChartDataSet *)secondDataSetWithXAxisValues:(NSArray *)xAxisValues
{
    NSArray <NSNumber *>*values = @[
                                    @130.5991, 
                                    @374.1945, 
                                    @223.8714, 
                                    @728.665, 
                                    @68.1635, 
                                    @99.8315,
                                    @167.995,
                                    @36.7765,
                                    @105.0405,
                                    @14.37,
                                    @156.187,
                                    @158.1315,
                                    @495.9335,
                                    @654.065,
                                    // @1706.912 - // TOTAL
                                    ];
    NSArray <NSNumber *>*normalizedValues = [self normalizeValues:values];
    NSMutableArray <BarChartDataEntry *>*dataEntries = [NSMutableArray array];
    for (NSNumber *value in normalizedValues) {
        NSInteger index = [normalizedValues indexOfObject:value];
        BarChartDataEntry *dataEntry = [[BarChartDataEntry alloc] initWithValue:normalizedValues[index].doubleValue 
                                                                         xIndex:index];
        [dataEntries addObject:dataEntry];
    }
    BarChartDataSet *chartDataSet = [[BarChartDataSet alloc] initWithYVals:dataEntries label:@"Store Cost 2013"];
    chartDataSet.colors = @[[UIColor blueColor]];
    return chartDataSet;
}

- (BarChartDataSet *)thirdDataSetWithXAxisValues:(NSArray *)xAxisValues
{
    NSArray <NSNumber *>*values = @[
                                    @0.8563462703357563,
                                    @0.8928271866810314,
                                    @0.6330944470377184,
                                    @0.7890173011216982,
                                    @0.8367881644850372,
                                    @0.8296963084197128,
                                    @0.8324029750048191,
                                    @0.5651340996168582,
                                    @0.5187539223671735,
                                    @0.0,
                                    @0.5859321719978693,
                                    @0.6787836030189892,
                                    @0.9433643149826642,
                                    @0.8624904719303602,
                                    //@0.7923236818515335 - // TOTAL
                                    ];
    NSArray <NSNumber *>*normalizedValues = [self normalizeValues:values];
    NSMutableArray <BarChartDataEntry *>*dataEntries = [NSMutableArray array];
    for (NSNumber *value in normalizedValues) {
        NSInteger index = [normalizedValues indexOfObject:value];
        BarChartDataEntry *dataEntry = [[BarChartDataEntry alloc] initWithValue:normalizedValues[index].doubleValue 
                                                                         xIndex:index];
        [dataEntries addObject:dataEntry];
    }
    BarChartDataSet *chartDataSet = [[BarChartDataSet alloc] initWithYVals:dataEntries label:@"$ Per Sq Foot"];
    chartDataSet.colors = @[[UIColor redColor]];
    return chartDataSet;
}

- (NSArray <NSNumber *>*)normalizeValues:(NSArray <NSNumber *>*)values
{
    NSNumber *maxNumber = [self findMaxValueInValues:values];
    CGFloat k = 1.0;
    if (maxNumber.doubleValue < 1.0) {
        k = 100;
    } else if (maxNumber.doubleValue > 1.0 && maxNumber.doubleValue <= 100.0) {
        k = 1;
    } else {
        k = [self calculateKFromValue:maxNumber.doubleValue];
    }
    
    NSMutableArray *normalizedValues = [NSMutableArray array];
    for (NSNumber *value in values) {
        if (maxNumber.doubleValue <= 100) {
            [normalizedValues addObject:@(value.doubleValue * k)];
        } else {
            [normalizedValues addObject:@(value.doubleValue / k)];            
        }
    }
    return normalizedValues;
}

- (CGFloat)calculateKFromValue:(double)value
{
    NSInteger intValue = value;
    NSInteger power = 0;
    NSInteger reminder = intValue % 10;
    while (reminder) {
        intValue = intValue / 10;
        reminder = intValue % 10;
        power++;
    }
    double normalizedValue = value / pow(10, power-1);
    NSInteger normalizedIntValue = normalizedValue;
    if (normalizedIntValue > 5) {
        return 10;
    } else {
        return ((NSInteger)ceil(normalizedValue)) * 10;
    }
}

- (NSNumber *)findMaxValueInValues:(NSArray <NSNumber *>*)values
{
    NSNumber *maxValue = @0.0;
    for (NSNumber *value in values) {
        if (value.doubleValue > maxValue.doubleValue) {
            maxValue = value;
        }
    }
    return maxValue;
}

#pragma mark - JMRefreshable
- (void)refresh
{

}

#pragma mark - Custom accessors
- (JMWebEnvironment *)currentWebEnvironment
{
    return [[JMWebViewManager sharedInstance] reusableWebEnvironmentWithId:[self currentWebEnvironmentIdentifier]];
}

- (NSString *)currentWebEnvironmentIdentifier
{
    NSString *webEnvironmentIdentifier = kJMAdhocViewWebEnvironemntId;
    return webEnvironmentIdentifier;
}

- (void)resetSubViews
{
//    [self.reportLoader destroy];
//    [self.webEnvironment resetZoom];
//    [self.webEnvironment.webView removeFromSuperview];
//
//    self.webEnvironment = nil;
}

#pragma mark - Adhoc View Loader
//- (void)loadAdhocViewWithCompletion:(void(^)(BOOL success, NSError *error))completion
//{
//    JSReportLoaderCompletionBlock heapBlock = [completion copy];
//
//    JMJavascriptRequest *request = [JMJavascriptRequest requestWithCommand:@"JasperMobile.AdhocView.VIS.API.run"
//                                                                parameters:@{
//                                                                        @"uri" : self.resource.resourceLookup.uri
//                                                                }];
//    __weak __typeof(self) weakSelf = self;
//    [self.webEnvironment sendJavascriptRequest:request
//                                    completion:^(NSDictionary *parameters, NSError *error) {
//                                        __typeof(self) strongSelf = weakSelf;
//
//                                        if (error) {
//                                            heapBlock(NO, error);
//                                        } else {
//                                            heapBlock(YES, nil);
//                                        }
//                                    }];
//}

@end