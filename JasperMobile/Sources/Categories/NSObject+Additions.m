/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "NSObject+Additions.h"


@implementation NSObject(Additions)

- (JSRESTBase *)restClient
{
    return [JMSessionManager sharedManager].restClient;
}

@end
