/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksii Gubariev ogubarie@tibco.com
 @since 2.3
 */

#import "JMExportTask.h"
#import "JSReport.h"

@interface JMReportExportTask : JMExportTask
@property (nonatomic, strong, readonly) JSReport *report;
@property (nonatomic, strong, readonly) JSReportPagesRange *pagesRange;

- (instancetype)initWithReport:(JSReport *)report name:(NSString *)name format:(NSString *)format pages:(JSReportPagesRange *)pagesRange;

@end
