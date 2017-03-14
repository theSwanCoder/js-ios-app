/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @author Oleksii Gubariev ogubarie@tibco.com
 @since 2.3
 */

#import "JMExportTask.h"
#import "JMExportResource.h"

@interface JMExportManager : NSObject
+ (instancetype)sharedInstance;

- (void)saveResourceWithTask:(JMExportTask *)task;
- (void)addExportTask:(JMExportTask *)task;

- (void)cancelAll;
- (void)cancelTask:(JMExportTask *)task;
- (void)cancelTaskForResource:(JMExportResource *)resource;

- (NSArray <JMExportResource *> *)exportedResources;

+ (JMExportResource *)exportResourceWithName:(NSString *)resourceName format:(NSString *)reportFormat;

@end
