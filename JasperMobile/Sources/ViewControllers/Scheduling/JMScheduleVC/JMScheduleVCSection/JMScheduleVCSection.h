/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.3
 */

#import "JMScheduleVCRow.h"

typedef NS_ENUM(NSInteger, JMScheduleVCSectionType) {
    JMNewScheduleVCSectionTypeMain = 0,
    JMNewScheduleVCSectionTypeOutputOptions,
    JMNewScheduleVCSectionTypeScheduleStart,
    JMNewScheduleVCSectionTypeRecurrence,
    JMNewScheduleVCSectionTypeScheduleEnd,
    JMNewScheduleVCSectionTypeHolidays,
};

@interface JMScheduleVCSection : NSObject
@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, assign, readonly) JMScheduleVCSectionType type;
@property (nonatomic, strong, readonly) NSArray <JMScheduleVCRow *>*rows;
- (instancetype)initWithSectionType:(JMScheduleVCSectionType)type rows:(NSArray <JMScheduleVCRow *> *)rows;
+ (instancetype)sectionWithSectionType:(JMScheduleVCSectionType)type rows:(NSArray <JMScheduleVCRow *> *)rows;
- (JMScheduleVCRow *)rowWithType:(JMScheduleVCRowType)type;
- (void)hideRowWithType:(JMScheduleVCRowType)type;
- (void)showRowWithType:(JMScheduleVCRowType)type;
@end
