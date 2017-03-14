/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.6
 */

@import UIKit;
#import "JMBaseViewController.h"
@class JMReportChartType;

@interface JMReportChartTypesVC : JMBaseViewController
@property (nonatomic, copy, nonnull) NSArray <JMReportChartType *>*chartTypes;
@property (nonatomic, strong) JMReportChartType *__nullable selectedChartType;
@property (nonatomic, copy, nullable) void(^exitBlock)(JMReportChartType * __nonnull selectedChartType);
@end
