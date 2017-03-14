/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMJavascriptResponse.h"


@implementation JMJavascriptResponse

- (NSString *)description
{
    NSString *description = [NSString stringWithFormat:@"\nJMJavascriptCallback: %@\ncommand: %@\ntype: %@\nparams:%@", [super description], self.command, @(self.type), self.parameters];
    return description;
}

@end
