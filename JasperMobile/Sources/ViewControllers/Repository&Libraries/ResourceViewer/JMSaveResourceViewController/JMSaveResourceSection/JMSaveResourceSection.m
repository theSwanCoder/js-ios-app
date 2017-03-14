/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMSaveResourceSection.h"

@implementation JMSaveResourceSection

- (instancetype)init
{
    [NSException raise:@"Init with (- (instancetype)initWithSectionType:(JMSaveResourceSectionType)sectionType title:(NSString *)title)"
                format:@""];
    return nil;
}

- (instancetype)initWithSectionType:(JMSaveResourceSectionType)sectionType title:(NSString *)title
{
    self = [super init];
    if (self) {
        _sectionType = sectionType;
        _title = title;
    }
    return self;
}

+ (JMSaveResourceSection *)sectionWithType:(JMSaveResourceSectionType)sectionType title:(NSString *)title
{
    return [[self.class alloc] initWithSectionType:sectionType title:title];
}
@end
