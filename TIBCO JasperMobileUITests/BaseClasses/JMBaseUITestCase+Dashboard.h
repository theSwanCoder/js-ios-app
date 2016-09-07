//
// Created by Aleksandr Dakhno on 9/7/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMBaseUITestCase.h"

extern NSString *const kTestDashboardName;

@interface JMBaseUITestCase (Dashboard)
- (void)openTestDashboardPage;
- (void)closeTestDashboardPage;

- (void)openDashboardInfoPage;
- (void)closeDashboardInfoPage;

- (void)markDashboardAsFavoriteFromInfoPage;
- (void)unmarkDashboardFromFavoriteFromInfoPage;
@end