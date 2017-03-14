/*
 * Copyright ©  2016 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


/**
 @author Oleksii Gubariev ogubarie@tibco.com
 @since 2.6
 */

#import <UIKit/UIKit.h>

@class JMWebEnvironment;
@class JMResourceViewerStateManager;
@class JMResourceViewerPrintManager;
@class JMResourceViewerInfoPageManager;
@class JMResourceViewerShareManager;
@class JMResourceViewerHyperlinksManager;
@class JMResourceViewerDocumentManager;
@class JMResourceViewerExternalScreenManager;
@class JMResourceViewerSessionManager;

NS_ASSUME_NONNULL_BEGIN

@interface JMResourceViewerConfigurator : NSObject
@property (nonatomic, strong, readonly) JMWebEnvironment *webEnvironment;
@property (nonatomic, strong) JMResourceViewerStateManager *stateManager;
@property (nonatomic, strong) JMResourceViewerPrintManager *printManager;
@property (nonatomic, strong) JMResourceViewerInfoPageManager *infoPageManager;
@property (nonatomic, strong) JMResourceViewerShareManager *shareManager;
@property (nonatomic, strong) JMResourceViewerHyperlinksManager *hyperlinksManager;
@property (nonatomic, strong) JMResourceViewerDocumentManager *documentManager;
@property (nonatomic, strong) JMResourceViewerSessionManager *sessionManager;
@property (nonatomic, strong) JMResourceViewerExternalScreenManager *externalScreenManager;
@property (nonatomic, assign) CGFloat viewportScaleFactor;


- (instancetype)initWithWebEnvironment:(JMWebEnvironment *)webEnvironment;
+ (instancetype)configuratorWithWebEnvironment:(JMWebEnvironment *)webEnvironment;

- (void)configWithWebEnvironment:(JMWebEnvironment *)webEnvironment NS_REQUIRES_SUPER;

- (void)setup;
- (void)reset;

NS_ASSUME_NONNULL_END
@end
