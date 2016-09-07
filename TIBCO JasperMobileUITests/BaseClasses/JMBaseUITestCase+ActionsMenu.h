//
// Created by Aleksandr Dakhno on 9/7/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMBaseUITestCase.h"

@interface JMBaseUITestCase (ActionsMenu)
- (void)openMenuActions;
- (void)selectActionWithName:(NSString *)actionName;
- (void)openMenuActionsOnNavBarWithLabel:(NSString *)label;
@end