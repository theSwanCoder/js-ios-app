/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksandr Dahno odahno@tibco.com
 @author Oleksii Gubariev ogubarie@tibco.com
 @since 2.3
 */

#import "JMExportResource.h"
@class JMExportTask;

typedef void(^JMSavingCompletion)(JMExportTask * _Nonnull task, NSURL * _Nullable savedResourceFolderURL, NSError * _Nullable error);

@interface JMExportTask : NSOperation {
    NSURL *_savedResourceFolderURL;
    NSError *_savingError;
}

@property (nonatomic, strong, nonnull, readonly) JMExportResource *exportResource;

- (nonnull instancetype)initWithResource:(nonnull JMExportResource *)resource;
+ (nonnull instancetype)taskWithResource:(nonnull JMExportResource *)resource;

- (void)completeOperation NS_REQUIRES_SUPER;

- (void)addSavingCompletionBlock:(nonnull JMSavingCompletion)completionBlock;

@end
