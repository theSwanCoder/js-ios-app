/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.5
 */

@import Foundation;

typedef NS_ENUM(NSInteger, JMScheduleVCRowType) {
    // Common field
    JMScheduleVCRowTypeLabel,
    JMScheduleVCRowTypeDescription,
    JMScheduleVCRowTypeOutputFileURI,
    JMScheduleVCRowTypeOutputFolderURI,
    JMScheduleVCRowTypeFormat,
    JMScheduleVCRowTypeTimeZone,
    // Start Date policy
    JMScheduleVCRowTypeStartDate,
    JMScheduleVCRowTypeStartImmediately, // boolean
    // Trigger
    JMScheduleVCRowTypeRepeatType,
    // Repeat Policy for simple trigger
    JMScheduleVCRowTypeRepeatCount,
    JMScheduleVCRowTypeRepeatTimeInterval,
    // Repeat Policy for calendar trigger
    JMScheduleVCRowTypeCalendarEveryMonth, // boolean
    JMScheduleVCRowTypeCalendarSelectedMonths,
    JMScheduleVCRowTypeCalendarEveryDay,  // boolean
    JMScheduleVCRowTypeCalendarSelectedDays,
    JMScheduleVCRowTypeCalendarDatesInMonth, // TODO: implement in next release
    JMScheduleVCRowTypeCalendarHours,
    JMScheduleVCRowTypeCalendarMinutes,
    // End Policy (common)
    JMScheduleVCRowTypeEndDate,
    // End Policy for simple trigger
    JMScheduleVCRowTypeRunIndefinitely, // boolean
    JMScheduleVCRowTypeNumberOfRuns,
};

@interface JMScheduleVCRow : NSObject
@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, strong) NSString *errorMessage;
@property (nonatomic, assign, readonly) JMScheduleVCRowType type;
@property (nonatomic, assign, getter=isHidden) BOOL hidden;
- (instancetype)initWithRowType:(JMScheduleVCRowType)type;
- (instancetype)initWithRowType:(JMScheduleVCRowType)type hidden:(BOOL)hidden;
+ (instancetype)rowWithRowType:(JMScheduleVCRowType)type;
+ (instancetype)rowWithRowType:(JMScheduleVCRowType)type hidden:(BOOL)hidden;
@end
