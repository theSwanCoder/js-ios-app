/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.6
 */

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

    if (elementHittable) {
        [self tap];
    } else {
        // TODO: Should we interpret it as an error?
        NSLog(@"Element isHittable: NO");
    }
}

@end
