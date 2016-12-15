//
// Created by Aleksandr Dakhno on 12/15/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "JMBaseUITestCase+Alerts.h"
#import "JMBaseUITestCase+Helpers.h"


@implementation JMBaseUITestCase (Alerts)

- (XCUIElement *)waitAlertInHierarchyWithTitle:(NSString *)title
                                       timeout:(NSTimeInterval)timeout
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    NSTimeInterval remain = timeout;
    XCUIElement *alert;
    do {
        remain -= kUITestsElementAvailableTimeout;
        alert = [self findAlertWithTitle:title];;
    } while (alert == nil && remain >= 0);

    return alert;
}

- (XCUIElement *)findAlertWithTitle:(NSString *)title
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    sleep(kUITestsElementAvailableTimeout);

    NSLog(@"All alerts : %@", self.application.alerts.allElementsBoundByAccessibilityElement);
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(XCUIElement *evaluatedObject, NSDictionary<NSString *, id> *bindings) {
        BOOL isEqualIdentifiers = [evaluatedObject.identifier isEqualToString:title];
        BOOL isEqualLabel = [evaluatedObject.label isEqualToString:title];
        return isEqualIdentifiers || isEqualLabel;
    }];
    XCUIElementQuery *elementQuery = [self.application.alerts matchingPredicate:predicate];
    NSArray *allElements = elementQuery.allElementsBoundByAccessibilityElement;
    XCUIElement *alert = allElements.firstObject;
    NSLog(@"All found alerts (with title %@): %@", title, allElements);
    return alert;
}

- (XCUIElement *)waitAlertWithTitle:(NSString *)title
                            timeout:(NSTimeInterval)timeout
{
    NSLog(@"%@ - %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    XCUIElement *alert = [self findAlertWithTitle:title];
    if (!alert) {
        alert = [self waitAlertInHierarchyWithTitle:title
                                            timeout:timeout];
    }
    [self waitElementReady:alert
                   timeout:timeout];
    return alert;
}

@end