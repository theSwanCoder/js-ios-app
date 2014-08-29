//
//  JMServerOption.m
//  JasperMobile
//
//  Created by Oleksii Gubariev on 7/24/14.
//  Copyright (c) 2014 JasperMobile. All rights reserved.
//

#import "JMServerOption.h"

@implementation JMServerOption

- (id)init
{
    self = [super init];
    if (self) {
        self.editable = YES;
    }
    return self;
}

- (void)setOptionValue:(id)optionValue
{
    _optionValue = optionValue;
    self.errorString = nil;
}

@end
