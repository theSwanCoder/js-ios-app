//
// Created by Aleksandr Dakhno on 12/13/16.
// Copyright (c) 2016 TIBCO JasperMobile. All rights reserved.
//

#import "XCUIElement+Tappable.h"


@implementation XCUIElement (Tappable)

- (void)tapByWaitingHittable
{
    // TODO: Do we need variable timeout
    NSTimeInterval timeout = 3;
    NSTimeInterval waitingInterval = 1;
    NSTimeInterval remain = timeout;
    BOOL elementHittable = self.isHittable;
    NSLog(@"Element isHittable: %@", elementHittable ? @"YES" : @"NO");
    while ( remain >= 0 && !elementHittable) {
        remain -= waitingInterval;
        sleep(waitingInterval);

        elementHittable = self.isHittable;
        NSLog(@"remain: %@", @(remain));
        NSLog(@"Element isHittable: %@", elementHittable ? @"YES" : @"NO");
    }

    if (!self.isHittable) {
        // TODO: Should we interpret it as an error?
    } else {
        [self tap];
    }
}

@end
