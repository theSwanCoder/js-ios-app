/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @since 2.3
 */

#import "JMEditabledViewController.h"
#import "JaspersoftSDK.h"
@class JMResource;

typedef void(^JMScheduleCompletionBlock)(JSScheduleMetadata *__nullable);

@interface JMScheduleVC : JMEditabledViewController
@property (nonatomic, strong, readonly) JSScheduleMetadata *__nonnull scheduleMetadata;
@property (nonatomic, strong) NSString *__nullable backButtonTitle;
@property (nonatomic, copy) JMScheduleCompletionBlock __nonnull exitBlock;

- (void)createNewScheduleMetadataWithResourceLookup:(nonnull JMResource *)resource;

- (void)updateScheduleMetadata:(nonnull JSScheduleMetadata *)metaData;

@end
