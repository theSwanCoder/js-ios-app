//
// Created by Aleksandr Dakhno on 9/7/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMBaseUITestCase.h"

extern NSString *const kTestDashboardName;

@interface JMBaseUITestCase (Dashboard)
- (void)openTestDashboardPage;
- (void)openTestDashboardPageWithWaitingFinish:(BOOL)waitingFinish;
- (void)closeTestDashboardPage;
- (void)cancelOpeningTestDashboardPage;

- (void)openDashboardInfoPage;
- (void)closeDashboardInfoPage;

- (void)markDashboardAsFavoriteFromInfoPage;
- (void)unmarkDashboardFromFavoriteFromInfoPage;

- (void)markDashboardAsFavoriteFromActionsMenu;
- (void)unmarkDashboardFromFavoriteFromActionsMenu;

- (void)markDashboardAsFavoriteFromNavigationBar;
- (void)unmarkDashboardFromFavoriteFromNavigationBar;

- (void)refreshDashboard;

- (void)openPrintDashboardPage;
- (void)closePrintDashboardPage;
@end