/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMScheduleVCSection.h"

@interface JMScheduleVCSection()
@property (nonatomic, strong, readwrite) NSMutableArray <JMScheduleVCRow *> *internalRows;
@end

@implementation JMScheduleVCSection

- (instancetype)initWithSectionType:(JMScheduleVCSectionType)type rows:(NSArray <JMScheduleVCRow *> *)rows
{
    self = [super init];
    if (self) {
        _title = [self titleForSectionType:type];
        _type = type;
        _internalRows = [rows mutableCopy];
    }
    return self;
}

+ (instancetype)sectionWithSectionType:(JMScheduleVCSectionType)type rows:(NSArray <JMScheduleVCRow *> *)rows
{
    return [[self alloc] initWithSectionType:type rows:rows];
}

- (JMScheduleVCRow *)rowWithType:(JMScheduleVCRowType)type
{
    JMScheduleVCRow *searchRow;
    for (JMScheduleVCRow *row in self.internalRows) {
        if (row.type == type) {
            searchRow = row;
            break;
        }
    }
    if (!searchRow) {
        // TODO: handle this
    }
    return searchRow;
}

- (void)hideRowWithType:(JMScheduleVCRowType)type
{
    JMScheduleVCRow *row = [self rowWithType:type];
    row.hidden = YES;
}

- (void)showRowWithType:(JMScheduleVCRowType)type
{
    JMScheduleVCRow *row = [self rowWithType:type];
    row.hidden = NO;
}

#pragma mark - Custom Accessors
- (NSArray <JMScheduleVCRow *>*)rows
{
    NSMutableArray *rows = [NSMutableArray array];
    for (JMScheduleVCRow *row in self.internalRows) {
        if (!row.hidden) {
            [rows addObject:row];
        }
    }
    return rows;
}

#pragma mark - Helpers
- (NSString *)titleForSectionType:(JMScheduleVCSectionType)type
{
    NSString *title;
    switch(type) {
        case JMNewScheduleVCSectionTypeMain: {
            title = @"Main";
            break;
        }
        case JMNewScheduleVCSectionTypeOutputOptions: {
            title = @"Output Options";
            break;
        }
        case JMNewScheduleVCSectionTypeScheduleStart: {
            title = @"Schedule Start";
            break;
        }
        case JMNewScheduleVCSectionTypeRecurrence: {
            title = @"Recurrence";
            break;
        }
        case JMNewScheduleVCSectionTypeScheduleEnd: {
            title = @"Schedule End";
            break;
        }
        case JMNewScheduleVCSectionTypeHolidays: {
            title = @"Holidays";
            break;
        }
    }
    return title;
}

@end
