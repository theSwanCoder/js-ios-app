//
// Created by Aleksandr Dakhno on 9/13/15.
// Copyright (c) 2015 TIBCO JasperMobile. All rights reserved.
//

#import "JMHTMLElement.h"


@implementation JMHTMLElement

- (NSString *)description
{
    return [NSString stringWithFormat:@"type: %@; child: %@", self.elementType, self.childElements];
}

@end