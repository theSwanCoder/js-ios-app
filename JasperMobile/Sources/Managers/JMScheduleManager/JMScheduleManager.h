/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.3
 */

#import "JaspersoftSDK.h"

@class JMResource;

typedef void(^JMScheduleCompletion)(JSScheduleMetadata *__nullable, NSError *__nullable);

@interface JMScheduleManager : NSObject
+ (instancetype __nullable)sharedManager;
- (void)loadScheduleMetadataForScheduleWithId:(NSInteger)scheduleId completion:(JMScheduleCompletion __nonnull)completion;
- (void)createScheduleWithData:(JSScheduleMetadata *__nonnull)jobData completion:(JMScheduleCompletion __nonnull)completion;
- (void)updateSchedule:(JSScheduleMetadata *__nonnull)schedule completion:(JMScheduleCompletion __nonnull)completion;
- (void)deleteScheduleWithJobIdentifier:(NSInteger)identifier completion:(void (^__nonnull)(NSError *__nullable))completion;
// create new model
- (JSScheduleMetadata *__nonnull)createNewScheduleMetadataWithResourceLookup:(JMResource *__nonnull)resourceLookup;
- (JSScheduleSimpleTrigger *__nonnull)defaultSimpleTrigger;
- (JSScheduleSimpleTrigger *__nonnull)defaultNoneTrigger;
- (JSScheduleCalendarTrigger *__nonnull)defaultCalendarTrigger;
@end
