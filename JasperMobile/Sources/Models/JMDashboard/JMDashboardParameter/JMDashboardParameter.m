/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMDashboardParameter.h"


@implementation JMDashboardParameter

#pragma mark - Life Cycle
- (instancetype)initWithData:(NSDictionary *)data
{
    self = [super init];
    if (self) {
        _identifier = data[@"id"];
        _values = data[@"value"];
    }
    return self;
}

+ (instancetype)parameterWithData:(NSDictionary *)data
{
    return [[self alloc] initWithData:data];
}

#pragma mark - Public API
- (void)updateValuesWithString:(NSString *)stringValues
{
    NSArray *values = [stringValues componentsSeparatedByString:@","];
    self.values = values;
}

- (NSString *)valuesAsString
{
    NSString *valuesAsString = self.values.firstObject;
    if (self.values.count > 1) {
        valuesAsString = [NSString stringWithFormat:@"%@, ", self.values.firstObject];
        for (int i = 1; i < self.values.count; i++) {
            if (i == self.values.count - 1) {
                valuesAsString = [valuesAsString stringByAppendingFormat:@"%@", self.values[i]];
            } else {
                valuesAsString = [valuesAsString stringByAppendingFormat:@"%@, ", self.values[i]];
            }
        }
    }
    return valuesAsString;
}

@end
