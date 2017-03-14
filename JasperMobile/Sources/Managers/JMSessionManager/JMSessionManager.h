/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */

/**
 @author Oleksii Gubariev ogubarie@tibco.com
 @since 2.0
 */


#import <Foundation/Foundation.h>
#import "JSRESTBase.h"
#import "JMServerProfile+Helpers.h"

@class JSProfile;

@interface JMSessionManager : NSObject

@property (nonatomic, strong, readonly) JSRESTBase *restClient;

@property (nonatomic, strong, readonly) JSUserProfile *serverProfile;

+ (instancetype) sharedManager;

- (void) createSessionWithServerProfile:(JSProfile *)serverProfile completion:(void(^)(NSError *error))completionBlock;

- (void)restoreLastSessionWithCompletion:(void (^)(BOOL isSessionRestored))completion;

- (void) reset;

- (void)obsoleteSession;
- (void)obsoleteSessionInWebView;

- (void) logout;

- (void) updateSessionServerProfileWith:(JMServerProfile *)changedServerProfile;

- (NSPredicate *)predicateForCurrentServerProfile;

@end
