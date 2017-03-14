/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksii Gubariev ogubarie@tibco.com
 @since 2.6
 */

#import <Foundation/Foundation.h>
#import "JMExportTask.h"
#import "JSDashboard.h"

@interface JMDashboardExportTask : JMExportTask
@property (nonatomic, strong, readonly) JSDashboard *dashboard;

- (instancetype)initWithDashboard:(JSDashboard *)dashboard name:(NSString *)name format:(NSString *)format;

@end
