/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMSelectedItem.h"


@implementation JMSelectedItem

- (instancetype)initWithTitle:(NSString *)title value:(id)value selected:(BOOL)selected
{
    self = [super init];
    if (self) {
        _title = title;
        _value = value;
        _selected = selected;
    }
    return self;
}

+ (instancetype)itemWithTitle:(NSString *)title value:(id)value selected:(BOOL)selected
{
    return [[self alloc] initWithTitle:title value:value selected:selected];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"item: %@, selected:%@", self.title, self.isSelected ? @"YES": @"NO"];
}

@end
