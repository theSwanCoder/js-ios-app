/*
 * Copyright ©  2013 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMSingleSelectInputControlCell.h"
#import "JMLocalization.h"

@interface JMSingleSelectInputControlCell()
@property (nonatomic, weak) IBOutlet UILabel *valueLabel;
@end

@implementation JMSingleSelectInputControlCell

- (void)setEnabledCell:(BOOL)enabled
{
    [super setEnabledCell:enabled];
    self.userInteractionEnabled = enabled;
}

- (void)updateWithParameters:(NSArray *)parameters
{
    [self updateValueLabelWithParameters:parameters];
    [self.delegate updatedInputControlsValuesWithDescriptor:self.inputControlDescriptor];
    [self.delegate inputControlCellDidChangedValue:self];
}

- (void)setInputControlDescriptor:(JSInputControlDescriptor *)inputControlDescriptor
{
    [super setInputControlDescriptor:inputControlDescriptor];
    [self setInputControlState:inputControlDescriptor.state];
}

- (void)setInputControlState:(JSInputControlState *)state
{
    self.inputControlDescriptor.state = state;
    NSMutableArray *selectedValues = [NSMutableArray array];
    for (JSInputControlOption *option in state.options) {
        if (option.selected) {
            [selectedValues addObject:option];
        }
    }
    [self updateValueLabelWithParameters:selectedValues];
}

- (void)updateValueLabelWithParameters:(NSArray *)parameters
{
    if ([parameters count] > 0) {
        NSArray *allValues = [parameters sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [[obj1 label] compare:[obj2 label]];
        }];
        NSMutableString *valuesAsStrings = [NSMutableString string];
        for (JSInputControlOption *option in allValues) {
            NSString *formatString = [valuesAsStrings length] ? @", %@" : @"%@";
            [valuesAsStrings appendFormat:formatString, option.label];
        }
        self.inputControlDescriptor.state.value = valuesAsStrings;
        self.valueLabel.text = valuesAsStrings;
    } else {
        self.inputControlDescriptor.state.value = nil;
        self.valueLabel.text = JMLocalizedString(@"---");
    }
    [self updateDisplayingOfErrorMessage];
}

@end
