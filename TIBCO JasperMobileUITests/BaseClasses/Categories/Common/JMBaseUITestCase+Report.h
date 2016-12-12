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
- (void)openTestReportFromInfoPage;
- (void)openTestReportWithMandatoryFiltersPage;
- (void)openTestReportWithSingleSelectedControlPage;
- (void)openTestReportPageWithWaitingFinish:(BOOL)waitingFinish;
- (void)closeTestReportPage;
- (void)cancelOpeningTestReportPage;

- (void)openReportFiltersPage;
- (void)closeReportFiltersPage;

- (void)openSavingReportPage;
- (void)closeSaveReportPage;

- (void)saveTestReportWithName:(NSString *)name
                        format:(NSString *)format;

- (XCUIElement *)searchTestReportInSectionWithName:(NSString *)sectionName;

// Printing
- (void)openPrintReportPage;
- (void)closePrintReportPage;

// Verifying
- (void)verifyThatReportInfoPageOnScreen;
- (void)verifyThatReportInfoPageContainsCorrectDataForReportWithName:(NSString *)reportName;

- (void)givenThatReportCellsOnScreenInSectionWithName:(NSString *)sectionName;
@end
