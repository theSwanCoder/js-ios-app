//
//  JMBaseUITestCase+Report.h
//  TIBCO JasperMobile
//
//  Created by Aleksandr Dakhno on 9/12/16.
//  Copyright © 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMBaseUITestCase.h"

extern NSString *const kTestReportName;
extern NSString *const kTestReportWithMandatoryFiltersName;
extern NSString *const kTestReportWithSingleSelectedControlName;

@interface JMBaseUITestCase (Report)
- (void)openTestReportPage;
- (void)openTestReportWithMandatoryFiltersPage;
- (void)openTestReportWithSingleSelectedControlPage;
- (void)openTestReportPageWithWaitingFinish:(BOOL)waitingFinish;
- (void)closeTestReportPage;
- (void)cancelOpeningTestReportPage;

- (void)openReportFiltersPage;
- (void)closeReportFiltersPage;

- (void)openSaveReportPage;
- (void)closeSaveReportPage;

- (void)saveTestReportWithName:(NSString *)name format:(NSString *)format;
@end
