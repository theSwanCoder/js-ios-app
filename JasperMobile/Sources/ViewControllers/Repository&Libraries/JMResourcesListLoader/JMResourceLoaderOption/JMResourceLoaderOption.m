/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMResourceLoaderOption.h"


@implementation JMResourceLoaderOption

- (instancetype)initWithTitle:(NSString *)title value:(id)value
{
    self = [super init];
    if (self) {
        _title = title;
        _value = value;
    }
    return self;
}

+ (instancetype)optionWithTitle:(NSString *)title value:(id)value
{
    return [[self alloc] initWithTitle:title value:value];
}

@end
