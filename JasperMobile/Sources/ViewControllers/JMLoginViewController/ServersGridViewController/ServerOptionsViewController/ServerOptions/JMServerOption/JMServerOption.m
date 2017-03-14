/*
 * Copyright ©  2014 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMServerOption.h"

@implementation JMServerOption

- (instancetype)initWithTitle:(NSString *)title
                  optionValue:(id)optionValue
               cellIdentifier:(NSString *)cellIdentifier
                     editable:(BOOL)editable
{
    self = [super init];
    if (self) {
        _titleString = title;
        _optionValue = optionValue;
        _cellIdentifier = cellIdentifier;
        _editable = editable;
    }
    return self;
}

+ (instancetype)optionWithTitle:(NSString *)title
                    optionValue:(id)optionValue
                 cellIdentifier:(NSString *)cellIdentifier
                       editable:(BOOL)editable
{
    return [[self alloc] initWithTitle:title
                           optionValue:optionValue
                        cellIdentifier:cellIdentifier
                              editable:editable];
}

- (void)setOptionValue:(id)optionValue
{
    if (optionValue != _optionValue) {
        _optionValue = optionValue;
        _errorString = nil;
    }
}

@end
